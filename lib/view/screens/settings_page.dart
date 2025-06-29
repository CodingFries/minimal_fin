import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minimal_jellyfin/view/widgets/page_wrapper.dart';
import 'package:validators/validators.dart';

import '../../model/settings_storage.dart';
import '../routing/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  void _loadCurrentUrl() {
    final currentUrl = SettingsStorage.getServerUrl();
    if (currentUrl != null) {
      _urlController.text = currentUrl;
    }
    // Leave empty if no URL is saved
  }

  bool _isValidUrl(String url) {
    if (url.trim().isEmpty) {
      return false;
    }

    // Use validators package for safe URL validation
    // Only allow HTTP and HTTPS protocols for security
    return isURL(url.trim(), requireProtocol: true);
  }

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

  Future<void> _saveUrl() async {
    final url = _urlController.text.trim();

    // Validate URL before saving
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

    setState(() {
      _isLoading = true;
    });

    try {
      await SettingsStorage.setServerUrl(url);
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

        // Navigate to WebView page after successful save
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            if (context.canPop()) {
              context.pop();
            } else {
              // If we can't pop, it means we are at the initial route
              // So we navigate to the WebView page directly
              context.go(AppRoutes.webView);
            }
          }
        });
      }
    } catch (e) {
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
