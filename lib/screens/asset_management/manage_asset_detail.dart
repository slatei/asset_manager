import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/models/asset/category.dart';
import 'package:asset_store/screens/asset_management/category_dropdown.dart';
import 'package:asset_store/screens/asset_management/date_picker.dart';
import 'package:asset_store/screens/asset_management/manage_asset_labels.dart';
import 'package:flutter/material.dart';

class ManageAssetDetail extends StatefulWidget {
  const ManageAssetDetail({
    required this.asset,
    required this.onUpdate,
    super.key,
  });

  final Asset asset;
  final void Function(Asset updatedAsset) onUpdate;

  @override
  State<ManageAssetDetail> createState() => _ManageAssetDetailState();
}

class _ManageAssetDetailState extends State<ManageAssetDetail>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Asset localAsset;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  List<String> labels = ['Flutter', 'Dart'];

  @override
  void initState() {
    super.initState();

    // Initialize the local asset with the passed-in asset
    localAsset = widget.asset;

    // Add listeners to update the local asset and notify the parent
    _nameController.addListener(_updateName);
    _priceController.addListener(_updatePrice);
  }

  void _updateName() {
    setState(() {
      localAsset.name = _nameController.text;
    });
    widget.onUpdate(localAsset);
  }

  void _updatePrice() {
    setState(() {
      localAsset.purchase?.price = double.parse(_priceController.text);
    });
    widget.onUpdate(localAsset);
  }

  void _updateCategory(DefaultCategories? selectedCategory) {
    setState(() {
      localAsset.category = selectedCategory?.category;
    });
    widget.onUpdate(localAsset);
  }

  void _updateDate(DateTime? dateTime) {
    setState(() {
      localAsset.purchase?.date = dateTime;
    });
    widget.onUpdate(localAsset);
  }

  void _updateLabels(List<String> updatedLabels) {
    setState(() {
      labels = updatedLabels;
      localAsset.labels = updatedLabels;
    });
    widget.onUpdate(localAsset);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        // Primary data entry
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Asset name
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_2),
                  label: Text('Name'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Asset category
              CategoryDropdown(
                onChanged: _updateCategory,
              ),
              const SizedBox(height: 20),

              // Asset date
              AssetDatePicker(onChanged: _updateDate),
              const SizedBox(height: 20),

              // Asset price
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  label: Text('Price'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        const Divider(
          indent: 20,
          endIndent: 20,
        ),

        ManageAssetLabels(
          labels: labels,
          onLabelsChanged: _updateLabels,
        ),

        const Divider(
          indent: 20,
          endIndent: 20,
        )
      ],
    );
  }
}
