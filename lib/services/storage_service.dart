import 'dart:io';
import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/shared/hashed_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static Future<void> addAssetFiles(Asset asset) async {
    if (asset.files.isNotEmpty) {
      try {
        for (HashedFile file in asset.files) {
          final ref =
              FirebaseStorage.instance.ref().child('assets').child(file.hash);

          // Check if the file already exists
          String? existingUrl;
          try {
            existingUrl = await ref.getDownloadURL();
          } catch (e) {
            if (e is FirebaseException && e.code == 'object-not-found') {
              existingUrl = null;
            } else {
              rethrow;
            }
          }

          if (existingUrl != null) {
            file.url = existingUrl; // Use existing URL
          } else {
            // Upload new file
            if (kIsWeb) {
              await ref.putData(await file.readAsBytes());
            } else {
              await ref.putFile(File(file.path));
            }
            file.url = await ref.getDownloadURL();
          }
        }
      } on FirebaseException catch (e) {
        if (kDebugMode) {
          print("Error uploading image: ${e.message}");
        }
      }
    }
  }
}
