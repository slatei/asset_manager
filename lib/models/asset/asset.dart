import 'package:asset_store/models/asset/category.dart';
import 'package:asset_store/models/asset/purchase.dart';
import 'package:asset_store/models/asset/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  Asset({
    required this.name,
    required String id,
    Purchase? purchase,
    AssetCategory? category,
    AssetRoom? room,
    List<String>? labels,
    String? notes,
  })  : _id = id,
        _purchase = purchase,
        _room = room,
        labels = labels ?? [],
        _notes = notes;

  String name;
  final String _id;
  Purchase? _purchase;
  AssetCategory? category;
  AssetRoom? _room;
  List<String>? labels;
  String? _notes;

  final DateTime _createdAt = DateTime.now();

  final List<String> _filePaths = [];

  // Getters
  String get id => _id;
  Purchase? get purchase => _purchase;
  AssetRoom? get room => _room;
  String? get notes => _notes;

  DateTime get createdAt => _createdAt;
  List<String> get filePaths => List.unmodifiable(_filePaths);

  void addFilePath(String path) {
    _filePaths.add(path);
  }

  @override
  String toString() {
    return {'id': _id, ...toFirestore()}.toString();
  }

  // List<XFile> getFilesFromStorage() {}

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "category": category.toString(),
      "room": room.toString(),
      "purchase": purchase?.asMap ?? {},
      "_createdAt": _createdAt.toIso8601String(),
      "_updatedAt": DateTime.now().toIso8601String(),
      "images": _filePaths.map((path) => path).toList(),
      "notes": notes,
      "labels": labels?.toList(),
    };
  }

  factory Asset.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;

    Asset asset = Asset(
      id: snapshot.id,
      name: data['name'],
      room: DefaultRooms.values.firstWhere((r) => r.name == data['room']).room,
      category: DefaultCategories.values
          .firstWhere((c) => c.toString() == data['category'])
          .category,
      purchase: data['purchase']
          ? Purchase(
              price: data['purchase']['price'],
              date: DateTime.parse(data['purchase']['date']),
              location: data['purchase']['location'],
            )
          : null,
      labels: data['labels'],
      notes: data['notes'],
    );

    for (String path in data['images']) {
      asset.addFilePath(path);
    }

    return asset;
  }

  // static double get totalCost =>
  //     _assets.fold(0.0, (assetSum, asset) => assetSum + asset.cost);
}

List<Asset> allAssets = [
  Asset(name: 'Fridge', id: "1234"),
  Asset(name: 'Bed', id: "2345"),
  Asset(name: 'Rug', id: "2345"),
];
