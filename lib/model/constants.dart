/// Global constants and shared resources for the Minimal Jellyfin application.
/// 
/// This file contains application-wide constants and shared resources that need
/// to be accessible throughout the application lifecycle. Currently manages
/// the WebView2 environment configuration for consistent web content rendering.

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Global constants class containing shared application resources.
/// 
/// This class uses the 'K' naming convention (short for Constants) and provides
/// static access to resources that need to be shared across the application.
class K {
  /// The WebView2 environment instance used for all WebView operations.
  /// 
  /// This environment is initialized during application startup in main.dart
  /// and provides a consistent WebView2 runtime configuration with custom
  /// user data folder for the application. It ensures all WebView instances
  /// share the same runtime environment and settings.
  /// 
  /// Set to null initially and populated during app initialization.
  static WebViewEnvironment? webViewEnvironment;
}
