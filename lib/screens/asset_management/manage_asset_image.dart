import 'dart:io';
import 'package:asset_store/models/asset/asset.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ManageAssetImage extends StatefulWidget {
  const ManageAssetImage({
    super.key,
    required this.asset,
    required this.onUpdate,
    required this.imagePicker,
  });

  final Asset asset;
  final void Function(Asset updatedAsset) onUpdate;
  final ImagePicker imagePicker;

  @override
  State<ManageAssetImage> createState() => _ManageAssetImageState();
}

class _ManageAssetImageState extends State<ManageAssetImage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Asset localAsset;

  XFile? _imageFile;

  @override
  void initState() {
    super.initState();

    // Initialize the local asset with the passed-in asset
    localAsset = widget.asset;
  }

  Future<void> _pickImage() async {
    try {
      _imageFile =
          await widget.imagePicker.pickImage(source: ImageSource.gallery);
      if (_imageFile != null) {
        setState(() {
          localAsset.addFile(_imageFile!);
        });
        widget.onUpdate(localAsset);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      localAsset.removeFile(_imageFile!);
      _imageFile = null;
    });
    widget.onUpdate(localAsset);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Upload Image'),
        ),
        const SizedBox(height: 40),
        if (_imageFile != null) ...[
          kIsWeb
              ? Image.network(_imageFile!.path, height: 200)
              : Image.file(File(_imageFile!.path), height: 200),
          ElevatedButton(
            onPressed: _removeImage,
            child: const Text('Remove'),
          ),
        ]
      ],
    );
  }
}
