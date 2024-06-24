import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:asset_store/models/asset.dart';

const assetsCollection = 'assets';

class AssetState extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  List<Asset> _assets = [];
  List<Asset> get assets => _assets;

  AssetState({required this.firestore, required this.auth}) {
    _listenToAssets();
  }

  void _listenToAssets() {
    firestore.collection('assets').snapshots().listen((snapshot) {
      _assets = snapshot.docs.map((doc) => Asset.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  Future<DocumentReference> addAssetToDatabase(Asset asset) async {
    return firestore.collection(assetsCollection).add(<String, dynamic>{
      'name': asset.name,
      'category': asset.category,
      'purchaseDate': asset.purchaseDate,
      'cost': asset.cost,
      'photoPath': asset.photoPath,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'owner': auth.currentUser!.displayName,
      'userId': auth.currentUser!.uid,
    });
  }

  double get totalCost =>
      _assets.fold(0.0, (assetSum, asset) => assetSum + asset.cost);
}
