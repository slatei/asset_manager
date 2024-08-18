import 'package:flutter/material.dart';

class ManageAssetLabels extends StatefulWidget {
  final List<String> labels;
  final Function(List<String>) onLabelsChanged;

  const ManageAssetLabels({
    required this.labels,
    required this.onLabelsChanged,
    super.key,
  });

  @override
  State<ManageAssetLabels> createState() => _ManageAssetLabelsState();
}

class _ManageAssetLabelsState extends State<ManageAssetLabels> {
  late List<String> labels;

  @override
  void initState() {
    super.initState();
    labels = List.from(widget.labels);
  }

  void _addLabel(String label) {
    setState(() {
      labels.add(label);
      widget.onLabelsChanged(labels); // Notify parent of changes
    });
  }

  void _removeLabel(String label) {
    setState(() {
      labels.remove(label);
      widget.onLabelsChanged(labels); // Notify parent of changes
    });
  }

  void _showAddLabelDialog(BuildContext context) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Label'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter label"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addLabel(controller.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        children: [
          ...widget.labels.map((label) => Chip(
                label: Text(label),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () => _removeLabel(label),
              )),
          GestureDetector(
            onTap: () => _showAddLabelDialog(context),
            child: Chip(
              label: const Icon(Icons.add, size: 18.0),
              backgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
