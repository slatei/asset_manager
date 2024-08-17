import 'package:asset_store/screens/asset_management/asset_buttons.dart';
import 'package:flutter/material.dart';

class CreateAssetImage extends StatefulWidget {
  const CreateAssetImage({
    required this.tabController,
    super.key,
  });

  final TabController tabController;

  @override
  State<CreateAssetImage> createState() => _CreateAssetImageState();
}

class _CreateAssetImageState extends State<CreateAssetImage>
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
        const SizedBox(height: 400),
        AssetButtons(
          tabController: widget.tabController,
          add: () {},
        ),
      ],
    );
  }
}
