import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '613277586109-emt42fc6ttdf605d20duqmj9janahioe.apps.googleusercontent.com',
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Trigger the standard signInWithCredential flow
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // After a successful credential sign-in, check if this user has a document in the users Firestore collection
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // The Rejection Logic: If the Firestore document does not exist
          // sign them back out using both FirebaseAuth and GoogleSignIn
          await FirebaseAuth.instance.signOut();
          await googleSignIn.signOut();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account not found. Please go to the Sign Up page to create an account.'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }
      }
      
      // The Success Logic: If the document does exist, route them to the Home screen as normal
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Error: [${e.code}] ${e.message}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // DEMO LOGIN LOGIC
    if (email == 'demo@evolvix.com' && password == '123456') {
      try {
        // 1. Try to sign in first
        UserCredential? userCredential;
        try {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found') {
            // 2. If user doesn't exist, create the demo account
            userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            
            // 3. Initialize Demo Data
            if (userCredential.user != null) {
              await _initializeDemoData(userCredential.user!.uid);
            }
          } else {
            rethrow;
          }
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
        return;
      } catch (e) {
        // Fallback to normal error handling if something goes wrong
      }
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initializeDemoData(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    
    // User Profile
    batch.set(userRef, {
      'username': 'DemoUser',
      'name': 'Demo User',
      'email': 'demo@evolvix.com',
      'level': 3,
      'xp': 120,
      'coins': 500,
      'joinedDate': 'January 2024',
      'characterClass': 'Explorer',
    });

    // Sample Tasks
    final tasksRef = userRef.collection('tasks');
    
    // Completed
    batch.set(tasksRef.doc('demo_task_1'), {
      'title': 'Explore Evolvix App',
      'category': 'Habit',
      'xpReward': 50,
      'progress': 1.0,
      'status': 'completed',
    });

    // Pending
    batch.set(tasksRef.doc('demo_task_2'), {
      'title': 'Complete your first study session',
      'category': 'Study',
      'xpReward': 100,
      'progress': 0.0,
      'status': 'active',
    });

    // Rewards
    final rewardsRef = userRef.collection('rewards');
    batch.set(rewardsRef.doc('demo_reward_1'), {
      'title': 'First Steps',
      'description': 'Created your account!',
      'icon': 'stars',
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0118),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 50,
                              offset: const Offset(0, 25),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(48),
                          child: Image.asset(
                            'assets/images/evolvix_logo_wt.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.rocket_launch, color: Colors.white, size: 50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Evolvix',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Inter',
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF59168B).withOpacity(0.3),
                            const Color(0xFF312C85).withOpacity(0.3),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0xFFAD46FF).withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF9810FA),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF9810FA).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: Color(0xFFDAB2FF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInputField(
                            label: 'Email',
                            hint: 'Enter your email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            controller: _passwordController,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Color(0xFFC27AFF), fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9810FA), Color(0xFF4F39F6)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFAD46FF).withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -4,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: Divider(color: const Color(0xFFAD46FF).withOpacity(0.3))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: Color(0xFFC27AFF), fontSize: 14),
                                ),
                              ),
                              Expanded(child: Divider(color: const Color(0xFFAD46FF).withOpacity(0.3))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // GOOGLE SIGN IN BUTTON
                          InkWell(
                            onTap: _isGoogleLoading ? null : _signInWithGoogle,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3C0366).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFAD46FF).withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: _isGoogleLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google_logo.png',
                                          height: 24,
                                          errorBuilder: (context, error, stackTrace) => 
                                              const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            color: Color(0xFFDAB2FF),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0118), Color(0xFF2A1544)],
            ),
          ),
        ),
        Positioned(
          left: -44,
          top: 295,
          child: _GlowEffect(
            color: const Color(0xFF9810FA).withOpacity(0.44),
            size: 460,
            blur: 120,
          ),
        ),
        Positioned(
          left: -100,
          top: 100,
          child: _GlowEffect(
            color: const Color(0xFFAD46FF).withOpacity(0.1),
            size: 200,
            blur: 80,
          ),
        ),
        Positioned(
          right: -50,
          bottom: 50,
          child: _GlowEffect(
            color: const Color(0xFF615FFF).withOpacity(0.1),
            size: 250,
            blur: 100,
          ),
        ),
        ..._buildStars(),
      ],
    );
  }

  List<Widget> _buildStars() {
    final stars = [
      [198.0, 223.0, 0.36],
      [41.0, 407.0, 0.61],
      [347.0, 150.0, 0.21],
      [15.0, 608.0, 0.54],
      [114.0, 230.0, 0.60],
      [301.0, 583.0, 0.57],
      [130.0, 299.0, 0.32],
      [109.0, 320.0, 0.47],
      [112.0, 158.0, 0.78],
      [90.0, 276.0, 0.94],
      [92.0, 181.0, 0.77],
    ];
    return stars.map((star) => Positioned(
      left: star[0],
      top: star[1],
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFC27AFF).withOpacity(star[2] as double),
          shape: BoxShape.circle,
        ),
      ),
    )).toList();
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFDAB2FF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFAD46FF), fontSize: 16),
            prefixIcon: Icon(icon, color: const Color(0xFFC27AFF), size: 20),
            suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFFC27AFF),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
            filled: true,
            fillColor: const Color(0xFF3C0366).withOpacity(0.3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFFAD46FF).withOpacity(0.3),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFAD46FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowEffect extends StatelessWidget {
  final Color color;
  final double size;
  final double blur;
  const _GlowEffect({required this.color, required this.size, required this.blur});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur), child: Container(color: Colors.transparent)),
    );
  }
}
