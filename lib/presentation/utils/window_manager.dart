import 'dart:ui';

import 'package:window_manager/window_manager.dart';

class AppWindowManager {
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();

    await windowManager.setTitle('Lumen Space');
    await windowManager.setMinimumSize(const Size(1000, 600));
    await windowManager.setSize(const Size(1400, 900));
    await windowManager.center();
  }

  static Future<void> setTitle(String title) async {
    await windowManager.setTitle('$title - Lumen Space');
  }

  static Future<void> resetTitle() async {
    await windowManager.setTitle('Lumen Space');
  }
}
