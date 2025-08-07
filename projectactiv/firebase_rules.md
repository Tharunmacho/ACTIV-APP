# Firebase Security Rules Configuration

## Firestore Rules

Add these rules to your Firebase Console > Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Member registrations - users can create/read their own registrations
    match /member_registrations/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admin access (optional - add specific admin UIDs)
    match /{document=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid in ["ADMIN_UID_1", "ADMIN_UID_2"];
    }
  }
}
```

## Storage Rules

Add these rules to your Firebase Console > Storage > Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Member profile images
    match /member_profiles/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Member certificates (if needed in future)
    match /member_certificates/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Firebase Configuration Checklist

### 1. Firebase Console Setup
- [ ] Project created in Firebase Console
- [ ] Authentication enabled (Email/Password, Google, Facebook)
- [ ] Firestore Database created
- [ ] Storage enabled
- [ ] Web app registered

### 2. Authentication Providers
- [ ] Email/Password provider enabled
- [ ] Google Sign-in configured with OAuth client IDs
- [ ] Facebook Login configured with App ID and App Secret

### 3. Firestore Collections
- [ ] `users` collection (auto-created on first user)
- [ ] `member_registrations` collection (auto-created on first registration)

### 4. Security Rules Applied
- [ ] Firestore rules updated (see above)
- [ ] Storage rules updated (see above)
- [ ] Test rules with Firebase Console Rules Playground

### 5. App Configuration
- [ ] `firebase_options.dart` generated and included
- [ ] All required dependencies in `pubspec.yaml`
- [ ] Firebase initialized in `main.dart`

## Testing Firebase Connection

Use this code to test Firebase connection:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Test')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  print('✅ User authenticated: ${user.email}');
                  
                  // Test Firestore write
                  await FirebaseFirestore.instance
                    .collection('test')
                    .doc('test_doc')
                    .set({'message': 'Hello Firebase!', 'timestamp': FieldValue.serverTimestamp()});
                  
                  print('✅ Firestore write successful');
                } else {
                  print('❌ No user authenticated');
                }
              } catch (e) {
                print('❌ Firebase test failed: $e');
              }
            },
            child: Text('Test Firebase'),
          ),
        ],
      ),
    );
  }
}
```

## Common Issues and Solutions

### Issue: Permission Denied
**Solution**: Check Firestore rules, ensure user is authenticated

### Issue: Network Error
**Solution**: Check internet connection and Firebase config

### Issue: Invalid Project ID
**Solution**: Regenerate `firebase_options.dart` with FlutterFire CLI

### Issue: Authentication Failed
**Solution**: Check OAuth configuration for social logins
