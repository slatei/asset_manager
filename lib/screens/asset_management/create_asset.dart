import 'package:asset_store/screens/asset_management/create_asset_detail.dart';
import 'package:asset_store/screens/asset_management/create_asset_image.dart';
import 'package:flutter/material.dart';


class CreateAsset extends StatelessWidget {
  const CreateAsset({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>['Details', 'Upload Images'];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
          body: TabBarView(
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
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
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
      ),
    );
  }

  List<Widget> _buildTabContent(String tabName, BuildContext context) {
    if (tabName == 'Details') {
      return <Widget>[
        CreateAssetDetail(
          tabController: DefaultTabController.of(context),
        ),
      ];
    } else if (tabName == 'Upload Images') {
      return <Widget>[
        CreateAssetImage(
          tabController: DefaultTabController.of(context),
        ),
      ];
    }
    return <Widget>[];
  }
}
