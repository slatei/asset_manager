import 'package:asset_store/shared/styled_text.dart';
import 'package:flutter/material.dart';

class AssetListItem extends StatelessWidget {
  const AssetListItem(
      {required this.icon,
      required this.name,
      this.date,
      this.price,
      super.key});

  final IconData icon;
  final String name;
  final DateTime? date;
  final double? price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Icon
            Icon(icon),

            const SizedBox(width: 16),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (date != null) StyledDate(date!)
              ],
            ),

            const Expanded(child: SizedBox()),

            // Price
            if (price != null)
              StyledPrice(
                price!,
                style: Theme.of(context).textTheme.labelSmall,
              )
          ],
        ),
      ),
    );
  }
}
