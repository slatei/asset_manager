import 'package:flutter/material.dart';

class AssetHeader extends StatelessWidget {
  const AssetHeader({required this.label, required this.labelIcon, required this.value, super.key});

  final String label;
  final IconData labelIcon;
  final double value;

  @override
  Widget build(BuildContext context) {
    // Category Description
    return Column(
      children: [
        // Category Description
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          // Category/Room
          child: Row(
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Icon(labelIcon),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(label),
                ],
              ),
            ],
          ),
        ),

        // Total Value
        Container(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(6))),
          // Category/Room
          child: Row(
            children: [
              const SizedBox(
                height: 40,
                width: 40,
                child: Icon(Icons.attach_money),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text("\$${value.toStringAsFixed(2)}"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
