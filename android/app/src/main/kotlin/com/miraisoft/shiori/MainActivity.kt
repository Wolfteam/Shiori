package com.miraisoft.shiori

import android.util.Log
import android.webkit.WebSettings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object {
        const val METHOD_CHANNEL_NAME = "com.github.wolfteam.shiori"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME).setMethodCallHandler(::onMethodCall)
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("onMethodCall", "[$METHOD_CHANNEL_NAME] ${call.method}")
        try {
            when (call.method) {
                "getWebViewUserAgent" -> {
                    val webViewUserAgent = getWebViewUserAgent()
                    result.success(webViewUserAgent)
                }
                else -> {
                    result.notImplemented()
                }
            }

            result.success(null)
        } catch (error: Exception) {
            Log.e("onMethodCall", METHOD_CHANNEL_NAME, error)
            throw error
        }
    }

    private fun getWebViewUserAgent(): String {
        return WebSettings.getDefaultUserAgent(this.applicationContext)
    }
}
