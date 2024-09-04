import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/services/firestore_service.dart';
import 'package:asset_store/services/storage_service.dart';
import 'package:flutter/foundation.dart';

const assetsCollection = 'assets';

class AssetStore extends ChangeNotifier {
  final List<Asset> _assets = [];
  List<Asset> get assets => _assets;

  void putAssetInState(Asset asset) {
    // Find the index of the existing asset, if it exists
    int index = _assets.indexWhere((a) => a.id == asset.id);

    if (index != -1) {
      // If the asset exists, update it
      _assets[index] = asset;
    } else {
      // If the asset doesn't exist, add it to the list
      _assets.add(asset);
    }
  }

  void addAsset(Asset asset) async {
    await FirebaseStorageService.addAssetFiles(asset);
    FirestoreService.addAsset(asset);

    _assets.add(asset);
    notifyListeners();
  }

  Future<void> saveAsset(Asset asset) async {
    await FirebaseStorageService.addAssetFiles(asset);
    FirestoreService.updateAsset(asset);

    putAssetInState(asset);

    notifyListeners();
    return;
  }

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
