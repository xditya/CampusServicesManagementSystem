import 'package:csms/presentation/router/router.dart';
import 'package:csms/presentation/screens/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:csms/presentation/providers/theme_provider.dart';
import 'package:csms/helper/database/db_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DBService().connect();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.router.generator,
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (context) => const ErrorScreen()),
      ),
    );
  }
}
