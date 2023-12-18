import 'package:WhatsYapp/Dependencies/Auth/authentication.dart';
import 'package:WhatsYapp/screens/screen_onboarding.dart';
import 'package:WhatsYapp/screens/screen_profile.dart';

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF017F6A),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
              // Navigate to profile settings screen
              // Add your navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Account'),
            onTap: () {
              // Navigate to account settings screen
              // Add your navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // Navigate to notification settings screen
              // Add your navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chats'),
            onTap: () {
              // Navigate to chat settings screen
              // Add your navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Data and storage usage'),
            onTap: () {
              // Navigate to data and storage settings screen
              // Add your navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              // Navigate to help screen
              // Add your navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Navigate to about screen
              // Add your navigation logic here
            },
          ),
          ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                String? retVal = await signOut();
                if (retVal == "success") {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OnboardingScreen()),
                      (route) => false);
                }
              }),
        ],
      ),
    );
  }
}
