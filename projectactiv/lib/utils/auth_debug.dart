import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'logger.dart';

class AuthDebugWidget extends StatelessWidget {
  final AuthService authService;
  
  const AuthDebugWidget({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍 Auth Debug', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('User: ${authService.currentUser?.email ?? "Not logged in"}'),
          Text('UID: ${authService.currentUser?.uid ?? "No UID"}'),
          Text('Authenticated: ${authService.isUserAuthenticated}'),
          const SizedBox(height: 4),
          ElevatedButton(
            onPressed: () => _testAuth(),
            child: const Text('Test Auth'),
          ),
        ],
      ),
    );
  }

  void _testAuth() {
    final user = authService.currentUser;
    if (user == null) {
      AppLogger.error('❌ No user logged in');
    } else if (user.uid.isEmpty) {
      AppLogger.error('❌ User UID is empty');
    } else {
      AppLogger.success('✅ User authenticated: ${user.email} (${user.uid})');
    }
  }
}
