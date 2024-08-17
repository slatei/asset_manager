# Tabs and Nested Scroll View

- [Tabs and Nested Scroll View](#tabs-and-nested-scroll-view)
  - [Understanding NestedScrollView](#understanding-nestedscrollview)
    - [Understanding `NestedScrollView`](#understanding-nestedscrollview-1)
    - [Modifying the Example for Your Use Case](#modifying-the-example-for-your-use-case)
    - [Key Modifications](#key-modifications)
    - [How It Works](#how-it-works)
  - [Combining NestedScrollView and Custom Widgets](#combining-nestedscrollview-and-custom-widgets)
    - [Updated `NestedScrollViewExample` Code](#updated-nestedscrollviewexample-code)
    - [Explanation](#explanation)
    - [Summary](#summary)

## Understanding NestedScrollView

---

> Can you please help me understand the flutter "NestedScrollView" class? The Flutter documents provide this example code for creating a tabbed view with scrollable content, however it's not clear to me how to build on this
> <https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html>
>
> ```dart
> import 'package:flutter/material.dart';
>
> /// Flutter code sample for [NestedScrollView].
>
> void main() => runApp(const NestedScrollViewExampleApp());
>
> class NestedScrollViewExampleApp extends StatelessWidget {
>   const NestedScrollViewExampleApp({super.key});
>
>   @override
>   Widget build(BuildContext context) {
>     return const MaterialApp(
>       home: NestedScrollViewExample(),
>     );
>   }
> }
>
> class NestedScrollViewExample extends StatelessWidget {
>   const NestedScrollViewExample({super.key});
>
>   @override
>   Widget build(BuildContext context) {
>     final List<String> tabs = <String>['Tab 1', 'Tab 2'];
>     return DefaultTabController(
>       length: tabs.length, // This is the number of tabs.
>       child: Scaffold(
>         body: NestedScrollView(
>           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
>             // These are the slivers that show up in the "outer" scroll view.
>             return <Widget>[
>               SliverOverlapAbsorber(
>                 // This widget takes the overlapping behavior of the SliverAppBar,
>                 // and redirects it to the SliverOverlapInjector below. If it is
>                 // missing, then it is possible for the nested "inner" scroll view
>                 // below to end up under the SliverAppBar even when the inner
>                 // scroll view thinks it has not been scrolled.
>                 // This is not necessary if the "headerSliverBuilder" only builds
>                 // widgets that do not overlap the next sliver.
>                 handle:
>                     NestedScrollView.sliverOverlapAbsorberHandleFor(context),
>                 sliver: SliverAppBar(
>                   title:
>                       const Text('Books'), // This is the title in the app bar.
>                   pinned: true,
>                   expandedHeight: 150.0,
>                   // The "forceElevated" property causes the SliverAppBar to show
>                   // a shadow. The "innerBoxIsScrolled" parameter is true when the
>                   // inner scroll view is scrolled beyond its "zero" point, i.e.
>                   // when it appears to be scrolled below the SliverAppBar.
>                   // Without this, there are cases where the shadow would appear
>                   // or not appear inappropriately, because the SliverAppBar is
>                   // not actually aware of the precise position of the inner
>                   // scroll views.
>                   forceElevated: innerBoxIsScrolled,
>                   bottom: TabBar(
>                     // These are the widgets to put in each tab in the tab bar.
>                     tabs: tabs.map((String name) => Tab(text: name)).toList(),
>                   ),
>                 ),
>               ),
>             ];
>           },
>           body: TabBarView(
>             // These are the contents of the tab views, below the tabs.
>             children: tabs.map((String name) {
>               return SafeArea(
>                 top: false,
>                 bottom: false,
>                 child: Builder(
>                   // This Builder is needed to provide a BuildContext that is
>                   // "inside" the NestedScrollView, so that
>                   // sliverOverlapAbsorberHandleFor() can find the
>                   // NestedScrollView.
>                   builder: (BuildContext context) {
>                     return CustomScrollView(
>                       // The "controller" and "primary" members should be left
>                       // unset, so that the NestedScrollView can control this
>                       // inner scroll view.
>                       // If the "controller" property is set, then this scroll
>                       // view will not be associated with the NestedScrollView.
>                       // The PageStorageKey should be unique to this ScrollView;
>                       // it allows the list to remember its scroll position when
>                       // the tab view is not on the screen.
>                       key: PageStorageKey<String>(name),
>                       slivers: <Widget>[
>                         SliverOverlapInjector(
>                           // This is the flip side of the SliverOverlapAbsorber
>                           // above.
>                           handle:
>                               NestedScrollView.sliverOverlapAbsorberHandleFor(
>                                   context),
>                         ),
>                         SliverPadding(
>                           padding: const EdgeInsets.all(8.0),
>                           // In this example, the inner scroll view has
>                           // fixed-height list items, hence the use of
>                           // SliverFixedExtentList. However, one could use any
>                           // sliver widget here, e.g. SliverList or SliverGrid.
>                           sliver: SliverFixedExtentList(
>                             // The items in this example are fixed to 48 pixels
>                             // high. This matches the Material Design spec for
>                             // ListTile widgets.
>                             itemExtent: 48.0,
>                             delegate: SliverChildBuilderDelegate(
>                               (BuildContext context, int index) {
>                                 // This builder is called for each child.
>                                 // In this example, we just number each list item.
>                                 return ListTile(
>                                   title: Text('Item $index'),
>                                 );
>                               },
>                               // The childCount of the SliverChildBuilderDelegate
>                               // specifies how many children this inner list
>                               // has. In this example, each tab has a list of
>                               // exactly 30 items, but this is arbitrary.
>                               childCount: 30,
>                             ),
>                           ),
>                         ),
>                       ],
>                     );
>                   },
>                 ),
>               );
>             }).toList(),
>           ),
>         ),
>       ),
>     );
>   }
> }
> ```
>
> Namely, I want one tab to contain information about an asset details (for entering information such as the name of an asset, cost of an asset, and add labels to said asset
>
> And then a second tab which I would use for uploading images of an asset
>
> I _think_ I want to use NestedScrollView to ensure that the "details" tab is scrollable, especially if I add more details to the asset that causes content to overflow the bottom of the page

---

Sure! Let's break down the `NestedScrollView` and how you can customize the example you provided to achieve your goal.

### Understanding `NestedScrollView`

`NestedScrollView` is a widget that allows for two levels of scrollable widgets: an outer scrollable (usually used for the header, like an `AppBar`) and an inner scrollable (like a list or grid). It’s particularly useful when you want to have a collapsible header (like a `SliverAppBar`) that interacts with the scrolling content.

### Modifying the Example for Your Use Case

Based on your requirements:

- **Tab 1**: "Asset Details" – This will contain a form where you can enter details about the asset, like name, cost, and labels.
- **Tab 2**: "Upload Images" – This will allow users to upload images of the asset.

Here's how you can modify the provided code to suit your needs:

```dart
import 'package:flutter/material.dart';

void main() => runApp(const NestedScrollViewExampleApp());

class NestedScrollViewExampleApp extends StatelessWidget {
  const NestedScrollViewExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NestedScrollViewExample(),
    );
  }
}

class NestedScrollViewExample extends StatelessWidget {
  const NestedScrollViewExample({super.key});

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
                  expandedHeight: 150.0,
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
                              _buildTabContent(name),
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

  List<Widget> _buildTabContent(String tabName) {
    if (tabName == 'Details') {
      return <Widget>[
        _buildTextField('Asset Name'),
        _buildTextField('Cost'),
        _buildTextField('Label'),
        // Add more fields as necessary
      ];
    } else if (tabName == 'Upload Images') {
      return <Widget>[
        ElevatedButton(
          onPressed: () {
            // Code to upload image
          },
          child: Text('Upload Image'),
        ),
        // Add more widgets for image upload if necessary
      ];
    }
    return <Widget>[];
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
```

### Key Modifications

1. **Tabs**:

   - Changed tab names to "Details" and "Upload Images".
   - Added a method `_buildTabContent` to generate content based on the tab name.

2. **Details Tab**:

   - For the "Details" tab, used a `SliverList` with `SliverChildListDelegate` to create a list of `TextField` widgets for entering asset details (like name, cost, and labels).
   - `_buildTextField` is a helper function to easily create input fields.

3. **Upload Images Tab**:
   - For the "Upload Images" tab, added a simple `ElevatedButton` to simulate image upload functionality.

### How It Works

- **NestedScrollView**: The `headerSliverBuilder` creates a collapsible `SliverAppBar` that remains pinned at the top of the screen as the user scrolls.
- **CustomScrollView**: Each tab contains a `CustomScrollView` wrapped in a `SafeArea` and `Builder`, ensuring that it interacts correctly with the `NestedScrollView`.
- **Dynamic Content**: The `_buildTabContent` function dynamically generates the content based on the tab selected, enabling you to have different content layouts per tab.

This setup provides a scrollable interface with collapsible headers and is adaptable to more complex forms or different types of content in each tab.

## Combining NestedScrollView and Custom Widgets

---

> Let's assert now, that I have a file `create_asset_detail.dart` which contains the contents of the "Details" tab:
>
> ```dart
> import 'package:flutter/material.dart';
>
> class CreateAssetDetail extends StatefulWidget {
>   const CreateAssetDetail({
>     required this.tabController,
>     super.key,
>   });
>
>   final TabController tabController;
>
>   @override
>   State<CreateAssetDetail> createState() => _CreateAssetDetailState();
> }
>
> class _CreateAssetDetailState extends State<CreateAssetDetail>
>     with AutomaticKeepAliveClientMixin {
>   @override
>   bool get wantKeepAlive => true;
>
>   final _nameController = TextEditingController();
>   final _categoryController = TextEditingController();
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
>               TextField(
>                 controller: _nameController,
>                 decoration: const InputDecoration(
>                   prefixIcon: Icon(Icons.person_2),
>                   label: Text('Name'),
>                   border: OutlineInputBorder(),
>                 ),
>               ),
>               const SizedBox(height: 10),
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
>               const SizedBox(height: 10),
>
>               // Asset date
>               const TextField(
>                 decoration: InputDecoration(
>                   prefixIcon: Icon(Icons.calendar_month_rounded),
>                   label: Text('Date'),
>                   border: OutlineInputBorder(),
>                 ),
>               ),
>               const SizedBox(height: 10),
>
>               // Asset price
>               const TextField(
>                 decoration: InputDecoration(
>                   prefixIcon: Icon(Icons.attach_money_rounded),
>                   label: Text('Category'),
>                   border: OutlineInputBorder(),
>                 ),
>               ),
>               const SizedBox(height: 10),
>             ],
>           ),
>         ),
>       ],
>     );
>   }
> }
> ```
>
> How would I use this widget from the imported file instead of building the content out in the `_buildTabContent` function?

---

To use the `CreateAssetDetail` widget from the `create_asset_detail.dart` file instead of building the content directly in the `_buildTabContent` function, you'll follow these steps:

1. **Import the `create_asset_detail.dart` file** into your main file.
2. **Replace the contents of the "Details" tab** with an instance of the `CreateAssetDetail` widget.

Here’s how you can update your `NestedScrollViewExample` class:

### Updated `NestedScrollViewExample` Code

```dart
import 'package:flutter/material.dart';
import 'create_asset_detail.dart'; // Import the file containing CreateAssetDetail widget

void main() => runApp(const NestedScrollViewExampleApp());

class NestedScrollViewExampleApp extends StatelessWidget {
  const NestedScrollViewExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NestedScrollViewExample(),
    );
  }
}

class NestedScrollViewExample extends StatelessWidget {
  const NestedScrollViewExample({super.key});

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
                  expandedHeight: 150.0,
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
          tabController: DefaultTabController.of(context)!,
        ),
      ];
    } else if (tabName == 'Upload Images') {
      return <Widget>[
        ElevatedButton(
          onPressed: () {
            // Code to upload image
          },
          child: Text('Upload Image'),
        ),
        // Add more widgets for image upload if necessary
      ];
    }
    return <Widget>[];
  }
}
```

### Explanation

1. **Import the Widget**:

   ```dart
   import 'create_asset_detail.dart';
   ```

   This imports the `CreateAssetDetail` widget from the `create_asset_detail.dart` file.

2. **Modify `_buildTabContent`**:
   Replace the construction of the "Details" tab content with an instance of the `CreateAssetDetail` widget:

   ```dart
   if (tabName == 'Details') {
     return <Widget>[
       CreateAssetDetail(
         tabController: DefaultTabController.of(context)!,
       ),
     ];
   }
   ```

   - `CreateAssetDetail` is now being used directly, and it's passed the `TabController` from the `DefaultTabController` to ensure it can control or react to tab changes.

3. **Remove Unnecessary Code**:
   Since the `CreateAssetDetail` widget encapsulates the UI for the "Details" tab, there's no need to manually construct it in the `_buildTabContent` function.

### Summary

Now, the "Details" tab content is neatly separated into its own widget, making the code more modular and easier to maintain. This separation allows you to manage the details form in isolation, which is particularly beneficial as your app scales and becomes more complex.
