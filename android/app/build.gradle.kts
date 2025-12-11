// android/app/build.gradle.kts (Kotlin DSL)

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tripify"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Ganti ke Java 1.8
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        
        // AKTIFKAN CORE LIBRARY DESUGARING
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        // PERBAIKAN SINTAKSIS: Menggunakan tanda kutip ganda
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.tripify"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// PERBAIKAN SINTAKSIS: Menggunakan tanda kurung untuk Kotlin DSL
dependencies {
    // UBAH VERSI DARI 2.0.4 menjadi 2.1.4
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") 
}