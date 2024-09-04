# Passing DB Asset into Asset Detail Screen

## Pass Asset in to Child Widget

---

> I currently have a flutter application, with an "Asset management" screen that I would like to use for creating and updating assets.
>
> Currently this screen can only be used to create "Assets", and has the following declaration:
>
> ```dart
> class ManageAsset extends StatefulWidget {
>   const ManageAsset({super.key});
>
>   @override
>   State<ManageAsset> createState() => _ManageAssetState();
> }
>
> class _ManageAssetState extends State<ManageAsset> {
>   late Asset asset = Asset(
>     name: '',
>     id: uuid.v4(),
>   );
> ...
> ```
>
> However I would like to refactor this widget to optionally take an input "asset" instance. And if an asset instance is provided, then use that instead of declaring an empty asset as shown above

---

You can refactor your `ManageAsset` widget to accept an optional `Asset` instance as a parameter. This way, if an asset is passed in, the widget will use it; otherwise, it will create a new empty asset.

Here’s how you can update your `ManageAsset` widget:

```dart
class ManageAsset extends StatefulWidget {
  final Asset? asset;

  const ManageAsset({super.key, this.asset});

  @override
  State<ManageAsset> createState() => _ManageAssetState();
}

class _ManageAssetState extends State<ManageAsset> {
  late Asset asset;

  @override
  void initState() {
    super.initState();
    // If an asset is provided, use it; otherwise, create a new one
    asset = widget.asset ?? Asset(
      name: '',
      id: uuid.v4(),
    );
  }

  // Rest of your widget code...
}
```

### Explanation:

1. **Optional Asset Parameter**:
   - The `ManageAsset` widget now takes an optional `Asset?` parameter (`asset`).
2. **Initialize Asset**:
   - In the `initState` method of `_ManageAssetState`, the `asset` is initialized based on whether the `widget.asset` is provided or not.

This allows you to use the `ManageAsset` screen for both creating a new asset and editing an existing one. When you want to edit an asset, pass the asset to the `ManageAsset` widget; when you want to create a new one, simply don't pass any asset.

## Set Default Textfield Controller Values

---

> I am now passing that asset down to some nested widgets which also initialise the asset, which works fine. However these sub-widgets have TextField controllers that I would like to pre-populate with the contents of this existing asset if it is provided
>
> For example, the following widget is used for setting a "name" and "price" field:
>
> ```dart
> class ManageAssetDetail extends StatefulWidget {
>   const ManageAssetDetail({
>     required this.asset,
>     required this.onUpdate,
>     super.key,
>   });
>
>   final Asset asset;
>   final void Function(Asset updatedAsset) onUpdate;
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
>   late Asset localAsset;
>
>   final _nameController = TextEditingController();
>   final _priceController = TextEditingController();
>
>   List<String> labels = ['Flutter', 'Dart'];
>
>   @override
>   void initState() {
>     super.initState();
>
>     // Initialize the local asset with the passed-in asset
>     localAsset = widget.asset;
>
>     // Add listeners to update the local asset and notify the parent
>     _nameController.addListener(_updateName);
>     _priceController.addListener(_updatePrice);
>   }
> ...
> ```
>
> How can I make the \_nameController and \_priceController use the existing asset values if defined?

---

To pre-populate the `TextEditingController`s with the existing asset values, you can set the initial values of the controllers in the `initState` method. Here's how you can modify your `ManageAssetDetail` widget:

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

  // Initialize the controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the local asset with the passed-in asset
    localAsset = widget.asset;

    // Pre-populate the controllers with existing values from the asset, if available
    _nameController.text = localAsset.name;
    _priceController.text = localAsset.price?.toString() ?? '';

    // Add listeners to update the local asset and notify the parent
    _nameController.addListener(_updateName);
    _priceController.addListener(_updatePrice);
  }

  void _updateName() {
    setState(() {
      localAsset = localAsset.copyWith(name: _nameController.text);
      widget.onUpdate(localAsset);
    });
  }

  void _updatePrice() {
    setState(() {
      double? price = double.tryParse(_priceController.text);
      localAsset = localAsset.copyWith(price: price);
      widget.onUpdate(localAsset);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _priceController,
          decoration: InputDecoration(labelText: 'Price'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
```

### Explanation:

1. **Pre-populating the Controllers**:

   - In the `initState` method, the `TextEditingController` values are initialized using the corresponding values from the `localAsset` (which is a copy of `widget.asset`).
   - For the `_nameController`, it's straightforward: `localAsset.name` is directly assigned to `_nameController.text`.
   - For the `_priceController`, you might need to convert the `price` (if it exists) to a string, so `localAsset.price?.toString() ?? ''` is used.

2. **Update Logic**:

   - Listeners are added to each `TextEditingController` to update the local asset and notify the parent widget whenever the text changes.

3. **Memory Management**:
   - Don’t forget to dispose of the controllers in the `dispose` method to prevent memory leaks.

Now, when you pass an existing `Asset` to the `ManageAssetDetail` widget, the `TextField`s will be pre-populated with the asset's `name` and `price` values.

## CopyWith Function

---

> I note that the \_updateName function I already had (but hadn't provided in my example) is as follows:
>
> ```dart
> void _updateName() {
>     setState(() {
>       localAsset.name = _nameController.text;
>     });
>     widget.onUpdate(localAsset);
>   }
> ```
>
> But I see you have provided a different functionality using the .copyWith function. How does this differ?

---

The difference between your original `_updateName` function and the version I provided using `.copyWith` comes down to how the `localAsset` object is updated.

### Your Original Approach:

```dart
void _updateName() {
  setState(() {
    localAsset.name = _nameController.text;
  });
  widget.onUpdate(localAsset);
}
```

In your original approach, you are directly modifying the `name` property of the `localAsset` object. This is a straightforward way to update the value, but it has some implications:

- **Mutability**: You are directly mutating the existing `localAsset` object. If `Asset` is a mutable object, this is fine. However, in many cases, especially in Flutter, immutable objects are preferred because they make the application state easier to manage and debug.

### The `.copyWith` Approach:

```dart
void _updateName() {
  setState(() {
    localAsset = localAsset.copyWith(name: _nameController.text);
  });
  widget.onUpdate(localAsset);
}
```

The `.copyWith` approach creates a **new instance** of `Asset` with the updated `name` property, leaving the rest of the properties unchanged.

- **Immutability**: This approach is typically used with immutable objects. In this case, instead of changing the existing object, you create a new `Asset` object with the updated `name` while the rest of the fields remain the same.
- **Safety**: By creating a new object, you avoid unintended side effects where other parts of your application might still hold references to the old object. This is especially useful in complex state management scenarios.

### Which Approach to Use?

- **If `Asset` is Mutable**: Your original approach is fine and straightforward. It's also slightly more performant since you're not creating a new object.

- **If `Asset` is Immutable**: The `.copyWith` approach is necessary. This pattern is common in Flutter, especially when working with models that are designed to be immutable.

### Example of `copyWith` in an Immutable `Asset` Class:

```dart
class Asset {
  final String name;
  final double? price;
  final String id;

  Asset({required this.name, this.price, required this.id});

  Asset copyWith({String? name, double? price, String? id}) {
    return Asset(
      name: name ?? this.name,
      price: price ?? this.price,
      id: id ?? this.id,
    );
  }
}
```

In this example, `Asset` is immutable, and `copyWith` creates a new `Asset` instance with only the properties you want to change.
