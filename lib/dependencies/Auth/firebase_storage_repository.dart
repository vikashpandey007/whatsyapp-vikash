import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moment_dart/moment_dart.dart';

final firebaseStorageRepositoryProvider = Provider(
  (ref) {
    return FirebaseStorageRepository(firebaseStorage: FirebaseStorage.instance);
  },
);

class FirebaseStorageRepository {
  final FirebaseStorage firebaseStorage;

  FirebaseStorageRepository({required this.firebaseStorage});

  storeFileToFirebase(String ref, var file) async {
    UploadTask? uploadTask;
    if (file is File) {
      uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    }
    if (file is Uint8List) {
      uploadTask = firebaseStorage.ref().child(ref).putData(file);
    }

    TaskSnapshot snapshot = await uploadTask!;
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }
}

class firebaseStorage {
  storeFileToStorage(file) async {
    String videoName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child(
          '/Conversations/conversation_id/$videoName${Moment.now().millisecondsSinceEpoch}.mp4',
        );
    UploadTask uploadTask = storageReference.putFile(file!);
    TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});

    // Get the download URL
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
