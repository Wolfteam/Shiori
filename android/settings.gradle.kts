import java.util.Properties

pluginManagement {
    val flutterSdkPath = {
        val properties = Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        check(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    val flutterPath = flutterSdkPath()
    extra["flutterSdkPath"] = flutterPath

    includeBuild("$flutterPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version "4.4.2" apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
