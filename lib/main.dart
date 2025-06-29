// Main entry point for the Minimal Fin desktop application.
//
// This file handles the application initialization including:
// - Hive database setup for settings storage
// - WebView2 environment configuration for Windows
// - Window manager setup for frameless window functionality
// - Application theme and routing configuration
//
// The application creates a minimal, frameless desktop client for Jellyfin
// media servers with enhanced desktop integration.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'model/constants.dart';
import 'model/settings_storage.dart';
import 'view/routing/app_routes.dart';

/// Application entry point that initializes all required services and configurations.
///
/// This function performs the following initialization steps:
/// 1. Sets up Flutter widget binding
/// 2. Initializes Hive database for settings storage
/// 3. Configures WebView2 environment for web content rendering
/// 4. Sets up window manager for frameless window functionality
/// 5. Launches the main application widget
///
/// Throws an assertion error if WebView2 Runtime is not available.
Future main() async {
  // Ensure Flutter framework is properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database for persistent settings storage
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  Hive.init('${appDocumentsDir.path}/MinimalFin');
  await SettingsStorage.init();

  // Verify WebView2 Runtime availability (required for web content rendering)
  final availableVersion = await WebViewEnvironment.getAvailableVersion();
  assert(
    availableVersion != null,
    'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.',
  );

  // Create application data directory if it doesn't exist
  final Directory minimalFinDir = Directory(
    '${appDocumentsDir.path}/MinimalFin',
  );
  if (!await minimalFinDir.exists()) {
    await minimalFinDir.create(recursive: true);
  }

  // Initialize WebView2 environment with custom user data folder
  K.webViewEnvironment = await WebViewEnvironment.create(
    settings: WebViewEnvironmentSettings(userDataFolder: minimalFinDir.path),
  );

  // Initialize window manager for custom window controls
  await windowManager.ensureInitialized();

  // Configure window options for frameless, transparent window
  WindowOptions windowOptions = WindowOptions(
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  // Set up window display behavior
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAsFrameless();
  });

  // Launch the main application
  runApp(const MyApp());
}

/// Root application widget that configures the app's theme, routing, and title.
///
/// This widget serves as the main entry point for the Flutter application and
/// sets up the Material Design theme with dark mode and Material 3 design system.
/// It uses Go Router for declarative navigation between screens.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the root widget tree for the application.
  ///
  /// Returns a [MaterialApp.router] configured with:
  /// - Dark theme using Material 3 design system
  /// - Go Router configuration for navigation
  /// - Application title "Minimal Fin"
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Minimal Fin',
      theme: ThemeData.dark(useMaterial3: true),
      routerConfig: AppRoutes.router,
    );
  }
}
