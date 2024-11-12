// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:appwrite/enums.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/presentation/router/router.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: account
            .getSession(sessionId: 'current')
            .then((session) => true)
            .catchError((error) => false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            if (snapshot.data as bool) {
              // Schedule navigation after the current frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppRouter.router.navigateTo(
                  context,
                  '/dashboard',
                  transition: TransitionType.fadeIn,
                  replace: true,
                );
              });
            }
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await account.createOAuth2Session(
                        provider: OAuthProvider.google,
                        scopes: [
                          'email',
                          'profile',
                          'https://www.googleapis.com/auth/userinfo.profile',
                          'https://www.googleapis.com/auth/userinfo.email',
                          'https://www.googleapis.com/auth/plus.me',
                          'openid'
                        ],
                      );

                      // After successful login, verify the session: #TODO
                      try {
                        await account.getSession(sessionId: 'current');
                        // print('Login successful - User ID: ${session.userId}');

                        // Navigate to dashboard
                        AppRouter.router.navigateTo(
                          context,
                          '/dashboard',
                          transition: TransitionType.fadeIn,
                          replace: true,
                        );
                      } catch (sessionError) {
                        // print('Session error: $sessionError');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content:
                              Text('Failed to get session. Please try again.'),
                          duration: Duration(seconds: 3),
                        ));
                      }
                    } catch (e) {
                      if (e is PlatformException && e.code == 'CANCELED') {
                        // print('Login was canceled by the user.');
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Login was cancelled'),
                          duration: Duration(seconds: 3),
                        ));
                      } else {
                        // print('Login error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Login error: ${e.toString()}'),
                          duration: const Duration(seconds: 3),
                        ));
                      }
                    }
                  },
                  child: const Text('Sign in with Google'),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
