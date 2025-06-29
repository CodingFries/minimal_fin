import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:minimal_jellyfin/view/widgets/page_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

import '../../model/constants.dart';
import '../../model/settings_storage.dart';

// Helper class for modifying webpage buttons
class WebViewButtonModifications {
  final InAppWebViewController? webViewController;

  WebViewButtonModifications(this.webViewController);

  // Override button click behavior for buttons with multiple CSS classes
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

  // Set up a MutationObserver to watch for dynamically added buttons
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

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? webViewController;
  WebViewButtonModifications? buttonModifier;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
  );

  double progress = 0;
  String? serverUrl;

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  void _loadServerUrl() {
    final savedUrl = SettingsStorage.getServerUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        serverUrl = savedUrl;
      });
    }
  }

  // Load URL in WebView after controller is ready
  void _loadUrlInWebView() {
    if (webViewController != null &&
        serverUrl != null &&
        serverUrl!.isNotEmpty) {
      webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri(serverUrl!)),
      );
    }
  }

  void _onSettingsChanged() {
    final newUrl = SettingsStorage.getServerUrl();
    if (newUrl != null && newUrl.isNotEmpty && newUrl != serverUrl) {
      setState(() {
        serverUrl = newUrl;
      });
      // Navigate to the new URL
      if (webViewController != null) {
        webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(newUrl)));
      }
    }
  }

  // Handle custom button clicks from the webpage
  void _handleCustomButtonClick(String buttonId) async {
    // Handle fullscreen button click
    if (buttonId == 'fullscreenButton') {
      if (await windowManager.isMaximized()) {
        windowManager.unmaximize();
      } else {
        windowManager.maximize();
      }
    }
  }

  // Apply button modifications to the loaded webpage
  Future<void> _applyButtonModifications() async {
    if (buttonModifier == null) return;

    // Wait a bit for the page to fully render
    await Future.delayed(Duration(milliseconds: 1000));

    // Set up observer to watch for dynamically added fullscreen button
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
