import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart' as app_user;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  // Current user stream
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;
  
  // Send OTP to phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(firebase_auth.FirebaseAuthException error) onVerificationFailed,
    required Function(firebase_auth.PhoneAuthCredential credential) onVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-retrieval timeout
      },
    );
  }
  
  // Verify OTP and sign in
  Future<firebase_auth.UserCredential?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}