# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# WorkManager
-keep class androidx.work.** { *; }

# App Package
-keep class com.montra.app.montra.** { *; }

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Parcelable / Serializable
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}
-keepnames class * implements java.io.Serializable

# Suppress Play Store deferred component warnings
-dontwarn com.google.android.play.core.**

