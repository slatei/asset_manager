import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';

class HashedFile extends XFile {
  final String hash;
  String? url;

  HashedFile({
    required String path,
    required this.hash,
    this.url,
  }) : super(path);

  // Factory constructor to create a HashedFile from an XFile
  static Future<HashedFile> fromXFile(XFile file) async {
    final hash = await _computeFileHash(file);
    return HashedFile(path: file.path, hash: hash);
  }

  // Helper function to compute the hash of a file's contents
  static Future<String> _computeFileHash(XFile file) async {
    final bytes = await File(file.path).readAsBytes();
    final hash = sha1.convert(bytes); // Use SHA-1 hash
    return hash.toString();
  }
}
