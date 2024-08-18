# Sharing State

- [Sharing State](#sharing-state)
  - [Sub-Widget Updating Parent Widget State](#sub-widget-updating-parent-widget-state)
    - [1. Refactor `_ManageAssetState` to Handle Asset State Updates](#1-refactor-_manageassetstate-to-handle-asset-state-updates)
    - [2. Update the `ManageAssetDetail` Widget to Handle Text Input Changes](#2-update-the-manageassetdetail-widget-to-handle-text-input-changes)
    - [3. Pass Down the Updated Asset State](#3-pass-down-the-updated-asset-state)
    - [Refactored `ManageAsset` Class](#refactored-manageasset-class)
    - [Updated `ManageAssetDetail` Widget](#updated-manageassetdetail-widget)
    - [Explanation](#explanation)
  - [Child Widget Managing Sub-State Object](#child-widget-managing-sub-state-object)
    - [Refactor `ManageAssetDetail` to Manage its own Asset Instance](#refactor-manageassetdetail-to-manage-its-own-asset-instance)
    - [Updated `ManageAsset` Class](#updated-manageasset-class)
    - [Updated `ManageAssetDetail` Widget](#updated-manageassetdetail-widget-1)
    - [Explanation](#explanation-1)
  - [Class Setters and Getters](#class-setters-and-getters)
    - [Updated `Asset` Class with Setters](#updated-asset-class-with-setters)
    - [Explanation](#explanation-2)
    - [Example Usage](#example-usage)
    - [Benefits](#benefits)

## Sub-Widget Updating Parent Widget State

---

> I have a flutter application with a screen that can be used to create a personal "Asset". The asset has the following class definition:
>
> ```dart
> class Asset {
>   Asset({
>     required this.name,
>     required this.id,
>     this.purchase,
>     this.category,
>     this.room,
>     this.labels,
>     this.notes,
>   });
>
>   final String name;
>   final String id;
>   final Purchase? purchase;
>   final AssetCategory? category;
>   final AssetRoom? room;
>   final List<String>? labels;
>   final String? notes;
>
>   final DateTime _createdAt = DateTime.now();
>
>   final List<String> _filePaths = [];
>
>   void addFilePath(String path) {
>     _filePaths.add(path);
>   }
> }
> ```
>
> Then there is a `manage_asset.dart` file, which is a top-level screen which displays a tab separated list of screens for entering information about the asset:
>
> ```dart
> import 'package:asset_store/models/asset/asset.dart';
> import 'package:asset_store/screens/asset_management/asset_buttons.dart';
> import 'package:asset_store/screens/asset_management/manage_asset_detail.dart';
> import 'package:asset_store/screens/asset_management/manage_asset_image.dart';
> import 'package:flutter/material.dart';
>
> class TabName {
>   static const String details = 'Details';
>   static const String images = 'Images';
> }
>
> class ManageAsset extends StatefulWidget {
>   const ManageAsset({super.key});
>
>   @override
>   State<ManageAsset> createState() => _ManageAssetState();
> }
>
> class _ManageAssetState extends State<ManageAsset> {
>   late Asset topLevelAsset = Asset(name: 'New', id: 'id');
>
>   void _updateAsset(Asset asset) {
>     setState(() {
>       asset = topLevelAsset;
>     });
>   }
>
>   void _handleSubmit() {
>     print('Asset added');
>     print(asset.toString());
>   }
>
>   @override
>   Widget build(BuildContext context) {
>     final List<String> tabs = <String>[TabName.details, TabName.images];
>     return DefaultTabController(
>       length: tabs.length,
>       child: Scaffold(
>         body: Builder(builder: (BuildContext context) {
>           // Wrap the NestedScrollView inside a Builder widget, which ensures that when the "AssetButtons" is created, the DefaultTabController is already in place
>           final TabController tabController = DefaultTabController.of(context);
>
>           return NestedScrollView(
>             headerSliverBuilder:
>                 (BuildContext context, bool innerBoxIsScrolled) {
>               return <Widget>[
>                 SliverOverlapAbsorber(
>                   handle:
>                       NestedScrollView.sliverOverlapAbsorberHandleFor(context),
>                   sliver: SliverAppBar(
>                     title: const Text('Asset Management'),
>                     pinned: true,
>                     centerTitle: true,
>                     forceElevated: innerBoxIsScrolled,
>                     bottom: TabBar(
>                       tabs: tabs.map((String name) => Tab(text: name)).toList(),
>                     ),
>                   ),
>                 ),
>               ];
>             },
>             body: Column(
>               children: [
>                 // Tabs and tab content
>                 Expanded(
>                   child: TabBarView(
>                     children: tabs.map((String name) {
>                       return SafeArea(
>                         top: false,
>                         bottom: false,
>                         child: Builder(
>                           builder: (BuildContext context) {
>                             return CustomScrollView(
>                               key: PageStorageKey<String>(name),
>                               slivers: <Widget>[
>                                 SliverOverlapInjector(
>                                   handle: NestedScrollView
>                                       .sliverOverlapAbsorberHandleFor(context),
>                                 ),
>                                 SliverPadding(
>                                   padding: const EdgeInsets.all(8.0),
>                                   sliver: SliverList(
>                                     delegate: SliverChildListDelegate(
>                                       _buildTabContent(name, context),
>                                     ),
>                                   ),
>                                 ),
>                               ],
>                             );
>                           },
>                         ),
>                       );
>                     }).toList(),
>                   ),
>                 ),
>
>                 // Bottom bar navigation and state management
>                 // Obtain the tabController initialised using the builder function, and pass it directly to the AssetButtons widget
>                 AssetButtons(
>                   tabController: tabController,
>                   add: _handleSubmit,
>                 ),
>               ],
>             ),
>           );
>         }),
>       ),
>     );
>   }
>
>   List<Widget> _buildTabContent(String tabName, BuildContext context) {
>     if (tabName == TabName.details) {
>       return <Widget>[
>         ManageAssetDetail(
>           updateAsset: _updateAsset,
>           asset: topLevelAsset,
>         ),
>       ];
>     } else if (tabName == TabName.images) {
>       return <Widget>[
>         const ManageAssetImage(),
>       ];
>     }
>     return <Widget>[];
>   }
> }
> ```
>
> Then there is the `manage_asset_detail.dart` file, which is a Widget nested within the `create_asset.dart` file, which shows the first screen that users can use for updating/creating an asset:
>
> ```dart
> import 'package:asset_store/models/asset/asset.dart';
> import 'package:asset_store/screens/asset_management/manage_asset_labels.dart';
> import 'package:flutter/material.dart';
>
> class ManageAssetDetail extends StatefulWidget {
>   const ManageAssetDetail({
>     required this.asset,
>     required this.updateAsset,
>     super.key,
>   });
>
>   final void Function(Asset) updateAsset;
>   final Asset asset;
>
>   @override
>   State<ManageAssetDetail> createState() => _ManageAssetDetailState();
> }
>
> class _ManageAssetDetailState extends State<ManageAssetDetail>
>     with AutomaticKeepAliveClientMixin {
>   @override
>   bool get wantKeepAlive => true;
>
>   final _nameController = TextEditingController();
>   final _categoryController = TextEditingController();
>
>   List<String> labels = ['Flutter', 'Dart'];
>   void _updateLabels(List<String> updatedLabels) {
>     setState(() {
>       labels = updatedLabels;
>     });
>   }
>
>   @override
>   void dispose() {
>     _nameController.dispose();
>     _categoryController.dispose();
>     super.dispose();
>   }
>
>   @override
>   Widget build(BuildContext context) {
>     super.build(context);
>
>     return Column(
>       children: <Widget>[
>         // Primary data entry
>         Padding(
>           padding: const EdgeInsets.symmetric(horizontal: 20),
>           child: Column(
>             children: [
>               // Asset name
>               const SizedBox(height: 20),
>               TextField(
>                 controller: _nameController,
>                 decoration: const InputDecoration(
>                   prefixIcon: Icon(Icons.person_2),
>                   label: Text('Name'),
>                   border: OutlineInputBorder(),
>                 ),
>               ),
>               const SizedBox(height: 20),
>
>               // Asset category
>               TextField(
>                 controller: _categoryController,
>                 decoration: const InputDecoration(
>                   prefixIcon: Icon(Icons.category_rounded),
>                   label: Text('Category'),
>                   border: OutlineInputBorder(),
>                 ),
>               ),
>               const SizedBox(height: 20),
>
>               // Asset date
>               const TextField(
>                 decoration: InputDecoration(
>                   prefixIcon: Icon(Icons.calendar_month_rounded),
>                   label: Text('Date'),
>                   border: OutlineInputBorder(),
>                 ),
>               ),
>               const SizedBox(height: 20),
>
>               // Asset price
>               const TextField(
>                 decoration: InputDecoration(
>                   prefixIcon: Icon(Icons.attach_money_rounded),
>                   label: Text('Category'),
>                   border: OutlineInputBorder(),
>                 ),
>               ),
>               const SizedBox(height: 20),
>             ],
>           ),
>         ),
>
>         const Divider(
>           indent: 20,
>           endIndent: 20,
>         ),
>
>         ManageAssetLabels(
>           labels: labels,
>           onLabelsChanged: _updateLabels,
>         ),
>
>         const Divider(
>           indent: 20,
>           endIndent: 20,
>         )
>       ],
>     );
>   }
> }
> ```
>
> What I would like to do is define the state of the asset in the `create_asset.dart` file, and as the users changes tabs and updates information related to the asset, the "topLevelAsset" state is updated consistently. Then, when the user selects a button inside the `AssetButtons` widget, the `_handleSubmit` function is called to create the asset in some sort of store.
>
> Can you please help me outline how to set up the state of this asset at the top level, and pass the top level asset into each sub-widget respectively? Ideally, when the TextFieldControllers are updated, the top level asset state is kept up to date as well

---

To achieve the goal of maintaining the state of the `Asset` at the top level and consistently updating it as users interact with different tabs and sub-widgets, you can follow these steps:

### 1. Refactor `_ManageAssetState` to Handle Asset State Updates

First, modify the `_ManageAssetState` class so that it directly updates the `topLevelAsset` when any field is modified. The updated state will then be passed down to child widgets, allowing them to display and update the current asset information.

### 2. Update the `ManageAssetDetail` Widget to Handle Text Input Changes

You'll want the `ManageAssetDetail` widget to update the `Asset` object as users input data into the `TextField` widgets. This can be done by setting up listeners on the `TextEditingController` instances and calling a callback to update the asset state in the parent widget.

### 3. Pass Down the Updated Asset State

Ensure the updated `Asset` object is passed down to the appropriate widgets so that they have the current state of the asset.

Here's how you can do it:

### Refactored `ManageAsset` Class

```dart
class _ManageAssetState extends State<ManageAsset> {
  late Asset topLevelAsset = Asset(name: 'New', id: 'id');

  void _updateAssetField({
    String? name,
    String? category,
    List<String>? labels,
  }) {
    setState(() {
      if (name != null) topLevelAsset = Asset(name: name, id: topLevelAsset.id, purchase: topLevelAsset.purchase, category: topLevelAsset.category, room: topLevelAsset.room, labels: topLevelAsset.labels, notes: topLevelAsset.notes);
      if (category != null) topLevelAsset = Asset(name: topLevelAsset.name, id: topLevelAsset.id, purchase: topLevelAsset.purchase, category: topLevelAsset.category, room: topLevelAsset.room, labels: topLevelAsset.labels, notes: topLevelAsset.notes);
      if (labels != null) topLevelAsset = Asset(name: topLevelAsset.name, id: topLevelAsset.id, purchase: topLevelAsset.purchase, category: topLevelAsset.category, room: topLevelAsset.room, labels: labels, notes: topLevelAsset.notes);
    });
  }

  void _handleSubmit() {
    print('Asset added');
    print(topLevelAsset.toString());
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>[TabName.details, TabName.images];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
                                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
          updateAssetField: _updateAssetField,
          asset: topLevelAsset,
        ),
      ];
    } else if (tabName == TabName.images) {
      return <Widget>[
        const ManageAssetImage(),
      ];
    }
    return <Widget>[];
  }
}
```

### Updated `ManageAssetDetail` Widget

Modify the `ManageAssetDetail` widget to accept a callback function `updateAssetField` that is triggered whenever a field is updated:

```dart
class ManageAssetDetail extends StatefulWidget {
  const ManageAssetDetail({
    required this.asset,
    required this.updateAssetField,
    super.key,
  });

  final Asset asset;
  final void Function({
    String? name,
    String? category,
    List<String>? labels,
  }) updateAssetField;

  @override
  State<ManageAssetDetail> createState() => _ManageAssetDetailState();
}

class _ManageAssetDetailState extends State<ManageAssetDetail>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();

  List<String> labels = [];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.asset.name;
    labels = widget.asset.labels ?? [];

    // Add listeners to update the asset state when the text changes
    _nameController.addListener(() {
      widget.updateAssetField(name: _nameController.text);
    });
    _categoryController.addListener(() {
      widget.updateAssetField(category: _categoryController.text);
    });
  }

  void _updateLabels(List<String> updatedLabels) {
    setState(() {
      labels = updatedLabels;
    });
    widget.updateAssetField(labels: labels);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_2),
                  label: Text('Name'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded),
                  label: Text('Category'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Date'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  label: Text('Category'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const Divider(
          indent: 20,
          endIndent: 20,
        ),
        ManageAssetLabels(
          labels: labels,
          onLabelsChanged: _updateLabels,
        ),
        const Divider(
          indent: 20,
          endIndent: 20,
        )
      ],
    );
  }
}
```

### Explanation

- **State Management:** The `topLevelAsset` state is now maintained in the `_ManageAssetState` class. This state is updated using the `_updateAssetField` method, which modifies the `Asset` object based on the inputs received from the child widgets.
- **Listeners:** The `ManageAssetDetail` widget uses listeners on `TextEditingController` instances to detect changes and update the asset state in real-time.
- **Passing State Down:** The updated `Asset` object is passed down to the child widgets, ensuring that they have the latest data.

This setup ensures that all changes made in different parts of the UI are reflected in the central asset state, which is managed at the top level. When the user submits the asset, the `topLevelAsset` object will have all the updated information.

## Child Widget Managing Sub-State Object

---

> Instead of passing up each individual field, could the ManageAssetDetail widget instead manage it's own instance of the asset, or perhaps manage the asset instance passed in, and every time an update is made, call the callback function of the parent to also reflect the changes of the locally scoped asset object?

---

Certainly! Instead of passing individual fields to update the asset, you can have the `ManageAssetDetail` widget manage its own instance of the `Asset` object (or manage the passed-in instance). Every time an update is made within the `ManageAssetDetail` widget, it can call a callback function to notify the parent widget of the changes, allowing the parent to update its state.

Here's how you can implement this approach:

### Refactor `ManageAssetDetail` to Manage its own Asset Instance

The `ManageAssetDetail` widget will manage its own instance of the `Asset` (or modify the passed-in `Asset`). Whenever a change is made, it will call the parent's callback function to update the state at the top level.

### Updated `ManageAsset` Class

```dart
class _ManageAssetState extends State<ManageAsset> {
  Asset topLevelAsset = Asset(name: 'New', id: 'id');

  void _updateAsset(Asset updatedAsset) {
    setState(() {
      topLevelAsset = updatedAsset;
    });
  }

  void _handleSubmit() {
    print('Asset added');
    print(topLevelAsset.toString());
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>[TabName.details, TabName.images];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
                                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
        const ManageAssetImage(),
      ];
    }
    return <Widget>[];
  }
}
```

### Updated `ManageAssetDetail` Widget

Here, the `ManageAssetDetail` widget will manage its own instance of the asset. Whenever a user makes changes, the widget will call the `onUpdate` callback to notify the parent of the updated asset.

```dart
class ManageAssetDetail extends StatefulWidget {
  const ManageAssetDetail({
    required this.asset,
    required this.onUpdate,
    super.key,
  });

  final Asset asset;
  final void Function(Asset updatedAsset) onUpdate;

  @override
  State<ManageAssetDetail> createState() => _ManageAssetDetailState();
}

class _ManageAssetDetailState extends State<ManageAssetDetail>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Asset localAsset;

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the local asset with the passed-in asset
    localAsset = widget.asset;

    _nameController.text = localAsset.name;
    _categoryController.text = localAsset.category?.toString() ?? '';

    // Add listeners to update the local asset and notify the parent
    _nameController.addListener(_updateName);
    _categoryController.addListener(_updateCategory);
  }

  void _updateName() {
    setState(() {
      localAsset = Asset(
        name: _nameController.text,
        id: localAsset.id,
        purchase: localAsset.purchase,
        category: localAsset.category,
        room: localAsset.room,
        labels: localAsset.labels,
        notes: localAsset.notes,
      );
    });
    widget.onUpdate(localAsset);
  }

  void _updateCategory() {
    setState(() {
      // Assume that we have a way to convert string to category here
      localAsset = Asset(
        name: localAsset.name,
        id: localAsset.id,
        purchase: localAsset.purchase,
        category: localAsset.category,
        room: localAsset.room,
        labels: localAsset.labels,
        notes: localAsset.notes,
      );
    });
    widget.onUpdate(localAsset);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_2),
                  label: Text('Name'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_rounded),
                  label: Text('Category'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month_rounded),
                  label: Text('Date'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.attach_money_rounded),
                  label: Text('Category'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const Divider(
          indent: 20,
          endIndent: 20,
        ),
        ManageAssetLabels(
          labels: localAsset.labels ?? [],
          onLabelsChanged: (newLabels) {
            setState(() {
              localAsset = Asset(
                name: localAsset.name,
                id: localAsset.id,
                purchase: localAsset.purchase,
                category: localAsset.category,
                room: localAsset.room,
                labels: newLabels,
                notes: localAsset.notes,
              );
            });
            widget.onUpdate(localAsset);
          },
        ),
        const Divider(
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }
}
```

### Explanation

- **Local Asset Management:** The `ManageAssetDetail` widget manages a local instance of the `Asset`. It initializes this instance based on the asset passed from the parent.
- **Listeners for Fields:** The `TextEditingController` instances have listeners that update the local asset when the user modifies the fields. Each change triggers the `onUpdate` callback, passing the updated `Asset` object back to the parent.
- **Parent Callback:** The `onUpdate` callback is used by the `ManageAsset` widget to update the top-level `Asset` state whenever the `ManageAssetDetail` widget makes changes.

This approach encapsulates the logic of managing the asset's fields within `ManageAssetDetail` while ensuring that any updates are reflected in the parent widget's state. This method keeps the code organized and allows for easier state management and updates.

## Class Setters and Getters

---

> How could I update the Asset class to allow me to use setters for updating the asset.name, asset.category, and asset.labels fields?

---

To enable updating fields like `name`, `category`, and `labels` using setters in the `Asset` class, you'll need to implement custom setters for each of these fields. This approach allows you to encapsulate the logic for updating these fields directly within the `Asset` class, making it easier to manage and maintain.

Here’s how you can modify the `Asset` class to include setters:

### Updated `Asset` Class with Setters

```dart
class Asset {
  Asset({
    required String name,
    required String id,
    Purchase? purchase,
    AssetCategory? category,
    AssetRoom? room,
    List<String>? labels,
    String? notes,
  })  : _name = name,
        _id = id,
        _purchase = purchase,
        _category = category,
        _room = room,
        _labels = labels ?? [],
        _notes = notes;

  String _name;
  final String _id;
  Purchase? _purchase;
  AssetCategory? _category;
  AssetRoom? _room;
  List<String> _labels;
  String? _notes;

  final DateTime _createdAt = DateTime.now();

  final List<String> _filePaths = [];

  // Getters
  String get name => _name;
  String get id => _id;
  Purchase? get purchase => _purchase;
  AssetCategory? get category => _category;
  AssetRoom? get room => _room;
  List<String> get labels => _labels;
  String? get notes => _notes;

  DateTime get createdAt => _createdAt;
  List<String> get filePaths => List.unmodifiable(_filePaths);

  // Setters
  set name(String newName) {
    _name = newName;
  }

  set category(AssetCategory? newCategory) {
    _category = newCategory;
  }

  set labels(List<String> newLabels) {
    _labels = newLabels;
  }

  void addFilePath(String path) {
    _filePaths.add(path);
  }
}
```

### Explanation

- **Private Fields:** The fields that you want to modify through setters (`name`, `category`, and `labels`) are now private, denoted by the underscore (`_`) prefix.
- **Public Getters:** Public getters allow you to access the current value of each field. This encapsulation hides the internal state from direct modification outside the class.
- **Setters:** Custom setters are provided for `name`, `category`, and `labels`. These setters allow you to update the private fields while still using the public API of the `Asset` class.
- **Other Fields:** Fields like `id` are kept immutable (read-only) because they don't have setters.

### Example Usage

With the above changes, you can now update the asset's fields using the setters like this:

```dart
void _updateName(String newName) {
  setState(() {
    localAsset.name = newName;  // Using the setter to update the name
  });
  widget.onUpdate(localAsset);
}

void _updateCategory(AssetCategory? newCategory) {
  setState(() {
    localAsset.category = newCategory;  // Using the setter to update the category
  });
  widget.onUpdate(localAsset);
}

void _updateLabels(List<String> newLabels) {
  setState(() {
    localAsset.labels = newLabels;  // Using the setter to update the labels
  });
  widget.onUpdate(localAsset);
}
```

### Benefits

- **Encapsulation:** The internal state of the `Asset` class is better protected. Only controlled updates via setters are allowed.
- **Maintainability:** If you need to add additional logic (e.g., validation) when updating a field, you can easily do so within the setter method.
- **Consistency:** This structure ensures that all updates to the fields happen in a uniform manner, reducing the likelihood of bugs.

By implementing setters this way, you make the `Asset` class more flexible and robust, allowing for easier and safer updates to its fields.
