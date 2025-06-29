/// Main web view screen that displays the Jellyfin web interface with custom enhancements.
/// 
/// This file contains the primary screen for displaying Jellyfin's web interface
/// within a WebView component. It includes sophisticated JavaScript injection
/// capabilities to customize the web interface behavior, particularly for
/// fullscreen functionality and desktop integration.
/// 
/// Key features:
/// - WebView2 integration for optimal web content rendering
/// - JavaScript injection for customizing Jellyfin's web interface
/// - Custom fullscreen handling that integrates with window management
/// - Dynamic button behavior modification using MutationObserver
/// - Progress indication during page loading
/// - URL validation and navigation handling
/// 
/// The implementation uses advanced web technologies to provide a seamless
/// desktop experience while maintaining compatibility with Jellyfin's web interface.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:minimal_jellyfin/view/widgets/page_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../model/constants.dart';
import '../../model/settings_storage.dart';

/// Helper class for modifying webpage button behavior through JavaScript injection.
/// 
/// This class provides methods to override the default behavior of buttons in
/// the Jellyfin web interface, particularly for fullscreen functionality.
/// It uses JavaScript injection and MutationObserver to dynamically detect
/// and modify button behavior even when buttons are added dynamically to the DOM.
/// 
/// The class is designed to work with Jellyfin's web interface structure and
/// can be extended to modify other UI elements as needed.
class WebViewButtonModifications {
  /// The WebView controller used for JavaScript injection and DOM manipulation.
  /// 
  /// This controller provides access to the WebView's JavaScript execution
  /// context, allowing the modification of webpage behavior and DOM elements.
  final InAppWebViewController? webViewController;

  /// Creates a new instance with the specified WebView controller.
  /// 
  /// Parameters:
  ///   [webViewController] - The WebView controller for JavaScript execution
  WebViewButtonModifications(this.webViewController);

  /// Overrides button click behavior for buttons matching multiple CSS classes.
  /// 
  /// This method finds buttons that have all the specified CSS classes and
  /// replaces their click behavior with a custom handler that communicates
  /// back to the Flutter application.
  /// 
  /// Parameters:
  ///   [classNames] - List of CSS class names that the button must have
  ///   [buttonId] - Identifier passed back to Flutter when button is clicked
  /// 
  /// The method removes existing event listeners and adds a new click handler
  /// that prevents default behavior and calls back to Flutter via the
  /// 'buttonClicked' JavaScript handler.
  Future<void> overrideButtonClickByClasses(
    List<String> classNames,
    String buttonId,
  ) async {
    if (webViewController != null) {
      String classSelector = classNames
          .map((className) => '.$className')
          .join('');
      await webViewController!.evaluateJavascript(
        source: '''
        var buttons = document.querySelectorAll('$classSelector');
        for (var i = 0; i < buttons.length; i++) {
          var button = buttons[i];
          // Remove existing event listeners
          button.onclick = null;

          // Add new click behavior
          button.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();

            // Call back to Flutter
            window.flutter_inappwebview.callHandler('buttonClicked', '$buttonId');
          });
        }
      ''',
      );
    }
  }

