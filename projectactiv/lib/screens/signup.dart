import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});
  
  final AuthService _authService = AuthService();

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in successful: ${userCredential.user?.email}')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in error: $error')),
        );
      }
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final userCredential = await _authService.signInWithFacebook();
      
      if (userCredential != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook sign-in successful: ${userCredential.user?.email}')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Facebook sign-in error: $error')),
        );
      }
    }
  }

  Future<void> _signInWithLinkedIn(BuildContext context) async {
    try {
      // LinkedIn sign-in implementation would go here
      // Note: signin_with_linkedin package may need additional configuration
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('LinkedIn sign-in coming soon!')),
        );
      }
      // Show coming soon message or implement LinkedIn OAuth
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('LinkedIn sign-in error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Card
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4DF7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.account_circle, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "ACTIV Member Portal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF222B45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Empowering Entrepreneurs",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Main Card
              Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B4DF7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.account_circle, color: Colors.white, size: 48),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Welcome to ACTIV",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF222B45),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Register or login to continue your journey of empowerment, networking, and growth through our platform.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8F9BB3),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Google Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFE4E9F2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _signInWithGoogle(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                                  Image.asset(
                              'assets/images/google.png',
                              height: 22,
                              width: 22,
                            ),
                                             const SizedBox(width: 10),
                            const Text("Continue with Google",
                                style: TextStyle(fontSize: 16, color: Color(0xFF222B45))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Facebook Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _signInWithFacebook(context),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.facebookF, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text("Continue with Facebook",
                                style: TextStyle(fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // LinkedIn Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A66C2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _signInWithLinkedIn(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/linkedin.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text("Continue with LinkedIn",
                                style: TextStyle(fontSize: 16, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      "OR",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8F9BB3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        "Login with Email (Admin)",
                        style: TextStyle(
                          color: Color(0xFF5B4DF7),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Register Now
              SizedBox(
                width: 400,
                child: Column(
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 15, color: Color(0xFF8F9BB3)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Register Now",
                        style: TextStyle(
                          color: Color(0xFF5B4DF7),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Footer
              const SizedBox(
                width: 400,
                child: Text(
                  "Powered by VALAR DIGITAL COMMERCE PVT LTD",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8F9BB3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
