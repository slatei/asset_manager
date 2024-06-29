import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final ImagePicker imagePicker;
  final Function(File?, Uint8List?, String?) onImagePicked;

  const ImagePickerWidget({
    required this.imagePicker,
    required this.onImagePicked,
    super.key,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageUrl;

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await widget.imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageBytes = bytes;
            _imageUrl = pickedFile.path;
          });
        } else {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
        widget.onImagePicked(_imageFile, _imageBytes, _imageUrl);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_imageFile != null || _imageUrl != null)
          kIsWeb
              ? Image.network(_imageUrl!, height: 200)
              : Image.file(_imageFile!, height: 200),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Upload Image'),
        ),
      ],
    );
  }
}
