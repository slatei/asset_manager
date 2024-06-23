import 'package:asset_store/widgets/asset_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:asset_store/screens/asset_form.dart';
import 'package:asset_store/state/asset_state.dart';
import 'package:asset_store/state/auth_state.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
      body: Consumer<AssetState>(
        builder: (context, assetState, _) {
          final assets = assetState.assets;

          if (assets.isEmpty) {
            return const Center(child: Text('No assets found.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Assets: ${assets.length}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Cost: \$${assetState.totalCost.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assets.length,
                  itemBuilder: (context, index) {
                    final asset = assets[index];
                    return AssetCard(asset: asset);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addAsset',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssetForm(
                addAsset: (asset) =>
                    context.read<AssetState>().addAssetToDatabase(asset),
              ),
            ),
          );
        },
        tooltip: 'Add Asset',
        child: const Icon(Icons.add),
      ),
    );
  }
}
