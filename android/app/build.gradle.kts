import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.painpointtoday.yourhome"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        applicationId = "com.painpointtoday.yourhome"
        minSdk = 24
        targetSdk = 36
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

        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "YourHome Dev")
            signingConfig = signingConfigs.getByName("debug")
        }
        create("staging") {
            dimension = "env"
            resValue("string", "app_name", "YourHome Staging")
            signingConfig = signingConfigs.getByName("debug")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "YourHome")
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
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
