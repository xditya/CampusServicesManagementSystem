import 'package:appwrite/models.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:csms/presentation/widgets/bottom_navbar_vending.dart';
import 'package:flutter/material.dart';

Widget chooseNavBar(User session) {
  if (session.labels.contains("admin")) {
    return const BottomNavBarAdmin();
  } else if (session.labels.contains("vending")) {
    return const BottomNavBarVending();
  }
  return const BottomNavBar();
}
