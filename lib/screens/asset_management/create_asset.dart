import 'package:asset_store/screens/asset_management/asset_buttons.dart';
import 'package:asset_store/screens/asset_management/create_asset_detail.dart';
import 'package:asset_store/screens/asset_management/create_asset_image.dart';
import 'package:flutter/material.dart';

class CreateAsset extends StatefulWidget {
  const CreateAsset({super.key});

  @override
  State<CreateAsset> createState() => _CreateAssetState();
}

class _CreateAssetState extends State<CreateAsset>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<String> tabs = ['Details', 'Images'];
  final Map<String, Widget> tabsMap = {
    "Details": const CreateAssetDetail(),
    "Images": const CreateAssetImage(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: tabsMap.entries.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Asset'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabsMap.keys.map((key) {
            return Tab(
              text: key,
            );
          }).toList(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: tabsMap.values.map((value) {
                  return value;
                }).toList(),
              ),
            ),
            AssetButtons(
              tabController: _tabController,
              add: () {},
            )
          ],
        ),
      ),
    );
  }
}
