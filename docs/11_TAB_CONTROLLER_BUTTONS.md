# Controlling Tabs With Buttons <!-- omit in toc -->

- [Controlling Tabs With Buttons](#controlling-tabs-with-buttons)
  - [Explanation](#explanation)

## Controlling Tabs With Buttons

---

> I have the following flutter widget, which is a couple of navigate buttons that are placed at the bottom of a tabbed window
>
> I would like to be able to use the buttons to go to the next tab or previous tab. If the tab is the first disable, disable the "back" button, and if it's the last tab, disable the "next" button
>
> I have the following code:
>
> ```dart
> import 'package:flutter/material.dart';
>
> class AssetButtons extends StatelessWidget {
>  const AssetButtons({
>    // required this.back,
>    // required this.next,
>    required this.tabController,
>    required this.add,
>    super.key,
>  });
>
>  final TabController tabController;
>  // final Function() back;
>  // final Function() next;
>  final Function() add;
>
>  @override
>  Widget build(BuildContext context) {
>    return Row(
>      children: [
>        OutlinedButton(
>          onPressed: tabController.index != 0
>              ? () => tabController.animateTo(tabController.index - 1)
>              : null,
>          child: const Text('Back'),
>        ),
>        const SizedBox(width: 10),
>        OutlinedButton(
>          onPressed: tabController.index <= tabController.length
>              ? () => tabController.animateTo(tabController.index + 1)
>              : null,
>          child: const Text('Next'),
>        ),
>        const Expanded(child: SizedBox()),
>        FilledButton.icon(
>          onPressed: add,
>          icon: const Icon(Icons.add, size: 18),
>          label: const Text('Add'),
>        ),
>      ],
>    );
>  }
> }
> ```
>
> The buttons, when pressed, will correctly change to the next tab, however the buttons don't correctly become enabled or disabled when the tabController index is updated. Do I need to notify listeners when clicking on the buttons?

---

Yes, to ensure that the buttons become enabled or disabled when the `tabController` index is updated, you need to listen for changes to the `TabController` and rebuild the `AssetButtons` widget accordingly. This can be done using a `StatefulWidget` instead of a `StatelessWidget`.

Here is the modified code using `StatefulWidget`:

```dart
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
  _AssetButtonsState createState() => _AssetButtonsState();
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
    return Row(
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
    );
  }
}
```

### Explanation

1. **StatefulWidget and State:** changed `AssetButtons` to be a `StatefulWidget` with a corresponding `_AssetButtonsState` class.
2. **Listener:** added a listener to the `TabController` in `initState` that calls `setState` to update the widget when the tab index changes.
3. **Dispose:** removed the listener in the `dispose` method to prevent memory leaks.
4. **Button Enable/Disable Logic:** updated the logic for the "Next" button to check if the current index is less than the total number of tabs minus one (`_tabController.index < _tabController.length - 1`) to correctly handle enabling/disabling the button.

This ensures that the buttons are correctly enabled or disabled based on the current tab index.