  /// Sets up a MutationObserver to watch for dynamically added buttons.
  /// 
  /// This method creates a JavaScript MutationObserver that monitors the DOM
  /// for changes and automatically applies button behavior overrides to newly
  /// added elements. This is essential for Jellyfin's dynamic interface where
  /// buttons may be added after the initial page load.
  /// 
  /// The observer:
  /// 1. Checks for existing buttons matching the criteria
  /// 2. Sets up monitoring for new DOM nodes
  /// 3. Automatically applies overrides to matching buttons
  /// 4. Continues monitoring throughout the page lifecycle
  /// 
  /// Parameters:
  ///   [classNames] - List of CSS class names to match
  ///   [buttonId] - Identifier for the button type (used in callbacks)
  /// 
  /// This method is particularly important for Jellyfin's fullscreen button
  /// which may be added dynamically during video playback.
  Future<void> setupDynamicButtonObserver(
    List<String> classNames,
    String buttonId,
  ) async {
    if (webViewController != null) {
      String classSelector = classNames
          .map((className) => '.$className')
          .join('');
      await webViewController!.evaluateJavascript(
        source: '''
        // Function to override button behavior
        function overrideButton(button) {
          // Remove existing event listeners
          button.onclick = null;

          // Add new click behavior
          button.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();

            // Call back to Flutter
            window.flutter_inappwebview.callHandler('buttonClicked', '$buttonId');
          });

          console.log('Fullscreen button behavior overridden');
        }

        // Check if button already exists
        var existingButtons = document.querySelectorAll('$classSelector');
        for (var i = 0; i < existingButtons.length; i++) {
          overrideButton(existingButtons[i]);
        }

        // Create observer to watch for new buttons
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
              if (node.nodeType === 1) { // Element node
                // Check if the added node matches our selector
                if (node.matches && node.matches('$classSelector')) {
                  overrideButton(node);
                }

                // Check for matching buttons within the added node
                if (node.querySelectorAll) {
                  var buttons = node.querySelectorAll('$classSelector');
                  for (var i = 0; i < buttons.length; i++) {
                    overrideButton(buttons[i]);
                  }
                }
              }
            });
          });
        });

        // Start observing
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });

        console.log('Dynamic button observer set up for fullscreen button');
      ''',
      );
    }
  }
}

/// Main screen widget that displays the Jellyfin web interface in a WebView.
/// 
/// This widget creates a full-screen WebView that loads and displays the
/// Jellyfin server's web interface. It includes sophisticated customizations
/// to enhance the desktop experience, including:
/// 
/// - Custom fullscreen handling that integrates with window management
/// - JavaScript injection for modifying web interface behavior
/// - Progress indication during page loading
/// - Automatic URL loading from saved settings
/// - Permission handling for media playback
/// - External URL handling for non-web content
/// 
/// The widget uses PageWrapper to provide consistent window controls and
/// layout across the application.
class WebViewPage extends StatefulWidget {
  /// Creates a new WebView page instance.
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

/// State class for WebViewPage managing WebView lifecycle and interactions.
/// 
/// This state class handles all aspects of the WebView functionality including:
/// - WebView controller management and initialization
/// - JavaScript injection for custom button behavior
/// - URL loading and navigation
/// - Progress tracking and display
/// - Settings change handling and URL updates
/// - Custom button click handling (particularly fullscreen)
/// 
/// The class maintains the WebView state and provides methods for interacting
/// with the Jellyfin web interface through JavaScript injection.
class _WebViewPageState extends State<WebViewPage> {
  /// Controller for the WebView instance, providing access to WebView operations.
  InAppWebViewController? webViewController;

  /// Helper class for modifying webpage button behavior through JavaScript.
  WebViewButtonModifications? buttonModifier;

  /// WebView configuration settings optimized for media playback and debugging.
  /// 
  /// These settings enable:
  /// - Inspector access in debug mode for development
  /// - Automatic media playback without user gesture requirement
  /// - Inline media playback support
  /// - Fullscreen iframe support for video content
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
  );

  /// Current page loading progress (0.0 to 1.0).
  /// 
  /// Used to display a progress indicator while pages are loading.
  /// Updated through the onProgressChanged callback.
  double progress = 0;

  /// The currently configured Jellyfin server URL.
  /// 
  /// Loaded from settings storage and used to navigate the WebView
  /// to the appropriate Jellyfin server instance.
  String? serverUrl;

