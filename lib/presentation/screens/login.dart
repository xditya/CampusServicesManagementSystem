import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:csms/helper/config.dart';
import 'package:csms/helper/validate_email.dart';
import 'package:csms/presentation/router/router.dart';
import 'package:fluro/fluro.dart';
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
        AppRouter.router.navigateTo(
          context,
          '/dashboard',
          transition: TransitionType.fadeIn,
          replace: true,
        );
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
          AppRouter.router.navigateTo(
            context,
            '/dashboard',
            transition: TransitionType.fadeIn,
            replace: true,
          );
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

        if (mounted) {
          AppRouter.router.navigateTo(
            context,
            '/dashboard',
            transition: TransitionType.fadeIn,
            replace: true,
          );
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter OTP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter the verification code sent to your email: ${_emailController.text}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 40,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        fillColor: Colors.white.withOpacity(0.05),
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
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showOtpInput = false;
                        for (var controller in _otpControllers) {
                          controller.clear();
                        }
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.7),
                    ),
                    child: const Text('Back'),
                  ),
                  TextButton(
                    onPressed: _handleEmailSubmit,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.7),
                    ),
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              Theme.of(context).colorScheme.surface,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo with enhanced shadow and animation
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                'assets/images/CSMS.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 48),

                    Text(
                      'CSMS',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Campus Services Management System',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: 48),

                    // Sign in with Google Button
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: ElevatedButton(
                        onPressed: () => _handleGoogleSignIn(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 3,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (_showOtpInput)
                      _buildOtpInput()
                    else if (!_showEmailInput) ...[
                      // Subtle text button for other login methods
                      TextButton(
                        onPressed: () => setState(() => _showEmailInput = true),
                        child: Text(
                          'Use other sign-in methods',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Enhanced email input container
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign in with Email',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                      labelStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      fillColor: Colors.white.withOpacity(0.01),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.red.shade300,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      suffixIcon: _emailController
                                              .text.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                              ),
                                              onPressed: () {
                                                _emailController.clear();
                                                _emailFocusNode.requestFocus();
                                              },
                                            )
                                          : null,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(
                                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        onPressed: () => setState(
                                            () => _showEmailInput = false),
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              Colors.white.withOpacity(0.7),
                                        ),
                                        child: const Text('Back'),
                                      ),
                                      ElevatedButton(
                                        onPressed: _handleEmailSubmit,
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black87,
                                          backgroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Text('Continue'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
