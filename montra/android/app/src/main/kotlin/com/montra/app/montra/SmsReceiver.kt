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
        var backgroundEngine: FlutterEngine? = null
        var backgroundChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            for (sms in messages) {
                val sender = sms.displayOriginatingAddress ?: ""
                val body = sms.displayMessageBody ?: ""
                val receivedAt = sms.timestampMillis

                Log.d("SmsReceiver", "Received SMS from $sender")

                sendToFlutter(context, sender, body, receivedAt)
            }
        }
    }

    private fun sendToFlutter(context: Context, sender: String, body: String, receivedAt: Long) {
        val sharedPrefs = context.getSharedPreferences("sms_prefs", Context.MODE_PRIVATE)
        val callbackHandle = sharedPrefs.getLong("callbackHandle", -1L)

        if (callbackHandle == -1L) {
            Log.e("SmsReceiver", "No callback handle found. Flutter background handler not initialized.")
            return
        }

        if (backgroundEngine == null) {
            Log.d("SmsReceiver", "Initializing Flutter engine for background execution")
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(context)
            loader.ensureInitializationComplete(context, null)

            backgroundEngine = FlutterEngine(context)
            val callbackInfo = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)
            if (callbackInfo == null) {
                Log.e("SmsReceiver", "Fatal: failed to find callback")
                return
            }

            val args = DartExecutor.DartCallback(context.assets, loader.findAppBundlePath(), callbackInfo)
            backgroundEngine?.dartExecutor?.executeDartCallback(args)

            backgroundChannel = MethodChannel(backgroundEngine!!.dartExecutor.binaryMessenger, "com.montra.app/sms_background")
        }

        val arguments = mapOf(
            "sender" to sender,
            "body" to body,
            "receivedAt" to receivedAt
        )
        
        backgroundChannel?.invokeMethod("onSmsReceived", arguments)
    }
}
