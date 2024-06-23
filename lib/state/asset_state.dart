import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:asset_store/models/asset.dart';

class AssetState extends ChangeNotifier {
  List<Asset> _assets = [];
  List<Asset> get assets => _assets;

  AssetState() {
    _listenToAssets();
  }

  void _listenToAssets() {
    FirebaseFirestore.instance
        .collection('assets')
        .snapshots()
        .listen((snapshot) {
      _assets = snapshot.docs.map((doc) {
        final data = doc.data();
        return Asset.fromJson(data);
      }).toList();
      notifyListeners();
    });
  }

  Future<DocumentReference> addAssetToDatabase(Asset asset) async {
    return FirebaseFirestore.instance
        .collection('assets')
        .add(<String, dynamic>{
      'name': asset.name,
      'category': asset.category,
      'purchaseDate': asset.purchaseDate,
      'cost': asset.cost,
      'photoPath': asset.photoPath,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'owner': FirebaseAuth.instance.currentUser!.displayName,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });
  }

  double get totalCost =>
      _assets.fold(0.0, (assetSum, asset) => assetSum + asset.cost);
}
