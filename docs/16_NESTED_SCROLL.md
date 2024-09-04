# Nesting Scrollable Views

## Scrollable Asset "GridView"

---

> ```dart
> Widget build(BuildContext context) {
>    super.build(context);
>
>    return Column(
>      children: [
>        ElevatedButton(
>          onPressed: _pickImage,
>          child: const Text('Upload Image'),
>        ),
>        const SizedBox(height: 40),
>        // Display all the images
>        if (_imageFiles.isNotEmpty) ...[
>          Wrap(
>            children: _imageFiles
>                .map(
>                  (XFile image) => Column(
>                    children: [
>                      ImageBox(image: image, onRemove: _removeImage),
>                    ],
>                  ),
>                )
>                .toList(),
>          ),
>        ],
>      ],
>    );
>  }
> ```
>
> I would like to replace the vertical column with a grid of images, 2 images wide. How can I dynamically resize images and organise them into a grid like this?
>
> This widgets parent, however, implements a NestedScrollView:
>
> ```dart
> class _ManageAssetState extends State<ManageAsset> {
>   late Asset topLevelAsset;
>
>   @override
>   void initState() {
>     super.initState();
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
>               ],
>             ),
>           );
>         }),
>       ),
>     );
>   }
>
>   List<Widget> _buildTabContent(String tabName, BuildContext context) {
>     return <Widget>[
>       ManageAssetDetail(
>         asset: topLevelAsset,
>         onUpdate: _updateAsset,
>       ),
>     ];
>   }
> }
> ```
>
> Here we can see our ManageAssetDetail widget is being added into a SliverChildListDelegate
>
> Viewports expand in the scrolling direction to fill their container. In this case, a vertical viewport was given an unlimited amount of vertical space in which to expand. This situation typically happens when a scrollable widget is nested inside another scrollable widget.
> If this widget is always nested in a scrollable widget there is no need to use a viewport because there will always be enough vertical space for the children. In this case, consider using a Column or Wrap instead. Otherwise, consider using a CustomScrollView to concatenate arbitrary slivers into a single scrollable.
>
> The relevant error-causing widget was:
> CustomScrollView CustomScrollView:.../lib/screens/asset_management/manage_asset_image.dart:83:20

---

Given that the parent widget is using a `NestedScrollView` with `SliverList` and `CustomScrollView`, this setup can result in layout issues, particularly when dealing with nested scrolling widgets. Since `SliverList` is used inside a `CustomScrollView`, it expects its child widgets to have a defined height. However, if any child widget tries to expand to fill an undefined amount of space, it can cause the `unbounded height` error.

To address this issue, here are some steps you can take:

### 1. **Avoid Using `CustomScrollView` Inside Another Scrollable:**

Since your `ManageAssetImage` widget is already part of a scrollable view (`SliverList` inside `CustomScrollView`), you should avoid wrapping it in another `CustomScrollView`. Instead, you can directly use a `GridView` or `Wrap` for displaying the images.

### 2. **Replace `CustomScrollView` with a `Wrap` or `GridView`:**

Since you want to display images in a grid, and the parent widget is already handling the scrolling, you can replace `CustomScrollView` with a `Wrap` or directly use `GridView` without trying to scroll it independently.

Here’s how you can update your `ManageAssetImage` widget:

```dart
@override
Widget build(BuildContext context) {
  super.build(context);

  return Column(
    mainAxisSize: MainAxisSize.min,  // Shrink-wraps the Column
    children: [
      ElevatedButton(
        onPressed: _pickImage,
        child: const Text('Upload Image'),
      ),
      const SizedBox(height: 40),
      // Display all the images
      if (_imageFiles.isNotEmpty) ...[
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 images per row
            crossAxisSpacing: 10, // Horizontal spacing between images
            mainAxisSpacing: 10, // Vertical spacing between images
            childAspectRatio: 1, // Square cells
          ),
          physics: const NeverScrollableScrollPhysics(), // Disable scrolling
          shrinkWrap: true, // Make GridView take up only as much space as needed
          itemCount: _imageFiles.length,
          itemBuilder: (BuildContext context, int index) {
            final image = _imageFiles[index];
            return ImageBox(
              image: image,
              onRemove: () => _removeImage(image),
            );
          },
        ),
      ],
    ],
  );
}
```

### Key Adjustments:

- **`GridView.builder` with `NeverScrollableScrollPhysics`**: This prevents the `GridView` from scrolling independently since it's inside another scrollable widget.
- **`shrinkWrap: true`**: This makes sure the `GridView` only takes up as much space as it needs, avoiding conflicts with the parent scroll view.

This approach should prevent the `unbounded height` issue and ensure that your images are displayed correctly within the existing scrollable context.
