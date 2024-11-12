import 'package:csms/helper/config.dart';
import 'package:csms/presentation/screens/dashboard.dart';
import 'package:csms/presentation/screens/error.dart';
import 'package:csms/presentation/screens/login.dart';
import 'package:csms/presentation/screens/profile.dart';
import 'package:csms/presentation/screens/settings.dart';
import 'package:csms/presentation/screens/wallet.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

class AppRouter {
  static final router = FluroRouter();

  static void defineRoutes() {
    router.define(
      '/',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const LoginScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/dashboard',
      handler: Handler(
          handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return const DashboardScreen();
      }),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/wallet',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const WalletScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/profile',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const ProfileScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/settings',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const SettingsScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );
    router.notFoundHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return const ErrorScreen();
      },
    );
  }
}
