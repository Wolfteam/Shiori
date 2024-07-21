package com.miraisoft.shiori

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object {
        const val methodChannelName = "com.github.wolfteam.shiori"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName).setMethodCallHandler(::onMethodCall)
    }

    private fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        Log.d("onMethodCall", "[$methodChannelName] ${call.method}")
        try {
            when (call.method) {
                else -> {
                    result.notImplemented()
                }
            }

            result.success(null)
        } catch (error: Exception) {
            Log.e("onMethodCall", methodChannelName, error)
            throw error
        }
    }
}
