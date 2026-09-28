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
import io.flutter.embedding.engine.loader.FlutterLoader

class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
        var backgroundEngine: FlutterEngine? = null
        var backgroundChannel: MethodChannel? = null
        private var isChannelReady = false
        private val pendingSmsQueue = mutableListOf<Map<String, Any>>()
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        for (sms in messages) {
            val sender = sms.displayOriginatingAddress ?: ""
            val body = sms.displayMessageBody ?: ""
            val receivedAt = sms.timestampMillis

            Log.d(TAG, "Received SMS from: $sender, body length: ${body.length}")

            val args = mapOf(
                "sender" to sender,
                "body" to body,
                "receivedAt" to receivedAt
            )

            if (isChannelReady && backgroundChannel != null) {
                Log.d(TAG, "Channel ready, sending SMS to Dart immediately")
                backgroundChannel!!.invokeMethod("onSmsReceived", args)
            } else {
                Log.d(TAG, "Channel not ready, queueing SMS and starting engine")
                pendingSmsQueue.add(args)
                startBackgroundEngine(context)
            }
        }
    }

    private fun startBackgroundEngine(context: Context) {
        if (backgroundEngine != null) {
            Log.d(TAG, "Background engine already exists, waiting for it to become ready")
            return
        }

        val sharedPrefs = context.getSharedPreferences("sms_prefs", Context.MODE_PRIVATE)
        val callbackHandle = sharedPrefs.getLong("callbackHandle", -1L)

        if (callbackHandle == -1L) {
            Log.e(TAG, "No callback handle stored. App must be opened at least once first.")
            return
        }

        try {
            Log.d(TAG, "Spinning up background Flutter engine with callback handle: $callbackHandle")
            val loader = FlutterInjector.instance().flutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(context)
                loader.ensureInitializationComplete(context, null)
            }

            backgroundEngine = FlutterEngine(context)

            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
            if (callbackInfo == null) {
                Log.e(TAG, "Could not find Dart callback. Re-open the app to re-register.")
                backgroundEngine = null
                return
            }

            val dartCallback = DartExecutor.DartCallback(
                context.assets,
                loader.findAppBundlePath(),
                callbackInfo
            )
            backgroundEngine!!.dartExecutor.executeDartCallback(dartCallback)

            backgroundChannel = MethodChannel(
                backgroundEngine!!.dartExecutor.binaryMessenger,
                "com.montra.app/sms_background"
            )

            // Listen for the Dart side to signal it is ready
            backgroundChannel!!.setMethodCallHandler { call, result ->
                if (call.method == "backgroundChannelReady") {
                    Log.d(TAG, "Background channel ready. Flushing ${pendingSmsQueue.size} queued SMS(es).")
                    isChannelReady = true
                    for (sms in pendingSmsQueue) {
                        backgroundChannel!!.invokeMethod("onSmsReceived", sms)
                    }
                    pendingSmsQueue.clear()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start background Flutter engine: ${e.message}", e)
            backgroundEngine = null
            backgroundChannel = null
        }
    }
}

