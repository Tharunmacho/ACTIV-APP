import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ACTIV Dashboard'),
        backgroundColor: const Color(0xFF5B4DF7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/signup');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF5B4DF7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to ACTIV!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222B45),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hello, ${user?.displayName ?? user?.email ?? 'User'}',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF8F9BB3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Logged in via: ${user?.providerData.isNotEmpty == true ? user?.providerData.first.providerId : 'email'}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8F9BB3),
              ),
            ),
            const SizedBox(height: 32),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'You have successfully logged in to the ACTIV Member Portal. Your authentication details have been saved to Firebase.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF222B45),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
