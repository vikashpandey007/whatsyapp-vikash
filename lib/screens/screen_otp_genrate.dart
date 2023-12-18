import 'package:WhatsYapp/Dependencies/Auth/auth_controller.dart';
import 'package:WhatsYapp/widgets/widget_icon_button.dart';
import 'package:WhatsYapp/widgets/widget_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:WhatsYapp/Dependencies/helper/theme_extension.dart';

import '../Dependencies/Auth/auth_controller.dart';

class VerificationPage extends ConsumerWidget {
  static const String routeName = '/VerificationPage';

  const VerificationPage({
    super.key,
    required this.smsCodeId,
    required this.phoneNumber,
  });

  final String smsCodeId;
  final String phoneNumber;

  void verifySmsCode(
    BuildContext context,
    WidgetRef ref,
    String smsCode,
    String phoneNumber,
  ) {
    ref.read(authControllerProvider).verifySmsCode(
          context: context,
          smsCodeId: smsCodeId,
          smsCode: smsCode,
          mounted: true,
          phoneNumber: phoneNumber,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Verify your number',
          style: TextStyle(color: Color(0xFF017F6A)),
        ),
        actions: [
          CustomIconButton(
            onPressed: () {},
            icon: Icons.more_vert,
            iconColor: Colors.black,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: context.theme?.greyColor),
                  children: [
                    const TextSpan(
                      text:
                          "You've tried to register +911234567890. before requesting an SMS or Call with your code.",
                    ),
                    TextSpan(
                      text: "Wrong number?",
                      style: TextStyle(
                        color: context.theme?.blueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: CustomTextField(
                hintText: "- - -  - - -",
                fontSize: 30,
                autoFocus: true,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.length == 6) {
                    return verifySmsCode(context, ref, value, phoneNumber);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter 6-digit code',
              style: TextStyle(color: context.theme?.greyColor),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.message, color: context.theme?.greyColor),
                const SizedBox(width: 20),
                Text(
                  'Resend SMS',
                  style: TextStyle(
                    color: context.theme?.greyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              color: context.theme?.greyColor!.withOpacity(.2),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
