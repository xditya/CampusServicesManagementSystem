import 'package:appwrite/models.dart';
import 'package:csms/presentation/widgets/bottom_navbar.dart';
import 'package:csms/presentation/widgets/bottom_navbar_admin.dart';
import 'package:flutter/material.dart';

Widget chooseNavBar(User session) {
  return session.labels.contains("admin")
      ? const BottomNavBarAdmin()
      : const BottomNavBar();
}
