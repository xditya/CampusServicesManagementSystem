import 'package:csms/presentation/screens/add_balance.dart';
import 'package:csms/presentation/screens/admin.dart';
import 'package:csms/presentation/screens/dashboard.dart';
import 'package:csms/presentation/screens/error.dart';
import 'package:csms/presentation/screens/landing.dart';
import 'package:csms/presentation/screens/login.dart';
import 'package:csms/presentation/screens/my_orders.dart';
import 'package:csms/presentation/screens/my_prints.dart';
import 'package:csms/presentation/screens/pink_slips.dart';
import 'package:csms/presentation/screens/print_shop.dart';
import 'package:csms/presentation/screens/printer/printer_orders.dart';
import 'package:csms/presentation/screens/profile.dart';
import 'package:csms/presentation/screens/settings.dart';
import 'package:csms/presentation/screens/vending/vending_dashboard.dart';
import 'package:csms/presentation/screens/vending/vending_orders.dart';
import 'package:csms/presentation/screens/vending_machine.dart';
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
          return const LandingScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/login',
      handler: Handler(
          handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return const LoginScreen();
      }),
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

    router.define(
      '/admin',
      handler: Handler(
          handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return const AdminScreen();
      }),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/print-shop',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const PrintShopScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/add-balance',
      handler: Handler(
          handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return const AddBalanceScreen();
      }),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/vending-machine',
      handler: Handler(
          handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
        return const VendingMachineScreen();
      }),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/my-orders',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const MyOrdersScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/vending-dashboard',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const VendingDashboard();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/vending-orders',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const VendingOrders();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/my-prints',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const MyPrintsScreen();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/printer-orders',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const PrinterOrders();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/pink-slip',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const PinkSlipsPage();
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
