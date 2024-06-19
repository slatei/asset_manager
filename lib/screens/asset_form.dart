import 'package:flutter/material.dart';

class AssetForm extends StatelessWidget {
  const AssetForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset'),
      ),
      body: const Center(
        child: Text('Asset Form Screen'),
      ),
    );
  }
}
