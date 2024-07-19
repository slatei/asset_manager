import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class AssetImage {
  final XFile file;
  late String? _url;
  late Uint8List? _bytes;

  String? get url => _url;
  Uint8List? get bytes => _bytes;

  AssetImage._create(this.file) {
    _url = file.path;
  }

  _asyncInit() async {
    _bytes = await file.readAsBytes();
  }

  // Public factory
  // Usage:
  //    AssetImage img = await AssetImage.create(file);
  static Future<AssetImage> create(XFile file) async {
    var component = AssetImage._create(file);
    await component._asyncInit();
    return component;
  }
}
