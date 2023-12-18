import 'package:WhatsYapp/dependencies/notification/firebase_notification.dart';
import 'package:WhatsYapp/dependencies/root/OurRoot.dart';
import 'package:WhatsYapp/screens/Home_pages/home_page.dart';
import 'package:WhatsYapp/firebase_options.dart';
import 'package:WhatsYapp/routes/screen_image_view.dart';
import 'package:WhatsYapp/screens/screen_myvideo_player.dart';
import 'package:WhatsYapp/screens/screen_onboarding.dart';
import 'package:WhatsYapp/routes/screen_video_view.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:WhatsYapp/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'helvetica'),
        debugShowCheckedModeBanner: false,
        home: OurRoot(),
        onGenerateRoute: Routes.onGenerateRoute,
      ),
    );
  }
}
