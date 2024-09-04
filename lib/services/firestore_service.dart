import 'package:asset_store/models/asset/asset.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final ref =
      FirebaseFirestore.instance.collection('assets-beta').withConverter(
            fromFirestore: Asset.fromFirestore,
            toFirestore: (Asset a, _) => a.toFirestore(),
          );

  static Future<void> addAsset(Asset asset) async {
    await ref.doc(asset.id).set(asset);
  }

  static Future<QuerySnapshot<Asset>> getAssetsOnce() {
    return ref.get();
  }

  static Future<void> updateAsset(Asset asset) async {
    await ref.doc(asset.id).set(asset, SetOptions(merge: true));
  }

  // delete asset
  static Future<void> deleteAsset(Asset asset) async {
    await ref.doc(asset.id).delete();
  }
}
