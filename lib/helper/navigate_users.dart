// navigate users according to their labels

import 'package:appwrite/models.dart';
import 'package:csms/presentation/router/router.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

void naviagateUsers(BuildContext context, User session) {
  if (session.labels.contains('admin')) {
    AppRouter.router.navigateTo(
      context,
      '/admin',
      transition: TransitionType.fadeIn,
      replace: true,
    );
  } else if (session.labels.contains('print-shop]')) {
    AppRouter.router.navigateTo(
      context,
      '/print-shop',
      transition: TransitionType.fadeIn,
      replace: true,
    );
  } else {
    AppRouter.router.navigateTo(
      context,
      '/dashboard',
      transition: TransitionType.fadeIn,
      replace: true,
    );
  }
}
