import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class SuccessAnimationScreen extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback? onBackPressed;

  const SuccessAnimationScreen({
    super.key,
    this.title = 'Payment Successful',
    this.message = 'Your transaction has been completed',
    this.onBackPressed,
  });

  @override
  State<SuccessAnimationScreen> createState() => _SuccessAnimationScreenState();
}

class _SuccessAnimationScreenState extends State<SuccessAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _circleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.black,
                    Colors.black87,
                    Colors.black54,
                  ]
                : [
                    Colors.white,
                    Colors.white70,
                    Colors.white54,
                  ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _circleAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: CustomPaint(
                                  painter: SuccessCheckPainter(
                                    circleColor: isDark
                                        ? Colors.grey[900]!
                                        : Colors.white,
                                    checkColor: Colors.green,
                                    progress: _checkAnimation.value,
                                  ),
                                  size: const Size(200, 200),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween(begin: 0, end: 1),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder(
                          future:
                              Future.delayed(const Duration(milliseconds: 200)),
                          builder: (context, snapshot) {
                            return TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween(
                                  begin: 0,
                                  end: snapshot.connectionState ==
                                          ConnectionState.done
                                      ? 1
                                      : 0),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Text(
                                widget.message,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: (isDark
                                              ? Colors.white
                                              : Colors.black87)
                                          .withOpacity(0.8),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FilledButton.tonal(
                    onPressed: widget.onBackPressed ??
                        () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      side: BorderSide(
                        color: (isDark ? Colors.white : Colors.black12)
                            .withOpacity(0.1),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessCheckPainter extends CustomPainter {
  final Color circleColor;
  final Color checkColor;
  final double progress;

  SuccessCheckPainter({
    required this.circleColor,
    required this.checkColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint circlePaint = Paint()
      ..color = circleColor
      ..style = PaintingStyle.fill;

    final Paint checkPaint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    canvas.drawCircle(center, radius, circlePaint);

    if (progress > 0) {
      final Path checkPath = Path();
      final double startX = size.width * 0.28;
      final double startY = size.height * 0.5;
      final double midX = size.width * 0.45;
      final double midY = size.height * 0.66;
      final double endX = size.width * 0.78;
      final double endY = size.height * 0.38;

      checkPath.moveTo(startX, startY);
      checkPath.lineTo(midX, midY);
      checkPath.lineTo(endX, endY);

      final PathMetric pathMetric = checkPath.computeMetrics().first;
      final Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );

      canvas.drawPath(extractPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SuccessCheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
