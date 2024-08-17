import 'package:asset_store/screens/asset_management/asset_buttons.dart';
import 'package:asset_store/screens/asset_management/manage_asset_detail.dart';
import 'package:asset_store/screens/asset_management/manage_asset_image.dart';
import 'package:flutter/material.dart';

class TabName {
  static const String details = 'Details';
  static const String images = 'Images';
}

class ManageAsset extends StatelessWidget {
  const ManageAsset({super.key});

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
                  add: () {},
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
        const ManageAssetDetail(),
      ];
    } else if (tabName == TabName.images) {
      return <Widget>[
        const ManageAssetImage(),
      ];
    }
    return <Widget>[];
  }
}
