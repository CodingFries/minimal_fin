// Settings storage management using Hive database for persistent data.
// 
// This file provides a simple interface for storing and retrieving application
// settings using the Hive NoSQL database. Currently manages the Jellyfin server
// URL configuration, with the ability to easily extend for additional settings.
// 
// The storage is initialized during application startup and persists data
// between application sessions.

import 'package:hive_ce/hive.dart';

/// Manages persistent storage of application settings using Hive database.
/// 
/// This class provides static methods for storing and retrieving application
/// configuration data. It uses Hive for lightweight, fast local storage that
/// persists between application sessions.
/// 
/// Currently supports:
/// - Server URL storage for Jellyfin connection configuration
/// 
/// Usage:
/// ```dart
/// await SettingsStorage.init(); // Initialize during app startup
/// await SettingsStorage.setServerUrl('http://jellyfin.example.com:8096');
/// String? url = SettingsStorage.getServerUrl();
/// ```
class SettingsStorage {
  /// The Hive box instance used for storing settings data.
  /// 
  /// This box is initialized during [init()] and provides access to the
  /// persistent storage. It's marked as late final since it's guaranteed
  /// to be initialized before any other methods are called.
  static late final Box box;

  /// Storage key for the Jellyfin server URL setting.
  /// 
  /// This constant defines the key used to store and retrieve the server URL
  /// in the Hive database. Using a constant ensures consistency and helps
  /// prevent typos in key names.
  static const String keyServerUrl = 'serverUrl';

  /// Initializes the settings storage by opening the Hive box.
  /// 
  /// This method must be called during application startup before any other
  /// settings operations. It opens the 'settings' box in the Hive database
  /// and makes it available for read/write operations.
  /// 
  /// Throws [HiveError] if the box cannot be opened.
  static Future<void> init() async {
    box = await Hive.openBox('settings');
  }

  /// Retrieves the stored Jellyfin server URL.
  /// 
  /// Returns the previously saved server URL, or null if no URL has been
  /// configured. The URL should include the protocol (http:// or https://)
  /// and port number if non-standard.
  /// 
  /// Returns:
  ///   The stored server URL string, or null if not set.
  static String? getServerUrl() {
    return box.get(keyServerUrl);
  }

  /// Stores the Jellyfin server URL for future use.
  /// 
  /// Saves the provided server URL to persistent storage. The URL should be
  /// a valid HTTP/HTTPS URL pointing to a Jellyfin server instance.
  /// 
  /// Parameters:
  ///   [url] - The server URL to store (e.g., 'http://192.168.1.100:8096')
  /// 
  /// Throws [HiveError] if the data cannot be written to storage.
  static Future<void> setServerUrl(String url) async {
    await box.put(keyServerUrl, url);
  }
}
