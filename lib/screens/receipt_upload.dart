import 'package:flutter/material.dart';

class ReceiptUpload extends StatelessWidget {
  const ReceiptUpload({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Receipt'),
      ),
      body: const Center(
        child: Text('Receipt Upload Screen'),
      ),
    );
  }
}
