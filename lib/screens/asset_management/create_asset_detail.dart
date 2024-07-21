import 'package:flutter/material.dart';

class CreateAssetDetail extends StatefulWidget {
  const CreateAssetDetail({super.key});

  @override
  State<CreateAssetDetail> createState() => _CreateAssetDetailState();
}

class _CreateAssetDetailState extends State<CreateAssetDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: <Widget>[
          // Primary data entry
          const Text('Name'),
          const Text('Category'),
          const Text('Price'),

          // Separator bar
          const Padding(
            padding: EdgeInsets.all(10),
            child: Divider(
              indent: 20,
              endIndent: 20,
            ),
          ),

          const Text('Labels'),

          // Separator bar
          const Padding(
            padding: EdgeInsets.all(10),
            child: Divider(
              indent: 20,
              endIndent: 20,
            ),
          ),

          const Expanded(child: SizedBox()),

          TextButton(onPressed: () {}, child: const Text('Button'))
        ],
      ),
    );
  }
}
