package com.montra.app.montra

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.montra.app/sms_interceptor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initialize") {
                val callbackHandle = call.argument<Long>("callbackHandle")
                if (callbackHandle != null) {
                    val sharedPrefs = getSharedPreferences("sms_prefs", Context.MODE_PRIVATE)
                    sharedPrefs.edit().putLong("callbackHandle", callbackHandle).apply()
                    result.success(true)
                } else {
                    result.error("INVALID_ARGS", "callbackHandle is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
