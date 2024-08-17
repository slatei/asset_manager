import 'package:flutter/material.dart';

class AssetButtons extends StatefulWidget {
  const AssetButtons({
    required this.tabController,
    required this.add,
    super.key,
  });

  final TabController tabController;
  final Function() add;

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
          OutlinedButton(
            onPressed: _tabController.index != 0
                ? () => _tabController.animateTo(_tabController.index - 1)
                : null,
            child: const Text('Back'),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: _tabController.index < _tabController.length - 1
                ? () => _tabController.animateTo(_tabController.index + 1)
                : null,
            child: const Text('Next'),
          ),
          const Expanded(child: SizedBox()),
          FilledButton.icon(
            onPressed: widget.add,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
