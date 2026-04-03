import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A0118), Color(0xFF1A0F2E)],
              ),
            ),
          ),
          
          // Star Particles
          ..._buildStars(),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),


                // Branded Logo Centerpiece

                Center(

                  child: Container(

                    width: 120,

                    height: 120,

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      border: Border.all(color: Colors.white.withOpacity(0.1)),

                      boxShadow: [

                        BoxShadow(

                          color: const Color(0xFF9810FA).withOpacity(0.2), // Your purple glow

                          blurRadius: 40,

                          spreadRadius: 10,

                        ),

                      ],

                      // This maps your image directly to the circle shape

                      image: const DecorationImage(

                        image: AssetImage('assets/images/evolvix_logo_wt.png'),

                        fit: BoxFit.cover,

                      ),

                    ),

                  ),

                ),



                const SizedBox(height: 32),
                // // Logo
                // Center(
                //   child: Container(
                //     width: 120,
                //     height: 120,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: Colors.white.withOpacity(0.05),
                //       border: Border.all(color: Colors.white.withOpacity(0.1)),
                //       boxShadow: [
                //         BoxShadow(
                //           color: const Color(0xFF9810FA).withOpacity(0.2),
                //           blurRadius: 40,
                //           spreadRadius: 10,
                //         ),
                //       ],
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(12),
                //       child: Image.asset(
                //         'assets/images/evolvix_logo_wt.png',
                //         errorBuilder: (context, error, stackTrace) =>
                //             const Icon(Icons.rocket_launch, color: Colors.white, size: 60),
                //       ),
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Evolvix',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Subtitle
                const Text(
                  'Turn Productivity Into Progress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xCCFFFFFF),
                    fontFamily: 'Inter',
                    letterSpacing: 0.45,
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Loading Section
                Column(
                  children: [
                    // Progress Bar
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF9810FA),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9810FA).withOpacity(0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'INITIALIZING SYSTEM',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(flex: 2),
                
                // Bottom Focus Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: const Color(0xFF1E1435).withOpacity(0.6),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFB5F66B),
                          ),
                          child: const Icon(Icons.trending_up, color: Colors.black, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "TODAY'S FOCUS",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFDAB2FF),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Preparing your daily narrative...',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  List<Widget> _buildStars() {
    final stars = [
      [50.0, 100.0, 0.4],
      [280.0, 150.0, 0.2],
      [150.0, 300.0, 0.3],
      [40.0, 550.0, 0.5],
      [320.0, 600.0, 0.2],
      [100.0, 750.0, 0.4],
      [200.0, 820.0, 0.1],
      [340.0, 420.0, 0.6],
      [80.0, 220.0, 0.2],
      [250.0, 680.0, 0.3],
      [15.0, 400.0, 0.4],
      [300.0, 250.0, 0.1],
    ];
    
    return stars.map((star) => Positioned(
      left: star[0],
      top: star[1],
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: const Color(0xFFC27AFF).withOpacity(star[2]),
          shape: BoxShape.circle,
        ),
      ),
    )).toList();
  }
}
