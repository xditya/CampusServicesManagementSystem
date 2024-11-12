import 'package:csms/presentation/router/router.dart';
import 'package:csms/presentation/screens/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  @override
  void initState() {
    super.initState();
    AppRouter.defineRoutes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Services Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: AppRouter.router.generator,
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const ErrorScreen()),
    );
  }
}
