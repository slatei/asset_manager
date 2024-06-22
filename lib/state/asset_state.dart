import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:asset_store/models/asset.dart';

class AssetState extends ChangeNotifier {
  Future<DocumentReference> addAssetToDatabase(Asset asset) {
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
}
