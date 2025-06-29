import 'package:go_router/go_router.dart';

import '../../model/settings_storage.dart';
import '../screens/settings_page.dart';
import '../screens/web_view_page.dart';

class AppRoutes {
  static const String settings = '/settings';
  static const String webView = '/webview';

  static const String initial = '/';

  static GoRouter router = GoRouter(
    initialLocation: initial,
    routes: [
      GoRoute(
        path: initial,
        redirect: (context, state) {
          // Redirect to settings if server URL is not set
          final serverUrl = SettingsStorage.getServerUrl();
          if (serverUrl == null || serverUrl.isEmpty) {
            return settings;
          } else {
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
