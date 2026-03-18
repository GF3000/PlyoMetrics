# Flutter & Dart core
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# Pigeon-generated platform channel classes (path_provider, camera, etc.)
-keep class dev.flutter.pigeon.** { *; }

# path_provider_android
-keep class io.flutter.plugins.pathprovider.** { *; }

# Isar database native libraries
-keep class dev.isar.** { *; }

# FFmpeg Kit
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.arthenica.mobileffmpeg.** { *; }

# Keep all classes annotated with @Keep
-keep @androidx.annotation.Keep class * { *; }

# Suppress warnings for missing references
-dontwarn io.flutter.**
-dontwarn dev.flutter.pigeon.**
