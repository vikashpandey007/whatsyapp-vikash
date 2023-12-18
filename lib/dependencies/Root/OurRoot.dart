import 'package:WhatsYapp/dependencies/notification/firebase_notification.dart';
import 'package:WhatsYapp/screens/Home_pages/home_page.dart';
import 'package:WhatsYapp/screens/screen_onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;

class OurRoot extends StatefulWidget {
  const OurRoot({super.key});

  @override
  State<OurRoot> createState() => _OurRootState();
}

class _OurRootState extends State<OurRoot> {
  late final FirebaseAuth auth;
  late DatabaseReference client_ref;

  @override
  void initState() {
    auth = FirebaseAuth.instance;
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    if (mounted) {
      _initializeNotifications(context);
    }

    super.initState();
  }

  Future<void> _initializeNotifications(BuildContext context) async {
    await FirebaseMessaging.onMessage.listen((message) {
      if (io.Platform.isAndroid) {
        if (message.notification!.title.toString() !=
            auth.currentUser!.phoneNumber.toString()) {
          LocalNotificationservice().display(message);
          LocalNotificationservice.initNotification(
              context, message, client_ref, auth.currentUser!.phoneNumber);
          LocalNotificationservice.setupInteractmessege(
              context, client_ref, auth.currentUser!.phoneNumber);
        } else {
          print("else");
        }
      }
    });
    // ios notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification != null) {
        print("title ios ====  ${message.notification!.title}");
        print("body ios  ==== ${message.notification!.body}");
      }
      if (io.Platform.isIOS) {
        LocalNotificationservice().display(message);
        LocalNotificationservice.initNotification(context, message,client_ref, auth.currentUser!.phoneNumber);
        LocalNotificationservice.setupInteractmessege(context, client_ref,auth.currentUser!.phoneNumber);

        print("mesga =   ${message.data}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          final bool isLoggedIn = snapshot.hasData;
          return isLoggedIn ? const HomePage() : const OnboardingScreen();
        }
      },
    );
  }

  @override
  void dispose() {
    if (!mounted) {
      _initializeNotifications(context);
    }
    super.dispose();
  }
}
