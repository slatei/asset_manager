import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

mixin BottomAppBarMixin<T extends StatefulWidget> on State<T> {
  late ScrollController appBarController;
  bool appBarIsVisible = true;

  FloatingActionButtonLocation get appBarFabLocation => appBarIsVisible
      ? FloatingActionButtonLocation.endContained
      : FloatingActionButtonLocation.endFloat;

  void _listen() {
    switch (appBarController.position.userScrollDirection) {
      case ScrollDirection.idle:
        break;
      case ScrollDirection.forward:
        _show();
      case ScrollDirection.reverse:
        _hide();
    }
  }

  void _show() {
    if (!appBarIsVisible) {
      setState(() => appBarIsVisible = true);
    }
  }

  void _hide() {
    if (appBarIsVisible) {
      setState(() => appBarIsVisible = false);
    }
  }

  @override
  void initState() {
    appBarController = ScrollController();
    appBarController.addListener(_listen);

    super.initState();
  }
}
