# ACTIV Member Registration - Firebase Integration Guide

## 🎯 Overview
This guide explains how the member registration form integrates with Firebase and stores data when the submit button is clicked.

## 📋 Form Fields
The registration form captures the following data:

### Required Fields:
- **Full Name** - Text input
- **Email** - Email input with validation
- **Phone Number** - Phone input
- **Gender** - Dropdown (Male, Female, Other)
- **Date of Birth** - Date picker
- **Member Type** - Dropdown (INDIVIDUAL, SHG, FPO)
- **Category** - Dropdown (Technology, Healthcare, Finance, etc.)
- **Address** - Multi-line text
- **State** - Text input
- **City** - Text input
- **PIN Code** - Number input
- **PAN Number** - Text input

### Optional Fields:
- **Profile Photo** - Image upload

## 🔄 Data Flow

### 1. Form Submission
When user clicks "Submit Registration":
```
User fills form → Clicks Submit → Validation → Create MemberRegistration object → Save to Firebase
```

### 2. Validation Steps
- Form field validation (required fields)
- Date of birth selection check
- Gender selection check
- Member type selection check
- Category selection check
- User authentication check

### 3. Firebase Storage
Data is stored in two Firebase collections:

#### Collection: `member_registrations`
- **Document ID**: User's Firebase Auth UID
- **Data**: Complete registration information
- **Status**: "pending" (default)

#### Collection: `users` (Update)
- **Document ID**: User's Firebase Auth UID  
- **Updated Fields**:
  - `registrationStatus`: "submitted"
  - `registrationDate`: Server timestamp

### 4. File Upload (Optional)
If profile photo is selected:
- **Storage Path**: `member_profiles/{userId}/profile_{timestamp}.jpg`
- **URL**: Stored in registration data as `profilePhotoUrl`

## 🔧 Technical Implementation

### Key Files:
1. **`lib/models/member_registration.dart`** - Data model
2. **`lib/screens/member_registration_screen.dart`** - UI form
3. **`lib/services/auth_service.dart`** - Firebase integration

### Submit Button Implementation:
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _submitRegistration,
  child: _isLoading 
    ? CircularProgressIndicator() 
    : Text('Submit Registration'),
)
```

### Registration Save Process:
```dart
await _authService.saveMemberRegistration(registration, _profileImage);
```

## 🚀 Testing the Registration

### 1. Prerequisites
- User must be logged in (Firebase Auth)
- Internet connection
- Firebase project configured
- Firestore rules allow writes

### 2. Test Steps
1. Navigate to registration form
2. Fill all required fields
3. Click "Submit Registration"
4. Check console logs for progress
5. Verify success message
6. Check Firebase Console for data

### 3. Debug Logging
The app includes detailed logging:
- `🔄` - Process start
- `✅` - Success operations
- `❌` - Errors/failures
- `📤` - Data upload
- `📄` - Firestore operations

## 🔍 Troubleshooting

### Common Issues:

#### 1. "User not authenticated"
**Solution**: User must login first
```dart
Navigator.pushReplacementNamed(context, '/signup');
```

#### 2. "Permission denied"
**Solution**: Check Firestore security rules
```javascript
// Firebase Console > Firestore > Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /member_registrations/{userId} {
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /users/{userId} {
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### 3. "Network error"
**Solution**: Check internet connection and Firebase configuration

#### 4. Form validation fails
**Solution**: Ensure all required fields are filled:
- Full name, email, phone
- Gender, member type, category selected
- Date of birth selected
- Address details and PAN number

### 5. Image upload fails
**Solution**: Check Firebase Storage rules
```javascript
// Firebase Console > Storage > Rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /member_profiles/{userId}/{allPaths=**} {
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📱 User Experience

### Success Flow:
1. Form submission with loading indicator
2. Green success message: "Registration submitted successfully!"
3. Navigation to home screen

### Error Flow:
1. Red error message with specific details
2. Form remains open for retry
3. Loading indicator stops

## 🎛️ Firebase Console Verification

After successful registration, check:

1. **Firestore Database**:
   - Collection: `member_registrations`
   - Document: `{user-uid}`
   - Fields: All registration data

2. **Storage** (if photo uploaded):
   - Folder: `member_profiles/{user-uid}/`
   - File: `profile_{timestamp}.jpg`

3. **Authentication**:
   - User must be in Auth users list
   - User must be currently signed in

## 🔒 Security Notes

- User can only register their own data (UID-based security)
- Registration data tied to authenticated user
- Image uploads scoped to user folder
- No sensitive data logged in production
