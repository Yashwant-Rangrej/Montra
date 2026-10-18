package com.montra.app.montra

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.os.Bundle

class MainActivity: FlutterFragmentActivity() {
    companion object {
        var foregroundChannel: MethodChannel? = null
        var isAppInForeground: Boolean = false
    }

    private val CHANNEL = "com.montra.app/sms_interceptor"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (!isTaskRoot) {
            val intent = intent
            if (intent.hasCategory(Intent.CATEGORY_LAUNCHER) && Intent.ACTION_MAIN == intent.action) {
                finish()
                return
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        foregroundChannel = channel

        channel.setMethodCallHandler { call, result ->
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

    override fun onResume() {
        super.onResume()
        isAppInForeground = true
    }

    override fun onPause() {
        super.onPause()
        isAppInForeground = false
    }

    override fun onDestroy() {
        foregroundChannel = null
        isAppInForeground = false
        super.onDestroy()
    }
}
