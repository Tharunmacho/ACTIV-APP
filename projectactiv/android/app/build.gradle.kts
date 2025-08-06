plugins {
    id("com.android.application")
    id("kotlin-android")

    // ✅ Apply Flutter plugin after Android and Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")

    // ✅ Apply Google Services plugin (version set at project-level)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.projectactiv"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.projectactiv"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Replace with release signing config before production
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
