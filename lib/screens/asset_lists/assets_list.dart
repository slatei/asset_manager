import 'package:asset_store/models/asset/category.dart';
import 'package:asset_store/screens/asset_lists/asset_header.dart';
import 'package:asset_store/screens/asset_lists/asset_list_item.dart';
import 'package:asset_store/screens/asset_management/manage_asset.dart';
import 'package:asset_store/services/asset_store.dart';
import 'package:asset_store/shared/bottom_bar_mixin.dart';
import 'package:asset_store/shared/styled_bottom_bar.dart';
import 'package:asset_store/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssetsList extends StatefulWidget {
  const AssetsList({super.key});

  @override
  State<AssetsList> createState() => _AssetsListState();
}

class _AssetsListState extends State<AssetsList> with BottomAppBarMixin {
  @override
  void initState() {
    Provider.of<AssetStore>(
      context,
      listen: false,
    ).fetchAssetsOnce();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      // Top app bar and title
      appBar: AppBar(
        title: const Text('Assets List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authState.signOut(() {
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              });
            },
          ),
        ],
      ),

      // Bottom App Bar and add-asset button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageAsset(),
            ),
          );
        },
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
              child: Consumer<AssetStore>(builder: (context, value, child) {
                return ListView.builder(
                  itemCount: value.assets.length,
                  itemBuilder: (_, index) {
                    return AssetListItem(
                      asset: value.assets[index],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
