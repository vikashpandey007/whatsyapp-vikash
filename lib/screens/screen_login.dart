import 'package:WhatsYapp/Dependencies/Auth/auth_controller.dart';
import 'package:WhatsYapp/dependencies/utils/utils_colours.dart';
import 'package:WhatsYapp/widgets/widget_elevated_button.dart';
import 'package:WhatsYapp/widgets/widget_icon_button.dart';
import 'package:WhatsYapp/widgets/widget_text.dart';
//import '../../delete/Firebase/auth_service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:WhatsYapp/Dependencies/helper/theme_extension.dart';
import 'package:WhatsYapp/Dependencies/helper/show_alert_dialog.dart';

//import '../../delete/Auth/auth_controller.dart';

class ValidateScreen extends ConsumerStatefulWidget {
  const ValidateScreen({super.key});
  // static const String routeName = '/ValidateScreen';

  @override
  ConsumerState<ValidateScreen> createState() => _ValidateScreenState();
}

class _ValidateScreenState extends ConsumerState<ValidateScreen> {
  late TextEditingController countryNameController;
  late TextEditingController countryCodeController;
  late TextEditingController phoneNumberController;
  final TextEditingController smsController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  sendCodeToPhone() {
    final phoneNumber = phoneNumberController.text;
    final countryName = countryNameController.text;
    final countryCode = countryCodeController.text;

    if (phoneNumber.isEmpty) {
      return showAlertDialog(
        context: context,
        message: "Please enter your phone number",
      );
    } else if (phoneNumber.length < 9) {
      return showAlertDialog(
        context: context,
        message:
            'The phone number you entered is too short for the country: $countryName\n\nInclude your area code if you haven\'t',
      );
    } else if (phoneNumber.length > 10) {
      return showAlertDialog(
        context: context,
        message:
            "The phone number you entered is too long for the country: $countryName",
      );
    }

    ref.read(authControllerProvider).sendSmsCode(
          context: context,
          phoneNumber: "+$countryCode$phoneNumber",
        );
  }

  showCountryPickerBottomSheet() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: ['IN'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 600,
        backgroundColor: Colors.white,
        flagSize: 22,
        borderRadius: BorderRadius.circular(20),
        textStyle: TextStyle(color: context.theme?.greyColor),
        inputDecoration: InputDecoration(
          labelStyle: TextStyle(color: context.theme?.greyColor),
          prefixIcon: const Icon(
            Icons.language,
            color: Coloors.greenDark,
          ),
          hintText: 'Search country by code or name',
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
                // color: context.theme.greyColor.withOpacity(.2),
                ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Coloors.greenDark,
            ),
          ),
        ),
      ),
      onSelect: (country) {
        countryNameController.text = country.name;
        countryCodeController.text = country.phoneCode;
      },
    );
  }

  @override
  void initState() {
    countryNameController = TextEditingController(text: 'India');
    countryCodeController = TextEditingController(text: '91');
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    countryNameController.dispose();
    countryCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: const Text(
            'Enter your phone number',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          actions: [
            CustomIconButton(
              onPressed: () {},
              icon: Icons.more_vert,
              iconColor: Colors.black,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'WhatsApp will need to verify your number. ',
                  style: TextStyle(
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: "What's my number?",
                      style: TextStyle(
                        color: Coloors.greenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: CustomTextField(
                onTap: showCountryPickerBottomSheet,
                controller: countryNameController,
                readOnly: true,
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Coloors.greenDark,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: CustomTextField(
                      onTap: showCountryPickerBottomSheet,
                      controller: countryCodeController,
                      prefixText: '+',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: phoneNumberController,
                      hintText: 'phone number',
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Carrier charges may apply',
              style: TextStyle(
                color: context.theme?.greyColor,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: CustomElevatedButton(
          onPressed: sendCodeToPhone,
          text: 'NEXT',
          buttonWidth: 90,
        ),
      ),
    );
  }
}
