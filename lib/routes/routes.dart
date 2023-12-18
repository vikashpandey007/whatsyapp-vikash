import 'package:WhatsYapp/Screens/Home_pages/home_page.dart';
import 'package:WhatsYapp/screens/screen_loading.dart';
import 'package:WhatsYapp/screens/screen_login.dart';
import 'package:WhatsYapp/screens/screen_onboarding.dart';
import 'package:WhatsYapp/screens/screen_otp_genrate.dart';
import 'package:WhatsYapp/screens/screen_set_profile.dart';

import 'package:flutter/material.dart';

class Routes {
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String varification = 'varification';
  static const String userInfo = 'userInfo';
  static const String home = 'home';
  static const String chat = 'chat';
  static const String profilepage = 'profilepage';
  static const String loading = 'loading';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (context) => const ValidateScreen(),
        );
      case varification:
        final Map args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (context) => VerificationPage(
            smsCodeId: args['smsCodeId'],
            phoneNumber: args['phoneNumber'],
          ),
        );
      case userInfo:
        final String? profileImageUrl = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => UserInfoPage(
            profileImageUrl: profileImageUrl,
          ),
        );
      case home:
        return MaterialPageRoute(builder: (context) => const HomePage());
      case loading:
        return MaterialPageRoute(
          builder: (context) => const Loading(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) {
            return const Scaffold(
              body: Center(
                child: Text('No Page Route Provided'),
              ),
            );
          },
        );
    }
  }
}
