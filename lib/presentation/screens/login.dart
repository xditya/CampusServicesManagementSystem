import 'dart:ui';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/navigate_users.dart';
import 'package:csms/helper/validate_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showEmailInput = false;
  bool _showOtpInput = false;
  bool _isCheckingSession = true;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  String? userId;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (mounted) setState(() {});
    });
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      await account.getSession(sessionId: 'current');
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });

        // Navigate to dashboard if session is valid
        if (mounted) {
          final session = await account.get();
          if (mounted) {
            naviagateUsers(context, session);
          }
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isCheckingSession = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
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

      try {
        await account.get();
        if (context.mounted) {
          final session = await account.get();
          if (context.mounted) {
            naviagateUsers(context, session);
          }
        }
      } catch (sessionError) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get session. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;

      if (e is PlatformException && e.code == 'CANCELED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login was cancelled'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleEmailSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_emailController.text.isEmpty) return;
      if (!validateEmail(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid MBCET email address'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      try {
        final sessionToken = await account.createEmailToken(
          userId: ID.unique(),
          email: _emailController.text,
        );
        userId = sessionToken.userId;

        if (mounted) {
          setState(() {
            _showOtpInput = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP has been sent to your email'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending OTP: ${e.toString()}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _handleOtpSubmit() async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length == 6) {
      if (userId == null) {
        const SnackBar(
          content: Text('User ID is missing. Please try again.'),
          duration: Duration(seconds: 3),
        );
        return;
      }
      try {
        // Verify the email OTP token
        await account.createSession(
          userId: userId!,
          secret: otp,
        );
        try {
          await account.get();
          if (mounted) {
            final session = await account.get();
            if (mounted) {
              naviagateUsers(context, session);
            }
          }
        } catch (sessionError) {
          if (context.mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to get session. Please try again.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid OTP. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildOtpInput() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Code',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the code sent to ${_emailController.text}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 45,
                      height: 55,
                      child: TextFormField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        decoration: InputDecoration(
                          counterText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                          fillColor: Colors.white.withOpacity(0.08),
                          filled: true,
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _otpFocusNodes[index + 1].requestFocus();
                          }
                          if (value.length == 1 && index == 5) {
                            _handleOtpSubmit();
                          }
                          if (value.isEmpty && index > 0) {
                            _otpFocusNodes[index - 1].requestFocus();
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showOtpInput = false;
                          for (var controller in _otpControllers) {
                            controller.clear();
                          }
                        });
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      label: Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _handleEmailSubmit,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      label: Text(
                        'Resend Code',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF2D2D2D),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A), // Dark gray
              Color(0xFF2D2D2D), // Slightly lighter gray
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with enhanced animation
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.easeOutBack,
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.asset(
                                    'assets/images/CSMS.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        // Title with animation
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Column(
                                  children: [
                                    Text(
                                      'CSMS',
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.95),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Campus Services Management System',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 48),

                        if (!_showOtpInput) ...[
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: ElevatedButton(
                              onPressed: () => _handleGoogleSignIn(context),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (_showOtpInput)
                          _buildOtpInput()
                        else if (!_showEmailInput) ...[
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () =>
                                setState(() => _showEmailInput = true),
                            child: Text(
                              'Sign in with Email',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 15,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white.withOpacity(0.4),
                                decorationThickness: 1,
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 24),
                          _buildEmailInput(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in with Email',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.red.shade300,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.red.shade400,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    suffixIcon: _emailController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            onPressed: () {
                              _emailController.clear();
                              _emailFocusNode.requestFocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _showEmailInput = false),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      label: Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _handleEmailSubmit,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension for adding neumorphic effect to widgets
extension NeumorphicEffect on Widget {
  Widget addNeumorphism({
    double borderRadius = 30.0,
    Offset offset = const Offset(0, 10),
    double blurRadius = 20,
    Color topShadowColor = Colors.white10,
    Color bottomShadowColor = Colors.black26,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              offset: -offset,
              color: topShadowColor,
              blurRadius: blurRadius,
            ),
            BoxShadow(
              offset: offset,
              color: bottomShadowColor,
              blurRadius: blurRadius,
            ),
          ],
        ),
        child: this,
      ),
    );
  }
}
