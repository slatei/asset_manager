import 'package:asset_store/screens/asset_management/manage_asset_labels.dart';
import 'package:flutter/material.dart';

class ManageAssetDetail extends StatefulWidget {
  const ManageAssetDetail({
    super.key,
  });

  @override
  State<ManageAssetDetail> createState() => _ManageAssetDetailState();
}

class _ManageAssetDetailState extends State<ManageAssetDetail>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();

  List<String> labels = ['Flutter', 'Dart'];
  void _updateLabels(List<String> updatedLabels) {
    setState(() {
      labels = updatedLabels;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
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
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded),
                  label: Text('Category'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Asset date
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Date'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Asset price
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  label: Text('Category'),
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