  /// Initializes the widget state and loads the saved server URL.
  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  /// Loads the saved server URL from settings storage.
  /// 
  /// This method retrieves the previously saved Jellyfin server URL
  /// from persistent storage and updates the widget state. If no URL
  /// is saved, the serverUrl remains null.
  void _loadServerUrl() {
    final savedUrl = SettingsStorage.getServerUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        serverUrl = savedUrl;
      });
    }
  }

  /// Loads the configured server URL in the WebView.
  /// 
  /// This method navigates the WebView to the saved server URL, but only
  /// if both the WebView controller is initialized and a valid server URL
  /// is available. This is typically called after the WebView is created.
  void _loadUrlInWebView() {
    if (webViewController != null &&
        serverUrl != null &&
        serverUrl!.isNotEmpty) {
      webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(serverUrl!)),
      );
    }
  }

  /// Handles settings changes by reloading the WebView with the new URL.
  /// 
  /// This callback is triggered when the user returns from the settings page.
  /// It checks if the server URL has changed and, if so, updates the local
  /// state and navigates the WebView to the new URL.
  /// 
  /// This ensures the WebView immediately reflects any server URL changes
  /// without requiring an application restart.
  void _onSettingsChanged() {
    final newUrl = SettingsStorage.getServerUrl();
    if (newUrl != null && newUrl.isNotEmpty && newUrl != serverUrl) {
      setState(() {
        serverUrl = newUrl;
      });
      // Navigate to the new URL immediately
      if (webViewController != null) {
        webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(newUrl)));
      }
    }
  }

  /// Handles custom button clicks from the Jellyfin web interface.
  /// 
  /// This method processes button click events that have been intercepted
  /// by JavaScript injection. Currently handles the fullscreen button by
  /// toggling the window's maximized state instead of using web fullscreen.
  /// 
  /// Parameters:
  ///   [buttonId] - Identifier of the clicked button (e.g., 'fullscreenButton')
  /// 
  /// This provides better desktop integration by using native window
  /// management instead of browser-style fullscreen.
  void _handleCustomButtonClick(String buttonId) async {
    if (buttonId == 'fullscreenButton') {
      // Toggle window maximization instead of web fullscreen
      if (await windowManager.isMaximized()) {
        windowManager.unmaximize();
      } else {
        windowManager.maximize();
      }
    }
  }

  /// Applies JavaScript modifications to the loaded webpage.
  /// 
  /// This method sets up the JavaScript injection system that modifies
  /// the behavior of buttons in the Jellyfin web interface. It waits for
  /// the page to fully render before applying modifications.
  /// 
  /// Currently focuses on the fullscreen button, but can be extended
  /// to modify other UI elements as needed. The modifications persist
  /// even when new content is dynamically added to the page.
  Future<void> _applyButtonModifications() async {
    if (buttonModifier == null) return;

    // Allow time for the page to fully render and stabilize
    await Future.delayed(Duration(milliseconds: 1000));

    // Set up dynamic monitoring for fullscreen button
    await buttonModifier!.setupDynamicButtonObserver([
      'btnFullscreen',
    ], 'fullscreenButton');
  }

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      onSettingsChanged: _onSettingsChanged,
      child: Scaffold(
        body: Stack(
          children: [
            InAppWebView(
              webViewEnvironment: K.webViewEnvironment,
              initialUrlRequest: URLRequest(
                url: WebUri(serverUrl ?? 'about:blank'),
              ),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
                buttonModifier = WebViewButtonModifications(controller);

                // Add JavaScript handler for button callbacks
                controller.addJavaScriptHandler(
                  handlerName: 'buttonClicked',
                  callback: (args) {
                    _handleCustomButtonClick(args[0]);
                  },
                );

                // Load saved URL if available
                _loadUrlInWebView();
              },
              onLoadStop: (controller, url) async {
                // Apply button modifications after page loads
                await _applyButtonModifications();
              },
              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;

                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about",
                ].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    // Launch the App
                    await launchUrl(uri);
                    // and cancel the request
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                return NavigationActionPolicy.ALLOW;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100;
                });
              },
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
          ],
        ),
      ),
    );
  }
}
