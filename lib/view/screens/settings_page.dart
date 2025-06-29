/// Settings configuration screen for the Minimal Jellyfin application.
/// 
/// This file contains the settings page where users can configure their
/// Jellyfin server connection details. The page provides:
/// 
/// - Server URL input with real-time validation
/// - User-friendly error messages for invalid URLs
/// - Secure URL validation (HTTP/HTTPS only)
/// - Persistent storage of configuration
/// - Automatic navigation after successful configuration
/// - Loading states and user feedback
/// 
/// The settings page is typically the first screen users see when launching
/// the application for the first time, or when they need to change their
/// server configuration. It ensures users can only proceed with valid
/// server URLs and provides clear feedback throughout the process.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minimal_jellyfin/view/widgets/page_wrapper.dart';
import 'package:validators/validators.dart';

import '../../model/settings_storage.dart';
import '../routing/app_routes.dart';

/// Settings page widget for configuring Jellyfin server connection.
/// 
/// This widget provides a user interface for entering and validating
/// the Jellyfin server URL. It includes comprehensive validation,
/// error handling, and automatic navigation upon successful configuration.
/// 
/// The page is designed to be user-friendly with clear instructions,
/// validation feedback, and loading states to guide users through
/// the server setup process.
class SettingsPage extends StatefulWidget {
  /// Creates a new settings page instance.
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// State class for SettingsPage managing form input and validation.
/// 
/// This state class handles all aspects of the settings form including:
/// - Text input management for the server URL
/// - URL validation with comprehensive error checking
/// - Loading states during save operations
/// - Navigation after successful configuration
/// - User feedback through snackbars and visual indicators
/// 
/// The class ensures a smooth user experience with proper validation,
/// error handling, and clear feedback throughout the configuration process.
class _SettingsPageState extends State<SettingsPage> {
  /// Text controller for the server URL input field.
  /// 
  /// Manages the text input state and provides access to the current
  /// URL value entered by the user. Initialized with any existing
  /// saved URL during widget initialization.
  final TextEditingController _urlController = TextEditingController();

  /// Tracks whether a save operation is currently in progress.
  /// 
  /// Used to show loading indicators and prevent multiple simultaneous
  /// save operations. Set to true during async save operations.
  bool _isLoading = false;

  /// Initializes the widget state and loads any existing server URL.
  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  /// Loads the currently saved server URL into the input field.
  /// 
  /// This method retrieves any previously saved server URL from storage
  /// and populates the text field with it. If no URL is saved, the field
  /// remains empty, allowing the user to enter a new URL.
  void _loadCurrentUrl() {
    final currentUrl = SettingsStorage.getServerUrl();
    if (currentUrl != null) {
      _urlController.text = currentUrl;
    }
    // Field remains empty if no URL is saved
  }

  /// Validates whether the provided URL is acceptable for Jellyfin connection.
  /// 
  /// This method performs comprehensive URL validation including:
  /// - Checking for empty/whitespace-only input
  /// - Validating URL format using the validators package
  /// - Requiring HTTP or HTTPS protocol for security
  /// 
  /// Parameters:
  ///   [url] - The URL string to validate
  /// 
  /// Returns:
  ///   true if the URL is valid and safe to use, false otherwise
  bool _isValidUrl(String url) {
    if (url.trim().isEmpty) {
      return false;
    }

    // Use validators package for comprehensive URL validation
    // Require protocol to ensure complete URLs (http:// or https://)
    return isURL(url.trim(), requireProtocol: true);
  }

  /// Generates appropriate error messages for invalid URLs.
  /// 
  /// This method provides user-friendly error messages based on the
  /// specific validation failure, helping users understand what needs
  /// to be corrected in their input.
  /// 
  /// Parameters:
  ///   [url] - The URL that failed validation
  /// 
  /// Returns:
  ///   A descriptive error message explaining the validation failure
  String _getValidationErrorMessage(String url) {
    if (url.trim().isEmpty) {
      return 'Please enter a server URL';
    }

    if (!url.toLowerCase().startsWith('http://') &&
        !url.toLowerCase().startsWith('https://')) {
      return 'URL must start with http:// or https://';
    }

    return 'Please enter a valid URL';
  }

  /// Saves the entered server URL after validation and handles navigation.
  /// 
  /// This method performs the complete save operation including:
  /// 1. URL validation with user feedback for errors
  /// 2. Loading state management during async operations
  /// 3. Persistent storage of the validated URL
  /// 4. Success feedback to the user
  /// 5. Automatic navigation to the web view
  /// 6. Comprehensive error handling with user feedback
  /// 
  /// The method ensures the user experience is smooth with proper loading
  /// indicators, clear feedback, and appropriate navigation behavior based
  /// on the current navigation state.
  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();

    // Validate URL before attempting to save
    if (!_isValidUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getValidationErrorMessage(url),
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red.withAlpha(204),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Show loading state during save operation
    setState(() {
      _isLoading = true;
    });

    try {
      // Save the validated URL to persistent storage
      await SettingsStorage.setServerUrl(url);

      // Provide success feedback and navigate (only if widget is still mounted)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Server URL saved successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green.withAlpha(204),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Navigate to WebView after brief delay to show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            if (context.canPop()) {
              // Return to previous screen (likely WebView)
              context.pop();
            } else {
              // First-time setup - navigate directly to WebView
              context.go(AppRoutes.webView);
            }
          }
        });
      }
    } catch (e) {
      // Handle save errors with user feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving URL: $e',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.withAlpha(204),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.black.withAlpha(204),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withAlpha(26),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.language,
                          color: Colors.white.withAlpha(204),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Server Configuration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Server URL',
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _urlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your Jellyfin server URL',
                        hintStyle: TextStyle(
                          color: Colors.white.withAlpha(128),
                        ),
                        filled: true,
                        fillColor: Colors.black.withAlpha(77),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(51),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(51),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue.withAlpha(153),
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.link,
                          color: Colors.white.withAlpha(153),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Example: https://your-jellyfin-server.com/',
                      style: TextStyle(
                        color: Colors.white.withAlpha(153),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUrl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withAlpha(204),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Save Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withAlpha(26),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: Colors.white.withAlpha(179),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Use HTTPS URLs for secure connections to your Jellyfin server.',
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
