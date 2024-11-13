import 'package:csms/presentation/router/router.dart';
import 'package:csms/presentation/screens/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:csms/presentation/providers/theme_provider.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    AppRouter.defineRoutes();
  }

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      updateTheme: _updateThemeMode,
      child: MaterialApp(
        title: 'Campus Services Management System',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _themeMode,
        onGenerateRoute: AppRouter.router.generator,
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (context) => const ErrorScreen()),
      ),
    );
  }
}
