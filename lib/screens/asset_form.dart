import 'dart:async';
import 'package:flutter/material.dart';

import 'package:asset_store/models/asset.dart';

class AssetForm extends StatefulWidget {
  const AssetForm({required this.addAsset, super.key});

  final FutureOr<void> Function(Asset asset) addAsset;

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');

  String? _name;
  String? _category;
  String? _purchaseDate;
  double? _cost;
  String? _photoPath;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final asset = Asset(
        name: _name!,
        category: _category!,
        purchaseDate: _purchaseDate!,
        cost: _cost!,
        photoPath: _photoPath,
      );

      await widget.addAsset(asset);

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
            TextFormField(
              decoration: const InputDecoration(labelText: 'Photo Path'),
              onSaved: (value) {
                _photoPath = value;
              },
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
