import 'package:asset_store/screens/asset_management/manage_asset_labels.dart';
import 'package:flutter/material.dart';

class ManageAssetImage extends StatefulWidget {
  const ManageAssetImage({
    super.key,
  });

  @override
  State<ManageAssetImage> createState() => _ManageAssetImageState();
}

class _ManageAssetImageState extends State<ManageAssetImage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Code to upload image
          },
          child: const Text('Upload Image'),
        ),
      ],
    );
  }
}
