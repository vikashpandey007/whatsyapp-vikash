import 'package:WhatsYapp/Dependencies/Auth/auth_repository.dart';
import 'package:WhatsYapp/dependencies/models/model_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userInfoAuthProvider = FutureProvider(
  (ref) {
    final authController = ref.watch(authControllerProvider);
    return authController.getCurrentUserInfo();
  },
);

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;

  AuthController({required this.authRepository, required this.ref});

  Stream<UserModel> getUserPresenceStatus({required String uid}) {
    return getUserPresenceStatus(uid: uid);
  }

  Stream<UserModel> getAllOneToOneMessage(
    String uid,
  ) {
    return getAllOneToOneMessage(uid);
  }

  void updateUserPresence() {
    authRepository.updateUserPresence();
  }

  Future<UserModel?> getCurrentUserInfo() async {
    UserModel? user = await getCurrentUserInfo();
    return user;
  }

  void saveUserInfoToFirestore({
    required String username,
    required var profileImage,
    required BuildContext context,
    required bool mounted,
  }) {
    authRepository.saveUserInfoToFirestore(
      username: username,
      profileImage: profileImage,
      ref: ref,
      context: context,
      mounted: mounted,
    );
  }

  void verifySmsCode({
    required BuildContext context,
    required String smsCodeId,
    required String smsCode,
    required bool mounted,
    required String phoneNumber,
  }) {
    authRepository.verifySmsCode(
      context: context,
      smsCodeId: smsCodeId,
      smsCode: smsCode,
      mounted: mounted,
      phoneNumber: phoneNumber,
    );
  }

  void sendSmsCode({
    required BuildContext context,
    required String phoneNumber,
  }) {
    authRepository.sendSmsCode(context: context, phoneNumber: phoneNumber);
  }
}
