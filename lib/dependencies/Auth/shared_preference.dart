import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSharedPreference {
  static const String _keyLoggedIn = 'loggedIn';

  // Save authentication data
  static Future<void> saveAuthData(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_keyLoggedIn, true);

    prefs.setString("phoneNumber", phoneNumber);
  }

  // Retrieve authentication data
  static Future<Map<String, dynamic>?> getAuthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;

    if (isLoggedIn) {
      return {
        'isLoggedIn': isLoggedIn,
      };
    } else {
      return null;
    }
  }

  // Clear authentication data (logout)
  static Future<void> clearAuthData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
