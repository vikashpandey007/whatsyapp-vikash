import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:WhatsYapp/Dependencies/Auth/auth_controller.dart';
import 'package:WhatsYapp/dependencies/utils/utils_colours.dart';
import 'package:WhatsYapp/routes/routes.dart';
import 'package:WhatsYapp/widgets/widget_elevated_button.dart';
import 'package:WhatsYapp/widgets/widget_icon_button.dart';
import 'package:WhatsYapp/widgets/widget_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:WhatsYapp/Dependencies/helper/theme_extension.dart';
import 'package:WhatsYapp/Dependencies/helper/show_alert_dialog.dart';
import 'package:WhatsYapp/widgets/widget_short_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key, this.profileImageUrl});

  final String? profileImageUrl;

  @override
  ConsumerState<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  File? imageCamera;
  Uint8List? imageGallery;
  late final FirebaseAuth auth;
  late TextEditingController usernameController;
  late DatabaseReference messages_ref;

  var profile;

  saveUserDataToFirebase() {
    String username = usernameController.text;
    if (username.isEmpty) {
      return showAlertDialog(
        context: context,
        message: 'Please provide a username',
      );
    } else if (username.length < 3 || username.length > 20) {
      return showAlertDialog(
        context: context,
        message: 'A username length should be between 3-20',
      );
    } else if (profile == null || profile == "" || imageCamera != null) {
      ref.read(authControllerProvider).saveUserInfoToFirestore(
            username: username,
            profileImage:
                imageCamera ?? imageGallery ?? widget.profileImageUrl ?? '',
            context: context,
            mounted: mounted,
          );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.loading,
        (route) => false,
      );
    }
  }

  // Future requestPermission() async {
  //   const permission = Permission.camera;

  //   if (await permission.isDenied) {
  //     await permission.request();
  //   }
  // }

  Future<bool> storagePermission() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    debugPrint('releaseVersion : ${androidInfo.version.release}');
    final int androidVersion = int.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 6) {
      final request = await [
        Permission.videos,
        Permission.photos,
        //..... as needed
      ].request();

      havePermission =
          request.values.every((status) => status == PermissionStatus.granted);
    } else {
      final status = await Permission.storage.request();
      havePermission = status.isGranted;
    }

    if (!havePermission) {
      // if no permission then open app-setting
      await openAppSettings();
    }

    return havePermission;
  }

  imagePickerTypeBottomSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ShortHBar(),
            Row(
              children: [
                const SizedBox(width: 20),
                const Text(
                  'Profile photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                CustomIconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.close,
                ),
                const SizedBox(width: 15),
              ],
            ),
            Divider(
              color: context.theme?.greyColor!.withOpacity(.3),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const SizedBox(width: 20),
                imagePickerIcon(
                  onTap: pickmageFromCamera,
                  icon: Icons.camera_alt_rounded,
                  text: 'Camera',
                ),
                const SizedBox(width: 15),
                imagePickerIcon(
                  onTap: pickmageFromGallery,
                  icon: Icons.photo_camera_back_rounded,
                  text: 'Gallery',
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        );
      },
    );
  }

  pickmageFromCamera() async {
    try {
      Navigator.pop(context);
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          imageCamera = File(image.path);
          print(imageCamera);
        });
      }
    } catch (e) {
      showAlertDialog(context: context, message: e.toString());
    }
  }

  Future<void> pickmageFromGallery() async {
    Navigator.pop(context);
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageCamera = File(pickedFile.path);
      });
    }
  }

  imagePickerIcon({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
  }) {
    return Column(
      children: [
        CustomIconButton(
          onPressed: onTap,
          icon: icon,
          iconColor: Coloors.greenDark,
          minWidth: 50,
          border: Border.all(
            color: Colors.grey.withOpacity(.2),
            width: 1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          text,
          style: TextStyle(
            color: context.theme?.greyColor,
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    final DatabaseReference _database = FirebaseDatabase.instance.reference();
    usernameController = TextEditingController();
    auth = FirebaseAuth.instance;
    final client_ref = FirebaseDatabase.instance
        .ref()
        .child('Users/${auth.currentUser!.phoneNumber}/info');

    client_ref.onValue.listen((event) {
      if (event.snapshot.exists) {
        event.snapshot.children.forEach((DataSnapshot snapshot) {
          var valueMap = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            usernameController.text = valueMap['name'];
            profile = valueMap['profile_picture'];
          });
        });
      }
      // Handle the real-time data update
    });

    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("profile url == ${widget.profileImageUrl}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile info',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              'Please provide your name and an optional profile photo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.theme?.greyColor,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () async {
                PermissionStatus cameraStatus =
                    await Permission.camera.request();
                if (cameraStatus == PermissionStatus.granted) {
                  imagePickerTypeBottomSheet();
                }
                if (cameraStatus == PermissionStatus.denied) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('This permission is recommmended')));
                }
                if (cameraStatus == PermissionStatus.permanentlyDenied) {
                  openAppSettings();
                }

                final permission = await storagePermission();
                debugPrint('permission : $permission');
                // await requestPermission();
                // // await requestPermissionstorage();
                // await imagePickerTypeBottomSheet();
              },
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  // border: Border.all(
                  //   color: imageCamera == null
                  //       ? Colors.transparent
                  //       : context.theme!.greyColor!.withOpacity(.4),
                  // ),
                  image: imageCamera != null || profile != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: imageCamera != null
                              ? FileImage(imageCamera!)
                              : profile != null || profile != ""
                                  ? NetworkImage(profile)
                                  : FileImage(imageCamera!) as ImageProvider,
                        )
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 3, right: 3),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    size: 48,
                    color: imageCamera == null &&
                            imageGallery == null &&
                            widget.profileImageUrl == null
                        ? context.theme?.photoIconColor
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: CustomTextField(
                    controller: usernameController,
                    hintText: 'Type your name here',
                    textAlign: TextAlign.start,
                    autoFocus: true,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: context.theme?.photoIconColor,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: saveUserDataToFirebase,
        text: 'NEXT',
        buttonWidth: 90,
      ),
    );
  }
}


//  async {
//                 Map<Permission, PermissionStatus> statuses = await [
//                   Permission.storage,
//                   Permission.camera,
//                 ].request();
//                 if (statuses[Permission.storage]!.isGranted &&
//                     statuses[Permission.camera]!.isGranted) {
//                   imagePickerTypeBottomSheet();
//                 }
//                 if (statuses[Permission.storage]!.isGranted &&
//                     statuses[Permission.camera]!.isDenied) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                       content: Text('This permission is recommmended')));
//                 }
//                 if (statuses[Permission.storage]!.isGranted &&
//                     statuses[Permission.camera]!.isPermanentlyDenied) {
//                   openAppSettings();
//                 }
//               },