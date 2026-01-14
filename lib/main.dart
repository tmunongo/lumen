import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen/presentation/screens/home_screen.dart';
import 'package:lumen/presentation/utils/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppWindowManager.initialize();

  runApp(const ProviderScope(child: LumenApp()));
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumen Space',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B7FD7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B7FD7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
