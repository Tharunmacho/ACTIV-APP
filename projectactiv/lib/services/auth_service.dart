import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/member_registration.dart';
import '../utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is properly authenticated with valid UID
  bool get isUserAuthenticated {
    final user = _auth.currentUser;
    return user != null && user.uid.isNotEmpty;
  }

  // Force refresh the current user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _saveUserToFirestore(userCredential.user!, 'google');
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;

      final OAuthCredential facebookAuthCredential = 
          FacebookAuthProvider.credential(result.accessToken!.token);
      
      final UserCredential userCredential = 
          await _auth.signInWithCredential(facebookAuthCredential);
      await _saveUserToFirestore(userCredential.user!, 'facebook');
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      AppLogger.process('Attempting email/password sign-in for: $email');
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      AppLogger.success('Email/password sign-in successful');
      
      // Save/update user info in Firestore (passwords are handled securely by Firebase Auth)
      await _saveUserToFirestore(userCredential.user!, 'email');
      
      return userCredential;
    } catch (e) {
      AppLogger.error('Email/password sign-in failed: $e');
      rethrow;
    }
  }

  Future<UserCredential?> createUserWithEmailPassword(String email, String password, {String? displayName}) async {
    try {
      AppLogger.process('Creating new email/password account for: $email');
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
        await userCredential.user?.reload();
      }
      
      AppLogger.success('Email/password account created successfully');
      
      // Save user info in Firestore with additional admin data
      await _saveUserToFirestore(userCredential.user!, 'email', isAdmin: true);
      
      return userCredential;
    } catch (e) {
      AppLogger.error('Email/password account creation failed: $e');
      rethrow;
    }
  }

  Future<void> _saveUserToFirestore(User user, String provider, {bool isAdmin = false}) async {
    try {
      AppLogger.info('Saving user to Firestore: ${user.email}');
      
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'provider': provider,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Add admin-specific fields
      if (isAdmin) {
        userData.addAll({
          'role': 'admin',
          'adminAccess': true,
          'permissions': ['read', 'write', 'admin'],
        });
      } else {
        userData.addAll({
          'role': 'user',
          'adminAccess': false,
          'permissions': ['read'],
        });
      }

      // Only set createdAt for new users
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        userData['createdAt'] = FieldValue.serverTimestamp();
        AppLogger.info('Creating new user document');
      } else {
        AppLogger.info('Updating existing user document');
      }

      await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
      
      AppLogger.success('User data saved to Firestore successfully');
      
    } catch (e) {
      AppLogger.error('Error saving user to Firestore: $e');
      // Don't rethrow to avoid breaking the auth flow
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> _uploadImage(File image, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveMemberRegistration(MemberRegistration registration, File? profileImage) async {
    try {
      AppLogger.process('AuthService: Starting member registration save...');
      AppLogger.info('User ID: ${registration.userId}');
      
      // Validate that userId is not empty
      if (registration.userId.trim().isEmpty) {
        throw Exception('User ID cannot be empty. Please ensure user is properly authenticated.');
      }
      
      // Validate that current user matches registration userId
      final currentUser = _auth.currentUser;
      if (currentUser == null || currentUser.uid != registration.userId) {
        throw Exception('Authentication mismatch. Please logout and login again.');
      }
      
      AppLogger.success('User validation passed');
      
      String? profilePhotoUrl;

      // Upload profile image if provided
      if (profileImage != null) {
        AppLogger.info('Uploading profile image...');
        profilePhotoUrl = await _uploadImage(
          profileImage,
          'member_profiles/${registration.userId}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        AppLogger.success('Profile image uploaded: $profilePhotoUrl');
      } else {
        AppLogger.info('No profile image to upload');
      }

      // Create updated registration with image URLs
      final updatedRegistration = MemberRegistration(
        profilePhotoUrl: profilePhotoUrl,
        fullName: registration.fullName,
        email: registration.email,
        phoneNumber: registration.phoneNumber,
        gender: registration.gender,
        dateOfBirth: registration.dateOfBirth,
        memberType: registration.memberType,
        category: registration.category,
        address: registration.address,
        state: registration.state,
        city: registration.city,
        pinCode: registration.pinCode,
        panNumber: registration.panNumber,
        registrationDate: registration.registrationDate,
        userId: registration.userId,
      );

      AppLogger.info('Saving registration data to Firestore...');
      
      // Save to Firestore
      await _firestore
          .collection('member_registrations')
          .doc(registration.userId)
          .set(updatedRegistration.toFirestore());

      AppLogger.success('Registration data saved to member_registrations collection');

      // Update user profile with registration status
      AppLogger.info('Updating user profile with registration status...');
      await _firestore.collection('users').doc(registration.userId).update({
        'registrationStatus': 'submitted',
        'registrationDate': FieldValue.serverTimestamp(),
      });
      
      AppLogger.success('User profile updated successfully');
      AppLogger.success('Member registration save completed successfully!');
      
    } catch (e) {
      AppLogger.error('AuthService error: $e');
      rethrow;
    }
  }

  Future<MemberRegistration?> getMemberRegistration(String userId) async {
    try {
      final doc = await _firestore
          .collection('member_registrations')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return MemberRegistration.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
