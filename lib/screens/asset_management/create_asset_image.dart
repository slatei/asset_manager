import 'package:flutter/material.dart';

class CreateAssetImage extends StatefulWidget {
  const CreateAssetImage({super.key});

  @override
  State<CreateAssetImage> createState() => _CreateAssetImageState();
}

class _CreateAssetImageState extends State<CreateAssetImage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Add asset image"),
    );
  }
}
