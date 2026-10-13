package com.montra.app.montra

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import io.flutter.FlutterInjector

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"

        private val lock = Any()

        @Volatile private var backgroundEngine: FlutterEngine? = null
        @Volatile private var backgroundChannel: MethodChannel? = null
        @Volatile private var isChannelReady = false

        // Tracks how many SMS have been sent to Dart but not yet confirmed done.
        private var pendingProcessingCount = 0

        // SMS received before the Dart engine is ready.
        private val pendingSmsQueue = mutableListOf<Map<String, Any>>()

        fun resetEngine() {
            synchronized(lock) {
                Log.d(TAG, "Resetting background engine state.")
                backgroundChannel?.setMethodCallHandler(null)
                backgroundChannel = null
                backgroundEngine?.destroy()
                backgroundEngine = null
                isChannelReady = false
                pendingProcessingCount = 0
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return

        val messagesBySender = messages.groupBy { it.displayOriginatingAddress ?: "" }
        for ((sender, parts) in messagesBySender) {
            val body = parts.joinToString("") { it.displayMessageBody ?: "" }
            val receivedAt = parts.firstOrNull()?.timestampMillis ?: System.currentTimeMillis()

            Log.d(TAG, "Received SMS from: $sender, body length: ${body.length}")

            val args = mapOf(
                "sender" to sender,
                "body" to body,
                "receivedAt" to receivedAt
            )

            val fgChannel = MainActivity.foregroundChannel
            if (fgChannel != null) {
                Log.d(TAG, "App is in foreground, sending SMS to foreground channel directly")
                fgChannel.invokeMethod("onSmsReceivedForeground", args)
            } else {
                synchronized(lock) {
                    if (isChannelReady && backgroundChannel != null) {
                        Log.d(TAG, "Channel ready, sending SMS to Dart immediately")
                        pendingProcessingCount++
                        backgroundChannel!!.invokeMethod("onSmsReceived", args)
                    } else {
                        Log.d(TAG, "Channel not ready, queueing SMS and starting engine")
                        pendingSmsQueue.add(args)
                        startBackgroundEngine(context)
                    }
                }
            }
        }
    }

    private fun startBackgroundEngine(context: Context) {
        if (backgroundEngine != null) {
            Log.d(TAG, "Background engine already initializing, SMS queued.")
            return
        }

        val sharedPrefs = context.getSharedPreferences("sms_prefs", Context.MODE_PRIVATE)
        val callbackHandle = sharedPrefs.getLong("callbackHandle", -1L)

        if (callbackHandle == -1L) {
            Log.e(TAG, "No callback handle stored. Open the app at least once to register.")
            pendingSmsQueue.clear()
            return
        }

        try {
            Log.d(TAG, "Spinning up background Flutter engine with handle: $callbackHandle")

            val loader = FlutterInjector.instance().flutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(context.applicationContext)
                loader.ensureInitializationComplete(context.applicationContext, null)
            }

            val engine = FlutterEngine(context.applicationContext)
            backgroundEngine = engine

            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
            if (callbackInfo == null) {
                Log.e(TAG, "Dart callback not found — reopen the app to re-register.")
                resetEngine()
                return
            }

            val dartCallback = DartExecutor.DartCallback(
                context.assets,
                loader.findAppBundlePath(),
                callbackInfo
            )
            engine.dartExecutor.executeDartCallback(dartCallback)

            val channel = MethodChannel(
                engine.dartExecutor.binaryMessenger,
                "com.montra.app/sms_background"
            )
            backgroundChannel = channel

            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "backgroundChannelReady" -> {
                        synchronized(lock) {
                            Log.d(TAG, "Dart ready. Flushing ${pendingSmsQueue.size} queued SMS(es).")
                            isChannelReady = true
                            for (sms in pendingSmsQueue) {
                                pendingProcessingCount++
                                channel.invokeMethod("onSmsReceived", sms)
                            }
                            pendingSmsQueue.clear()
                        }
                        result.success(null)
                    }
                    "smsProcessingComplete" -> {
                        result.success(null)
                        synchronized(lock) {
                            pendingProcessingCount--
                            Log.d(TAG, "SMS processed. Remaining: $pendingProcessingCount")
                            if (pendingProcessingCount <= 0) {
                                Log.d(TAG, "All SMS processed. Scheduling engine teardown in 2500ms.")
                                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                                    synchronized(lock) {
                                        if (pendingProcessingCount <= 0) {
                                            resetEngine()
                                        }
                                    }
                                }, 2500)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start background Flutter engine: ${e.message}", e)
            resetEngine()
        }
    }
}
