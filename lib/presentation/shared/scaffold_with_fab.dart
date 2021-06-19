import 'package:flutter/material.dart';

import 'extensions/focus_scope_node_extensions.dart';
import 'mixins/app_fab_mixin.dart';

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

class _ScaffoldWithFabState extends State<ScaffoldWithFab> with SingleTickerProviderStateMixin, AppFabMixin {
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
            controller: scrollController,
            child: widget.child,
          ),
        ),
        floatingActionButton: getAppFab(),
      ),
    );
  }
}
