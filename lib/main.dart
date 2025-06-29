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

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  Hive.init('${appDocumentsDir.path}/MinimalFin');
  await SettingsStorage.init();

  final availableVersion = await WebViewEnvironment.getAvailableVersion();
  assert(
    availableVersion != null,
    'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.',
  );

  final Directory minimalFinDir = Directory(
    '${appDocumentsDir.path}/MinimalFin',
  );
  if (!await minimalFinDir.exists()) {
    await minimalFinDir.create(recursive: true);
  }

  K.webViewEnvironment = await WebViewEnvironment.create(
    settings: WebViewEnvironmentSettings(userDataFolder: minimalFinDir.path),
  );

  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAsFrameless();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Minimal Fin',
      theme: ThemeData.dark(useMaterial3: true),
      routerConfig: AppRoutes.router,
    );
  }
}
