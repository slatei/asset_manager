import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/asset.dart';
import '../widgets/asset_card.dart';
import './asset_form.dart';
import './receipt_upload.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: FutureBuilder<List<Asset>>(
        future: apiService.fetchAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Debug print
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
                      print('Asset: ${asset.toJson()}'); // Debug print
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
          FloatingActionButton(
            heroTag: 'addAsset',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssetForm()),
              );
            },
            tooltip: 'Add Asset',
            child: const Icon(Icons.add),
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
