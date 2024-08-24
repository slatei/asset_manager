import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/services/firestore_service.dart';
import 'package:asset_store/services/storage_service.dart';
import 'package:flutter/foundation.dart';

const assetsCollection = 'assets';

class AssetStore extends ChangeNotifier {
  final List<Asset> _assets = [];
  List<Asset> get assets => _assets;

  void addAsset(Asset asset) async {
    await FirebaseStorageService.addAssetFiles(asset);
    FirestoreService.addAsset(asset);

    _assets.add(asset);
    notifyListeners();
  }

  // Future<void> saveAsset(Asset asset) async {
  //   await FirestoreService.updateAsset(asset);
  //   return;
  // }

  void removeAsset(Asset asset) async {
    await FirestoreService.deleteAsset(asset);

    _assets.remove(asset);
    notifyListeners();
  }

  void fetchAssetsOnce() async {
    if (assets.isEmpty) {
      final snapshot = await FirestoreService.getAssetsOnce();

      for (var doc in snapshot.docs) {
        _assets.add(doc.data());
      }

      notifyListeners();
    }
  }
}
