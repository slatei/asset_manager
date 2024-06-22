import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:asset_store/models/asset.dart';
import 'package:asset_store/screens/asset_form.dart';
import 'package:asset_store/screens/receipt_upload.dart';
import 'package:asset_store/services/api_service.dart';
import 'package:asset_store/widgets/asset_card.dart';
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
    final apiService = Provider.of<ApiService>(context);
    final authState = Provider.of<AuthState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authState.signOut(() {
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Asset>>(
        future: apiService.fetchAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No assets found.'));
          } else {
            final assets = snapshot.data!;
            final totalCost =
                assets.fold(0.0, (sum, asset) => sum + asset.cost);

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
                      'Total Cost: \$${totalCost.toStringAsFixed(2)}',
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
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Consumer<AssetState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FloatingActionButton(
                  heroTag: 'addAsset',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AssetForm(
                                addAsset: (asset) =>
                                    appState.addAssetToDatabase(asset),
                              )),
                    );
                  },
                  tooltip: 'Add Asset',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'uploadReceipt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReceiptUpload()),
              );
            },
            tooltip: 'Upload Receipt',
            child: const Icon(Icons.upload),
          ),
        ],
      ),
    );
  }
}
