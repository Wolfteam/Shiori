package com.miraisoft.shiori

import android.util.Log
import androidx.annotation.NonNull
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
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
                "start" -> {
                    if (activity.application == null) {
                        val error = "Fail to resolve Application on registration"
                        Log.e(call.method, error)
                        result.error(call.method, error, Exception(error))
                        return
                    }

                    val appSecret = call.argument<String>("secret")
                    if (appSecret == null || appSecret.isEmpty()) {
                        val error = "App secret is not set"
                        Log.e(call.method, error)
                        result.error(call.method, error, Exception(error))
                        return
                    }

                    AppCenter.start(activity.application, appSecret, Analytics::class.java, Crashes::class.java)
                }
                "trackEvent" -> {
                    val name = call.argument<String>("name")
                    val properties = call.argument<Map<String, String>>("properties")
                    Analytics.trackEvent(name, properties)
                }
                "getInstallId" -> {
                    result.success(AppCenter.getInstallId().get()?.toString())
                    return
                }
                "isCrashesEnabled" -> {
                    result.success(Crashes.isEnabled().get())
                    return
                }
                "configureCrashes" -> {
                    val value = call.arguments as Boolean
                    Crashes.setEnabled(value).get()
                }
                "isAnalyticsEnabled" -> {
                    result.success(Analytics.isEnabled().get())
                    return
                }
                "configureAnalytics" -> {
                    val value = call.arguments as Boolean
                    Analytics.setEnabled(value).get()
                }
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
