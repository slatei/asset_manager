import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/models/asset/category.dart';
import 'package:asset_store/models/asset/purchase.dart';
import 'package:asset_store/screens/lists/asset_header.dart';
import 'package:asset_store/screens/lists/asset_list_item.dart';
import 'package:flutter/material.dart';

class AssetsList extends StatefulWidget {
  const AssetsList({super.key});

  @override
  State<AssetsList> createState() => _AssetsListState();
}

class _AssetsListState extends State<AssetsList> {
  late List<Asset> assetsList;

  @override
  void initState() {
    assetsList = [
      Asset(
        id: '1',
        name: 'Guitar',
        purchase: Purchase(
          price: 12332.3432,
          date: DateTime(2022, 1, 1),
        ),
        category: DefaultCategories.music.category,
      ),
      Asset(
        id: '2',
        name: 'Camera',
        purchase: Purchase(
          price: 840.98,
          date: DateTime(2022, 3),
        ),
      ),
      Asset(
        id: '3',
        name: 'Easel  ',
        purchase: Purchase(
          price: 132.22,
          date: DateTime(2022),
        ),
        category: DefaultCategories.art.category,
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              children: [
                // Header
                AssetHeader(
                  label: DefaultCategories.books.category.name,
                  labelIcon: DefaultCategories.books.category.icon!,
                  price: 12342.234,
                ),

                // Separator bar
                const SizedBox(height: 20),
                const Divider(
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 20),

                // Assets List
                Column(
                  children: assetsList.map((asset) {
                    return AssetListItem(
                      name: asset.name,
                      icon: asset.category?.icon != null
                          ? asset.category!.icon!
                          : Icons.question_mark_rounded,
                      date: asset.purchase?.date,
                      price: asset.purchase?.price,
                    );
                  }).toList(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
