plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter doit venir après Android et Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.volontariat_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "26.1.10909125"

    defaultConfig {
        applicationId = "com.example.volontariat_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // Pour tester rapidement en release
            signingConfig = signingConfigs.getByName("debug")
            // Active le shrinker/désactivation si besoin :
            // isMinifyEnabled = false
            // proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
