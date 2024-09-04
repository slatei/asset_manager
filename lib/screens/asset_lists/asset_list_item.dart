import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/screens/asset_management/manage_asset.dart';
import 'package:asset_store/shared/styled_text.dart';
import 'package:flutter/material.dart';

class AssetListItem extends StatelessWidget {
  const AssetListItem({
    required this.asset,
    super.key,
  });

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    // Inkwell gives us visual feedback when clicking on the item
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ManageAsset(asset: asset),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Icon
              Icon(
                asset.category?.icon != null
                    ? asset.category!.icon!
                    : Icons.question_mark_rounded,
              ),

              const SizedBox(width: 16),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (asset.purchase?.date != null)
                    StyledDate(asset.purchase!.date!)
                ],
              ),

              const Expanded(child: SizedBox()),

              // Price
              if (asset.purchase?.price != null)
                StyledPrice(
                  asset.purchase!.price!,
                  style: Theme.of(context).textTheme.labelSmall,
                )
            ],
          ),
        ),
      ),
    );
  }
}
