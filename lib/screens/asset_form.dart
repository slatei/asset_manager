import 'dart:async';
import 'dart:io';
import 'package:asset_store/widgets/asset_form/add_category_dialog.dart';
import 'package:asset_store/widgets/asset_form/asset_form_fields.dart';
import 'package:asset_store/widgets/image_picker_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:asset_store/models/asset.dart';
import 'package:asset_store/state/categories_state.dart';

class AssetForm extends StatefulWidget {
  final FutureOr<void> Function(Asset asset,
      {File? imageFile, Uint8List? imageBytes}) addAsset;
  final ImagePicker imagePicker;

  const AssetForm({
    required this.addAsset,
    required this.imagePicker,
    super.key,
  });

  @override
  State<AssetForm> createState() => _AssetFormState();
}

class _AssetFormState extends State<AssetForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_AssetFormState');
  File? _imageFile;
  Uint8List? _imageBytes;

  String? _name;
  String? _category;
  String? _purchaseDate;
  double? _cost;

  @override
  void initState() {
    super.initState();
    final categoriesState =
        Provider.of<CategoriesState>(context, listen: false);
    categoriesState.fetchCategories();
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
      });
      _formKey.currentState?.reset();
    }
  }

  void _addNewCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddCategoryDialog(
          onCategoryAdded: (newCategory) {
            setState(() {
              _category = newCategory;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            AssetFormFields(
              formKey: _formKey,
              onNameSaved: (value) {
                _name = value;
              },
              onCategorySaved: (value) {
                setState(() {
                  _category = value;
                });
              },
              onPurchaseDateSaved: (value) {
                _purchaseDate = value;
              },
              onCostSaved: (value) {
                _cost = value;
              },
              selectedCategory: _category,
              onAddNewCategory: _addNewCategory,
            ),
            const SizedBox(height: 20),
            ImagePickerWidget(
              imagePicker: widget.imagePicker,
              onImagePicked: (file, bytes, url) {
                setState(() {
                  _imageFile = file;
                  _imageBytes = bytes;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Save Asset'),
            ),
          ],
        ),
      ),
    );
  }
}
