import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:asset_store/models/asset.dart';

const assetsCollection = 'assets';

class AssetState extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  List<Asset> _assets = [];
  List<Asset> get assets => _assets;

  AssetState(
      {required this.firestore, required this.auth, required this.storage}) {
    _listenToAssets();
  }

  void _listenToAssets() {
    firestore.collection('assets').snapshots().listen((snapshot) {
      _assets = snapshot.docs.map((doc) => Asset.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  Future<DocumentReference> addAssetToDatabase(Asset asset,
      {File? imageFile, Uint8List? imageBytes}) async {
    String? photoUrl;

    if ((kIsWeb && imageBytes != null) || (!kIsWeb && imageFile != null)) {
      try {
        final ref = storage
            .ref()
            .child(assetsCollection)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        if (kIsWeb) {
          await ref.putData(imageBytes!);
        } else {
          await ref.putFile(imageFile!);
        }

        photoUrl = await ref.getDownloadURL();
      } on FirebaseException catch (e) {
        if (kDebugMode) {
          print("Error uploading image: ${e.message}");
        }
      }
    }

    return firestore.collection(assetsCollection).add(<String, dynamic>{
      'name': asset.name,
      'category': asset.category,
      'purchaseDate': asset.purchaseDate,
      'cost': asset.cost,
      'photoPath': photoUrl,
      'labels': asset.labels,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'owner': auth.currentUser!.displayName,
      'userId': auth.currentUser!.uid,
    });
  }

  double get totalCost =>
      _assets.fold(0.0, (assetSum, asset) => assetSum + asset.cost);
}
