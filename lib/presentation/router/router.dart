import 'package:csms/presentation/screens/admins/slips/threed_print_requests_admin.dart';
import 'package:csms/presentation/screens/admins/slips/gate_pass_admin.dart';
import 'package:csms/presentation/screens/admins/slips/lab_permission_admin.dart';
import 'package:csms/presentation/screens/admins/slips/leave_forms_admin.dart';
import 'package:csms/presentation/screens/admins/slips/lost_id_admin.dart';
import 'package:csms/presentation/screens/admins/slips/pink_slips_admin.dart';
import 'package:csms/presentation/screens/admins/slips/slips_dashboard.dart';
import 'package:csms/presentation/screens/admins/slips/vehicle_pass_admin.dart';
import 'package:csms/presentation/screens/students/threed_printing.dart';
import 'package:csms/presentation/screens/students/add_balance.dart';
import 'package:csms/presentation/screens/students/dashboard.dart';
import 'package:csms/presentation/screens/common/error.dart';
import 'package:csms/presentation/screens/common/landing.dart';
import 'package:csms/presentation/screens/common/login.dart';
import 'package:csms/presentation/screens/students/gate_pass.dart';
import 'package:csms/presentation/screens/students/lab_permission.dart';
import 'package:csms/presentation/screens/students/leave_form.dart';
import 'package:csms/presentation/screens/students/lost_id.dart';
import 'package:csms/presentation/screens/students/my_orders.dart';
import 'package:csms/presentation/screens/students/my_prints.dart';
import 'package:csms/presentation/screens/students/pink_slips.dart';
import 'package:csms/presentation/screens/students/print_shop.dart';
import 'package:csms/presentation/screens/admins/printer/printer_orders.dart';
import 'package:csms/presentation/screens/common/profile.dart';
import 'package:csms/presentation/screens/common/settings.dart';
import 'package:csms/presentation/screens/admins/vending/vending_dashboard.dart';
import 'package:csms/presentation/screens/admins/vending/vending_orders.dart';
import 'package:csms/presentation/screens/students/vehicle_pass.dart';
import 'package:csms/presentation/screens/students/vending_machine.dart';
import 'package:csms/presentation/screens/students/wallet.dart';
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
        return const SlipsDashboardScreen();
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

    router.define(
      '/gate-pass',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const GatePassPage();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/3d-printing',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const ThreeDPrintingPage();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/vehicle-pass',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const VehiclePassPage();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/lab-permission',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const LabPermissionPage();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/leave-form',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const LeaveFormPage();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/lost-id-card',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const LostIdPage();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/admin/gate-passes',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const GatePassAdmin();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/admin/pink-slips',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const PinkSlipsAdmin();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/admin/lab-permissions',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const LabPermissionAdmin();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/admin/leave-forms',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const LeaveFormsAdmin();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/admin/id-requests',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const LostIdAdmin();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/admin/3d-printing',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const PrintRequestsAdmin();
        },
      ),
      transitionType: TransitionType.fadeIn,
    );

    router.define(
      '/admin/vehicle-passes',
      handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const VehiclePassAdmin();
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
