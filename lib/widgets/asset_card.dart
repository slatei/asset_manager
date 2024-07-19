import 'package:asset_store/models/asset_orig.dart';
import 'package:flutter/material.dart';

class AssetCard extends StatelessWidget {
  final AssetOriginal asset;

  const AssetCard({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(asset.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${asset.category}'),
            Text('Purchase Date: ${asset.purchaseDate}'),
            Text('Cost: \$${asset.cost.toStringAsFixed(2)}'),
          ],
        ),
        trailing: asset.photoPath != null
            ? Image.network(asset.photoPath!)
            : const Icon(Icons.image_not_supported),
      ),
    );
  }
}
