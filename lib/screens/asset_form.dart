import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:asset_store/models/asset.dart';

class AssetForm extends StatefulWidget {
  const AssetForm({required this.addAsset, super.key});

  final FutureOr<void> Function(Asset asset,
      {File? imageFile, Uint8List? imageBytes}) addAsset;

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _imageUrl;

  String? _name;
  String? _category;
  String? _purchaseDate;
  double? _cost;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
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
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final asset = Asset(
        name: _name!,
        category: _category!,
        purchaseDate: _purchaseDate!,
        cost: _cost!,
      );

      if (kIsWeb) {
        await widget.addAsset(asset, imageBytes: _imageBytes);
      } else {
        await widget.addAsset(asset, imageFile: _imageFile);
      }

      setState(() {
        _imageFile = null;
        _imageBytes = null;
        _imageUrl = null;
      });
      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                _name = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Category'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
              onSaved: (value) {
                _category = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Purchase Date'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a purchase date';
                }
                return null;
              },
              onSaved: (value) {
                _purchaseDate = value;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a cost';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              onSaved: (value) {
                _cost = double.parse(value!);
              },
            ),
            const SizedBox(height: 20),
            if (_imageFile != null || _imageUrl != null)
              kIsWeb
                  ? Image.network(_imageUrl!, height: 200)
                  : Image.file(_imageFile!, height: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Receipt'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save Asset'),
            ),
          ]),
        ),
      ),
    );
  }
}
