import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final TextEditingController _phoneNumberController = TextEditingController();
final TextEditingController _otpController = TextEditingController();
String _verificationId = '';

Future<void> verifyPhoneNumber() async {
  String phoneNumber =
      '${_phoneNumberController.text}'; // Replace with your country code
  try {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print(
            'Verification completed automatically: ${_auth.currentUser!.uid}');
        // Save user details to Firebase Realtime Database
        saveUserDetailsToDatabase('John Doe', 'john.doe@example.com');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: $e');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('Code sent to $phoneNumber');
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code auto retrieval timed out');
      },
      timeout: Duration(seconds: 60),
    );
  } catch (e) {
    print('Error verifying phone number: $e');
  }
}

Future<void> verifyOTP() async {
  String smsCode = _otpController.text;
  try {
    AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
    print('User signed in with OTP: ${_auth.currentUser!.uid}');
    // Save user details to Firebase Realtime Database
    saveUserDetailsToDatabase('John Doe', 'john.doe@example.com');
  } catch (e) {
    print('Error verifying OTP: $e');
  }
}

Future<void> saveUserDetailsToDatabase(String displayName, String email) async {
  User? user = _auth.currentUser;

  if (user != null) {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    // Assuming you have a node named "users" in your database
    await databaseReference.child('users').child(user.uid).set({
      'displayName': displayName,
      'email': email,
    });

    print('User details saved to Firebase Realtime Database');
  } else {
    print('User not signed in');
  }
}

Future<String> signOut() async {
  String retval = "error";
  try {
    await _auth.signOut();

    retval = "success";
  } catch (e) {
    print(e);
  }
  return retval;
}
