import 'package:flutter/material.dart';

class CreateAssetImage extends StatefulWidget {
  const CreateAssetImage({
    super.key,
  });

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
      ],
    );
  }
}
