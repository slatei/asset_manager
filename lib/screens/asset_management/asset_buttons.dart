import 'package:flutter/material.dart';

class AssetButtons extends StatefulWidget {
  const AssetButtons({
    required this.tabController,
    required this.add,
    this.remove,
    super.key,
  });

  final TabController tabController;
  final Function() add;
  final Function()? remove;

  @override
  State<AssetButtons> createState() => _AssetButtonsState();
}

class _AssetButtonsState extends State<AssetButtons> {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = widget.tabController;
    _tabController.addListener(_updateState);
  }

  @override
  void dispose() {
    _tabController.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Navigation buttons
          OutlinedButton(
              onPressed: _tabController.index != 0
                  ? () => _tabController.animateTo(_tabController.index - 1)
                  : null,
              // child: const Text('Back'),
              child: const Icon(Icons.keyboard_arrow_left)),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: _tabController.index < _tabController.length - 1
                ? () => _tabController.animateTo(_tabController.index + 1)
                : null,
            // child: const Text('Next'),
            child: const Icon(Icons.keyboard_arrow_right),
          ),
          const Expanded(child: SizedBox()),

          // Delete button if delete function provided
          if (widget.remove != null) ...[
            OutlinedButton.icon(
              onPressed: widget.remove,
              label: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 10),
          ],

          // Save button
          FilledButton(
            onPressed: widget.add,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
