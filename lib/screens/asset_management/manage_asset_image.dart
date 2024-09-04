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

  final List<XFile> _imageFiles = [];
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
        _imageFiles.add(_imageFile!);
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

  Future<void> _removeImage(image) async {
    setState(() {
      localAsset.removeFile(image);
      _imageFiles.removeWhere((i) => i.hashCode == image.hashCode);
    });
    widget.onUpdate(localAsset);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // Add images button
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Upload Image'),
        ),

        // Display all uploaded images
        if (_imageFiles.isNotEmpty) ...[
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 images per row
              crossAxisSpacing: 10, // Horizontal spacing between images
              mainAxisSpacing: 10, // Vertical spacing between images
              childAspectRatio: 1, // Square cells
            ),
            // GridView.builder with NeverScrollableScrollPhysics:
            // This prevents the GridView from scrolling independently since it's
            // inside another scrollable widget.
            physics: const NeverScrollableScrollPhysics(),
            // shrinkWrap: true: This makes sure the GridView only takes up as
            // much space as it needs, avoiding conflicts with the parent scroll view.
            shrinkWrap:
                true, // Make GridView take up only as much space as needed
            itemCount: _imageFiles.length,
            itemBuilder: (BuildContext context, int index) {
              final image = _imageFiles[index];
              return ImageBox(
                image: image,
                onRemove: (image) => _removeImage(image),
              );
            },
          ),
        ],
      ],
    );
  }
}

class ImageBox extends StatelessWidget {
  const ImageBox({
    required this.image,
    required this.onRemove,
    super.key,
  });

  final XFile image;
  final void Function(XFile image) onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        kIsWeb
            ? Image.network(image.path, height: 200)
            : Image.file(File(image.path), height: 200),
        Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () => onRemove(image),
            )),
      ],
    );
  }
}
