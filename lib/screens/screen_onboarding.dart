import 'dart:ui';

import 'package:WhatsYapp/Dependencies/helper/theme_extension.dart';
import 'package:WhatsYapp/app_string/constants.dart';
import 'package:WhatsYapp/dependencies/utils/utils_colours.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:WhatsYapp/Routes/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var subscription;
  bool isInternetLostDialogVisible = false; // Track the dialog visibility state

  @override
  void initState() {
    super.initState();
    // Start listening to the connectivity changes when the widget is initialized.
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        // Show the instant alert dialog when the internet is lost.
        if (!isInternetLostDialogVisible) {
          _showInternetLostDialog();
          isInternetLostDialogVisible = true;
        }
      } else {
        // Internet connection is back, hide the dialog if it's visible.
        if (isInternetLostDialogVisible) {
          Navigator.pop(context); // Close the dialog
          isInternetLostDialogVisible = false;
        }
      }
    });
  }

  @override
  void dispose() {
    // Don't cancel the subscription here to keep listening for connectivity changes.
    super.dispose();
  }

// Function to show the instant alert dialog for internet loss.
  void _showInternetLostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            contentPadding: EdgeInsets.all(8.0),
            title: const Text(''),
            content: Container(
              height: 130,
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/no-internet.png',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "No Internet!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Please check internet connection!"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  navigateToLoginPage(context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 120),
            Image.asset(
              'assets/intro_circle_emote.png',
              width: 270,
              height: 270,
            ),
            const SizedBox(height: 50),
            const Text('Welcome to ' + AppConstants.appName,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text:
                      'Read our Privacy Policy. Tap "Agree and continue" to accept the ',
                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: "Terms of Service.",
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Text(
            //     'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service.',
            //     style: TextStyle(
            //       color: Colors.grey,
            //       fontSize: 14,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
            // ),
            const SizedBox(height: 10),
            Material(
              color: context.theme?.langBgColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                // onTap: () => showBottomSheet(context),
                borderRadius: BorderRadius.circular(20),
                splashFactory: NoSplash.splashFactory,
                highlightColor: context.theme?.langHightlightColor,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language,
                        color: Coloors.greenDark,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'English',
                        style: TextStyle(
                          color: Coloors.greenDark,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Coloors.greenDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 150),
            ElevatedButton(
              onPressed: () => navigateToLoginPage(context),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFF017F6A)),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 90, vertical: 10)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40))),
              ),
              child: const Text(
                'Agree and Continue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
