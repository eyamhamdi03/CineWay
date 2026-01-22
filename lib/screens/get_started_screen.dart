import 'package:cineway/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  late AnimationController _ticketController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _ticketRotation;
  late Animation<double> _ticketScale;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _ticketController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _ticketRotation = Tween<double>(begin: 0.10, end: -0.25).animate(
      CurvedAnimation(parent: _ticketController, curve: Curves.elasticOut),
    );

    _ticketScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _ticketController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _ticketController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _ticketController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Background gradient and blur effects
          Positioned(
            top: -100,
            left: size.width / 2 - 250,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3d99f5).withOpacity(
                          0.15 + (_pulseController.value * 0.05),
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Floating animated icons
          _buildFloatingIcon(
            top: size.height * 0.18,
            left: size.width * 0.08,
            icon: Icons.videocam_rounded,
            controller: _pulseController,
            duration: 3,
          ),
          _buildFloatingIcon(
            top: size.height * 0.22,
            right: size.width * 0.12,
            icon: Icons.star_rounded,
            controller: _pulseController,
            duration: 4,
            isBounce: true,
          ),
          _buildFloatingIcon(
            top: size.height * 0.38,
            left: size.width * 0.06,
            icon: Icons.local_activity_rounded,
            controller: _pulseController,
            duration: 5,
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Ticket card section
                Expanded(
                  flex: 7,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -10),
                      child: AnimatedBuilder(
                        animation: _ticketController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _ticketScale.value,
                            child: Transform.rotate(
                              angle: _ticketRotation.value,
                              child: _buildTicketCard(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Bottom content
                SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // App icon and name
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3d99f5), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3d99f5).withOpacity(0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.theaters_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'CineWay',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Heading
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 38,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(text: 'Your Gateway to the\n'),
                                TextSpan(
                                  text: 'Big Screen',
                                  style: TextStyle(color: Color(0xFF3d99f5)),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description
                          Text(
                            'Book tickets for the latest movies and\nsecure the best seats in just a few taps.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[400],
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Buttons
                          _buildPrimaryButton(
                            context,
                            'Get Started',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SignupScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildSecondaryButton(
                            context,
                            'Log In',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Terms text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'By continuing, you agree to our Terms of Service & Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon({
    required double top,
    double? left,
    double? right,
    required IconData icon,
    required AnimationController controller,
    required int duration,
    bool isBounce = false,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final value = isBounce
              ? math.sin(controller.value * math.pi * 2) * 15
              : math.sin(controller.value * math.pi * 2) * 8;
          final rotation = math.sin(controller.value * math.pi * 2) * 0.1;
          return Transform.translate(
            offset: Offset(0, value),
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: 0.15 + (math.sin(controller.value * math.pi * 2) * 0.1),
                child: Icon(
                  icon,
                  size: isBounce ? 35 : 45,
                  color: isBounce ? Colors.white : const Color(0xFF3d99f5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      width: 300,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E1E).withOpacity(0.95),
            const Color(0xFF2A2A2A).withOpacity(0.9),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3d99f5).withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left section (ADMIT ONE)
          Container(
            width: 85,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A).withOpacity(0.3),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'ADMIT ONE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                // Top notch
                Positioned(
                  top: -12,
                  left: 33,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF121212),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Bottom notch
                Positioned(
                  bottom: -12,
                  left: 33,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF121212),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right section
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo and name
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3d99f5), Color(0xFF2563EB)],
                              ),
                            ),
                            child: const Icon(
                              Icons.movie_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'CineWay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // Placeholder lines
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 110,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),

                      // Row and Seat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ROW',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'G',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SEAT',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '12',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Icon(
                            Icons.qr_code_2_rounded,
                            color: Colors.white.withOpacity(0.15),
                            size: 36,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Top notch
                Positioned(
                  top: -12,
                  right: 32,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF121212),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Bottom notch
                Positioned(
                  bottom: -12,
                  right: 32,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF121212),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3d99f5), Color(0xFF2563EB)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3d99f5).withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
