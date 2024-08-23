import 'package:asset_store/models/asset/asset.dart';
import 'package:asset_store/screens/asset_management/asset_buttons.dart';
import 'package:asset_store/screens/asset_management/manage_asset_detail.dart';
import 'package:asset_store/screens/asset_management/manage_asset_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class TabName {
  static const String details = 'Details';
  static const String images = 'Images';
}

class ManageAsset extends StatefulWidget {
  const ManageAsset({super.key});

  @override
  State<ManageAsset> createState() => _ManageAssetState();
}

class _ManageAssetState extends State<ManageAsset> {
  late Asset topLevelAsset = Asset(
    name: '',
    id: uuid.v4(),
  );

  void _updateAsset(Asset asset) {
    setState(() {
      topLevelAsset = asset;
    });
  }

  void _handleSubmit() {
    if (kDebugMode) {
      print('Asset added: ${topLevelAsset.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>[TabName.details, TabName.images];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: Builder(builder: (BuildContext context) {
          // Wrap the NestedScrollView inside a Builder widget, which ensures that when the "AssetButtons" is created, the DefaultTabController is already in place
          final TabController tabController = DefaultTabController.of(context);

          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    title: const Text('Asset Management'),
                    pinned: true,
                    centerTitle: true,
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                      tabs: tabs.map((String name) => Tab(text: name)).toList(),
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                // Tabs and tab content
                Expanded(
                  child: TabBarView(
                    children: tabs.map((String name) {
                      return SafeArea(
                        top: false,
                        bottom: false,
                        child: Builder(
                          builder: (BuildContext context) {
                            return CustomScrollView(
                              key: PageStorageKey<String>(name),
                              slivers: <Widget>[
                                SliverOverlapInjector(
                                  handle: NestedScrollView
                                      .sliverOverlapAbsorberHandleFor(context),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.all(8.0),
                                  sliver: SliverList(
                                    delegate: SliverChildListDelegate(
                                      _buildTabContent(name, context),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Bottom bar navigation and state management
                // Obtain the tabController initialised using the builder function, and pass it directly to the AssetButtons widget
                AssetButtons(
                  tabController: tabController,
                  add: _handleSubmit,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildTabContent(String tabName, BuildContext context) {
    if (tabName == TabName.details) {
      return <Widget>[
        ManageAssetDetail(
          asset: topLevelAsset,
          onUpdate: _updateAsset,
        ),
      ];
    } else if (tabName == TabName.images) {
      return <Widget>[
        ManageAssetImage(
          asset: topLevelAsset,
          onUpdate: _updateAsset,
          imagePicker: ImagePicker(),
        ),
      ];
    }
    return <Widget>[];
  }
}
