import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.firebase-perf")
    id("com.google.firebase.crashlytics")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is configured via android/key.properties (git-ignored).
// Copy key.properties.example to key.properties and point it at your upload
// keystore to ship Play-ready builds (see android/fastlane/README.md). When
// the file is absent — the default template state — release falls back to the
// debug keystore so the app still builds without any setup.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    namespace = "com.lucistudio.flutter_starter_template"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        // Flavors below define custom resource values via resValue(...).
        // AGP 9 disables this feature by default, so opt in explicitly.
        resValues = true
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            resValue("string", "app_name", "ZenPack (Dev)")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "ZenPack (Staging)")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "ZenPack")
        }
    }

    defaultConfig {
        applicationId = "com.aktechvn.zenpack"
        // ffmpeg_kit_extended_flutter (video-stamp overlay) requires API 26+.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

// ponytail: camerawesome 2.5.0 (latest published, unmaintained 13mo) vendors
// CameraX 1.4.2, which hits a known "Unable to establish connection on
// channel: ...ProcessCameraProvider.getInstance" release-build-only failure on
// some real devices (github.com/Apparence-io/CamerAwesome/issues/399,
// github.com/flutter/flutter/issues/167790 — the latter's own reporter fixed
// it by bumping their CameraX version). Forcing the newest stable CameraX
// artifacts is an experiment to see if the same fix applies here; drop this
// block if it doesn't help, or once camerawesome ships a version that bumps
// CameraX itself.
configurations.all {
    resolutionStrategy {
        force(
            "androidx.camera:camera-core:1.6.1",
            "androidx.camera:camera-camera2:1.6.1",
            "androidx.camera:camera-lifecycle:1.6.1",
            "androidx.camera:camera-video:1.6.1",
            "androidx.camera:camera-view:1.6.1",
            "androidx.camera:camera-extensions:1.6.1",
        )
    }
}
