import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/models/asset/category.dart';
import 'package:asset_store/models/asset/purchase.dart';
import 'package:asset_store/screens/asset_lists/asset_header.dart';
import 'package:asset_store/screens/asset_lists/asset_list_item.dart';
import 'package:asset_store/shared/bottom_bar_mixin.dart';
import 'package:asset_store/shared/styled_bottom_bar.dart';
import 'package:flutter/material.dart';

class AssetsList extends StatefulWidget {
  const AssetsList({super.key});

  @override
  State<AssetsList> createState() => _AssetsListState();
}

class _AssetsListState extends State<AssetsList> with BottomAppBarMixin {
  static List<Asset> assetsList = <Asset>[
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
      name: 'Easel',
      purchase: Purchase(
        price: 132.22,
        date: DateTime(2022),
      ),
      category: DefaultCategories.art.category,
    ),
    Asset(
      id: '4',
      name: 'Clothes Rack',
      purchase: Purchase(
        price: 28.00,
        date: DateTime(2023),
      ),
      category: DefaultCategories.clothing.category,
    ),
    Asset(
      id: '5',
      name: 'Cat Bed',
      purchase: Purchase(
        price: 12.13,
        date: DateTime(2023, 11, 4),
      ),
      category: DefaultCategories.pets.category,
    ),
    Asset(
      id: '6',
      name: 'Rug',
      purchase: Purchase(
        price: 358.99,
        date: DateTime(2024),
      ),
      category: DefaultCategories.fixture.category,
    ),
    Asset(
      id: '7',
      name: 'Couch',
      purchase: Purchase(
        price: 0.0,
        date: DateTime(2013),
      ),
      category: DefaultCategories.furniture.category,
    ),
    Asset(
      id: '8',
      name: 'Cat Tower',
      purchase: Purchase(
        price: 240.00,
        date: DateTime(2024, 1, 3),
      ),
      category: DefaultCategories.pets.category,
    ),
    Asset(
      id: '9',
      name: 'TV',
      purchase: Purchase(
        price: 899.99,
        date: DateTime(2023),
      ),
      category: DefaultCategories.electronics.category,
    ),
    Asset(
      id: '10',
      name: 'Pillows',
      purchase: Purchase(
        price: 38.80,
        date: DateTime(2024, 2, 2),
      ),
      category: DefaultCategories.furniture.category,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top app bar and title
      appBar: AppBar(
        title: const Text('Assets List'),
        centerTitle: true,
      ),

      // Bottom App Bar and add-asset button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add New Item',
        elevation: appBarIsVisible ? 0.0 : null,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: appBarFabLocation,
      bottomNavigationBar: StyledBottomAppBar(
        isVisible: appBarIsVisible,
      ),

      // main view window and assets list
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: <Widget>[
            AssetHeader(
              label: DefaultCategories.books.category.name,
              labelIcon: DefaultCategories.books.category.icon!,
              price: 12342.234,
            ),

            // Separator bar
            const Padding(
              padding: EdgeInsets.all(10),
              child: Divider(
                indent: 20,
                endIndent: 20,
              ),
            ),

            // Assets List
            Expanded(
              child: ListView(
                controller: appBarController,
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
            ),
          ],
        ),
      ),
    );
  }
}
