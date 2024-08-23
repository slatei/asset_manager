import 'package:asset_store/models/asset/category.dart';
import 'package:asset_store/models/asset/purchase.dart';
import 'package:asset_store/models/asset/room.dart';
import 'package:asset_store/shared/hashed_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
        _room = room,
        labels = labels ?? [],
        _notes = notes;

  String name;
  final String _id;
  Purchase? purchase = Purchase();
  AssetCategory? category;
  AssetRoom? _room;
  List<String>? labels;
  String? _notes;

  final DateTime _createdAt = DateTime.now();
  final List<HashedFile> _files = [];

  // Getters
  String get id => _id;
  AssetRoom? get room => _room;
  String? get notes => _notes;

  DateTime get createdAt => _createdAt;

  List<HashedFile> get files => List.unmodifiable(_files);

  // Setters
  Future<void> addFile(XFile file) async {
    final hashedFile = await HashedFile.fromXFile(file);

    // Check if the file is already in the list based on its hash
    if (!_files.any((existingFile) => existingFile.hash == hashedFile.hash)) {
      _files.add(hashedFile);
    }
  }

  void removeFile(XFile file) async {
    final hashedFile = await HashedFile.fromXFile(file);
    _files.removeWhere((existingFile) => existingFile.hash == hashedFile.hash);
  }

  @override
  String toString() {
    return {'id': _id, ...toFirestore()}.toString();
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "category": category.toString(),
      "room": room.toString(),
      "purchase": purchase?.asMap ?? {},
      "_createdAt": _createdAt.toIso8601String(),
      "_updatedAt": DateTime.now().toIso8601String(),
      "images": _files.map((file) => file.path).toList(),
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

    // for (String path in data['images']) {
    //   asset.addFile(path);
    // }

    return asset;
  }
}
