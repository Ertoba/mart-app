import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    //id("com.google.firebase.crashlytics")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "ge.mili.customer"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "ge.mili.customer"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug") // or "release" if you have real keystore
        }
    }


}

// Fix for AGP 8.10.0: manually copy flutter_assets into the merge output with correct path
project.afterEvaluate {
    val buildDir = project.layout.buildDirectory.get()
    val flutterAssetsDir = "$buildDir/intermediates/flutter/release/flutter_assets"
    val mergeOutputDir = "$buildDir/intermediates/assets/release/mergeReleaseAssets"

    val fixFlutterAssets = project.tasks.register("fixFlutterAssetsRelease", Copy::class.java) {
        dependsOn("compileFlutterBuildRelease")
        dependsOn("mergeReleaseAssets")
        from(flutterAssetsDir)
        into("$mergeOutputDir/flutter_assets")
    }

    project.tasks.findByName("compressReleaseAssets")?.dependsOn(fixFlutterAssets)
    project.tasks.findByName("packageRelease")?.dependsOn(fixFlutterAssets)
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("com.google.firebase:firebase-messaging:23.4.1")
    implementation("com.facebook.android:facebook-android-sdk:latest.release")
    implementation("com.google.android.gms:play-services-base:17.6.0")
    implementation("com.google.android.gms:play-services-wallet:19.4.0")
}
