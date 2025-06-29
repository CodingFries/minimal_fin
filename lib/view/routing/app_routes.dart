// Application routing configuration using Go Router for declarative navigation.
//
// This file defines the navigation structure for the Minimal Fin application.
// It implements a simple routing system with automatic redirection based on
// application state (whether a server URL is configured).
//
// The routing logic ensures users are guided through the proper setup flow:
// 1. If no server URL is configured, redirect to settings
// 2. If server URL exists, go directly to the web view
//
// Routes:
// - `/` (root) - Automatic redirection based on configuration
// - `/settings` - Server configuration page
// - `/webview` - Main Jellyfin web interface

import 'package:go_router/go_router.dart';

import '../../model/settings_storage.dart';
import '../screens/settings_page.dart';
import '../screens/web_view_page.dart';

/// Centralized routing configuration for the application.
///
/// This class manages all application routes and navigation logic using Go Router.
/// It provides a declarative approach to navigation with automatic redirection
/// based on application state.
///
/// The routing system implements a setup flow where users are automatically
/// directed to the settings page if no server URL is configured, ensuring
/// a smooth first-time user experience.
class AppRoutes {
  /// Route path for the settings/configuration page.
  ///
  /// This route displays the settings page where users can configure
  /// their Jellyfin server URL and other application preferences.
  static const String settings = '/settings';

  /// Route path for the main web view page.
  ///
  /// This route displays the Jellyfin web interface in a WebView component.
  /// Users are automatically redirected here after configuring a server URL.
  static const String webView = '/webview';

  /// Initial/root route path.
  ///
  /// This route implements automatic redirection logic based on whether
  /// a server URL has been configured. It serves as the entry point for
  /// the application's navigation flow.
  static const String initial = '/';

  /// The main router configuration for the application.
  ///
  /// This GoRouter instance defines all application routes and their behavior.
  /// It includes automatic redirection logic on the root route to guide users
  /// through the proper setup flow.
  ///
  /// Route behavior:
  /// - Root (`/`) - Redirects to settings if no server URL, otherwise to webview
  /// - Settings (`/settings`) - Shows the server configuration page
  /// - WebView (`/webview`) - Shows the main Jellyfin interface
  static GoRouter router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: initial,
        redirect: (context, state) {
          // Check if server URL is configured to determine redirect destination
          final serverUrl = SettingsStorage.getServerUrl();
          if (serverUrl == null || serverUrl.isEmpty) {
            // No server configured - redirect to settings for initial setup
            return settings;
          } else {
            // Server configured - go directly to the web interface
            return webView;
          }
        },
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(path: webView, builder: (context, state) => const WebViewPage()),
    ],
  );
}
