plugins {
    id("com.android.application")
    id("kotlin-android")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.youragent"
    compileSdk = 36 // Updated to stable SDK 36
    ndkVersion = flutter.ndkVersion
    buildToolsVersion = "36.0.0" // Updated to stable Build Tools 36.0.0

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21 // Updated to stable JDK 21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.youragent"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24 // Reasonable stable minSdk
        targetSdk = 36 // Updated to stable Target SDK 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        getByName("debug") {
            val userHome = System.getProperty("user.home")
            storeFile = file("$userHome/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "YourAgent Dev")
            signingConfig = signingConfigs.getByName("debug")
        }
        create("staging") {
            dimension = "env"
            resValue("string", "app_name", "YourAgent Staging")
            signingConfig = signingConfigs.getByName("debug")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "YourAgent")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

// Copy flavor app icons from assets/logo into dev/staging res so launcher uses them
val flavorIcons = mapOf(
    "dev" to "app_icon_dev.png",
    "staging" to "app_icon_uat.png",
)
val densities = listOf("mdpi", "hdpi", "xhdpi", "xxhdpi", "xxxhdpi")

flavorIcons.forEach { (flavor, iconName) ->
    val taskName = "copy${flavor.replaceFirstChar { it.uppercase() }}Icon"
    tasks.register(taskName) {
        doLast {
            val source = file("${project.projectDir}/../../assets/logo/$iconName")
            if (source.exists()) {
                densities.forEach { density ->
                    val destDir = file("${project.projectDir}/src/$flavor/res/drawable-$density")
                    destDir.mkdirs()
                    copy {
                        from(source)
                        into(destDir)
                        rename { "ic_launcher_foreground.png" }
                    }
                }
            }
        }
    }
}

afterEvaluate {
    flavorIcons.keys.forEach { flavor ->
        val cap = flavor.replaceFirstChar { it.uppercase() }
        tasks.matching {
            it.name.startsWith("merge${cap}") && it.name.endsWith("Resources")
        }.configureEach {
            dependsOn("copy${cap}Icon")
        }
    }
}
