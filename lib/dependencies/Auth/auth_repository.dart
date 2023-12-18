//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:WhatsYapp/Dependencies/Auth/firebase_storage_repository.dart';
import 'package:WhatsYapp/Dependencies/Auth/shared_preference.dart';
import 'package:WhatsYapp/dependencies/models/chat_model.dart';
import 'package:WhatsYapp/dependencies/models/model_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:WhatsYapp/Dependencies/helper/show_alert_dialog.dart';
import 'package:WhatsYapp/Dependencies/helper/show_loading_dialolg.dart';
//import 'package:WhatsYapp/auth/firebase_storage_repository.dart';
import 'package:WhatsYapp/routes/routes.dart';
import 'package:moment_dart/moment_dart.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    //  firestore: FirebaseFirestore.instance,
    realtime: FirebaseDatabase.instance,
  );
});

class AuthRepository {
  final FirebaseAuth auth;
  //final FirebaseFirestore firestore;
  final FirebaseDatabase realtime;

  AuthRepository({
    required this.auth,
    //required this.firestore,
    required this.realtime,
  });

  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late DatabaseReference _databaseRef;
  bool isUserInfoAvailable = false;
  // _databaseRef = FirebaseDatabase.instance.reference();

  Future<String> storeUserData(String phoneNumber) async {
    try {
      // Store user data in the Realtime Database
      await _database.child('Users').child(phoneNumber).child('info').set({
        'createdOn': (Moment.now().millisecondsSinceEpoch).toString(),
        'lastSignedIn': (Moment.now().millisecondsSinceEpoch).toString(),
        'name': '',
        'number': phoneNumber,
        'profile_picture': '',
        // Add other fields as needed
      });
      return 'Success';
    } catch (error) {
      print('Error storing user data: $error');
      return 'Failure';
    }
  }

  void updateUserPresence() {
    Map<String, dynamic> online = {
      'active': true,
      'lastSeen': Moment.now().millisecondsSinceEpoch,
    };
    Map<String, dynamic> offline = {
      'active': false,
      'lastSeen': Moment.now().millisecondsSinceEpoch,
    };

    final connectedRef = realtime.ref('.info/connected');

    connectedRef.onValue.listen((event) async {
      final isConnected = event.snapshot.value as bool? ?? false;
      if (isConnected) {
        await realtime.ref().child(auth.currentUser!.uid).update(online);
      } else {
        realtime
            .ref()
            .child(auth.currentUser!.uid)
            .onDisconnect()
            .update(offline);
      }
    });
  }

  // Future<UserModel?> getCurrentUserInfo() async {
  //   UserModel? user;
  //   final userInfo =
  //       await firestore.collection('users').doc(auth.currentUser?.uid).get();

  //   if (userInfo.data() == null) return user;
  //   user = UserModel.fromMap(userInfo.data()!);
  //   return user;
  // }

  void saveUserInfoToFirestore({
    required String username,
    required var profileImage,
    required ProviderRef ref,
    required BuildContext context,
    required bool mounted,
  }) async {
    try {
      showLoadingDialog(
        context: context,
        message: "Saving user info ... ",
      );
      String uid = auth.currentUser!.uid;
      String? phoneNumber = auth.currentUser!.phoneNumber;

      String profileImageUrl = profileImage is String ? profileImage : '';
      if (profileImage != null && profileImage is! String) {
        profileImageUrl = await ref
            .read(firebaseStorageRepositoryProvider)
            .storeFileToFirebase(
                'Users/$phoneNumber/info/${Moment.now().millisecondsSinceEpoch}.jpg',
                profileImage);
        print("$profileImageUrl");
        print(uid);
        print(Moment.now().millisecondsSinceEpoch);
        print(auth.currentUser!.phoneNumber!);
      }
      Navigator.pop(context);

      UserModel user = UserModel(
        username: username,
        uid: uid,
        profileImageUrl: profileImageUrl,
        active: true,
        lastSeen: Moment.now().millisecondsSinceEpoch,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupId: [],
      );

      await _database
          .child('Users')
          .child(auth.currentUser!.phoneNumber!)
          .child('info')
          .update({
        'name': username,
        'profile_picture': profileImageUrl,
        // Add other fields as needed
      });
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.loading,
        (route) => false,
      );
    } catch (e) {
      Navigator.pop(context);
      showAlertDialog(context: context, message: e.toString());
    }
  }

  void saveUserInfoToStorage({
    required String username,
    required var file,
    required ProviderRef ref,
    required BuildContext context,
    required bool mounted,
  }) async {
    try {
      showLoadingDialog(
        context: context,
        message: "Saving user info ... ",
      );
      String uid = auth.currentUser!.uid;
      String? phoneNumber = auth.currentUser!.phoneNumber;

     // String file = file is String ? file : '';
     
      var  profileImageUrl = await ref
            .read(firebaseStorageRepositoryProvider)
            .storeFileToFirebase(
                'Users/$phoneNumber/info/${Moment.now().millisecondsSinceEpoch}.jpg',
                file);
        print("$profileImageUrl");
        print(uid);
        print(Moment.now().millisecondsSinceEpoch);
        print(auth.currentUser!.phoneNumber!);
      
      Navigator.pop(context);

      if (!mounted) return profileImageUrl;
    } catch (e) {
      Navigator.pop(context);
      showAlertDialog(context: context, message: e.toString());
    }
  }

  void verifySmsCode({
    required BuildContext context,
    required String smsCodeId,
    required String smsCode,
    required bool mounted,
    required String phoneNumber,
  }) async {
    try {
      showLoadingDialog(
        context: context,
        message: 'Verifiying... ',
      );
      final credential = PhoneAuthProvider.credential(
        verificationId: smsCodeId,
        smsCode: smsCode,
      );
      await auth.signInWithCredential(credential);

      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('Users/${phoneNumber}/info').get();
      if (snapshot.exists) {
        // snapshot.children.forEach((DataSnapshot snapshot) {
        //   print("snap == ${snapshot.value}");
        // });

        await Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.userInfo,
          (route) => false,
          //arguments: user?.profileImageUrl,
        );
      } else {
        String result = await storeUserData(phoneNumber);
        print('Result: $result');
        if (result == 'Success') {
          await Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.userInfo,
            (route) => false,
            //arguments: user?.profileImageUrl,
          );
        }
      }

      if (!mounted) return;
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showAlertDialog(context: context, message: e.toString());
    }
  }

  void sendSmsCode({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    try {
      showLoadingDialog(
        context: context,
        message: "Sending a verification code to $phoneNumber",
      );
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          showAlertDialog(context: context, message: e.toString());
        },
        codeSent: (smsCodeId, resendSmsCodeId) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.varification,
            (route) => false,
            arguments: {
              'phoneNumber': phoneNumber,
              'smsCodeId': smsCodeId,
            },
          );
        },
        codeAutoRetrievalTimeout: (String smsCodeId) {},
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showAlertDialog(context: context, message: e.toString());
    }
  }
}
