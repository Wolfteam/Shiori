import 'package:flutter/material.dart';

import 'app_fab.dart';
import 'extensions/focus_scope_node_extensions.dart';
import 'extensions/scroll_controller_extensions.dart';

class ScaffoldWithFab extends StatefulWidget {
  final Widget child;
  final PreferredSizeWidget appbar;

  const ScaffoldWithFab({
    Key key,
    @required this.child,
    this.appbar,
  }) : super(key: key);

  @override
  _ScaffoldWithFabState createState() => _ScaffoldWithFabState();
}

class _ScaffoldWithFabState extends State<ScaffoldWithFab> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 0, // initially not visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).removeFocus();
      },
      child: Scaffold(
        appBar: widget.appbar,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: widget.child,
          ),
        ),
        floatingActionButton: AppFab(
          hideFabAnimController: _hideFabAnimController,
          scrollController: _scrollController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }
}
