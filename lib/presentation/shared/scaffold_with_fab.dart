import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/extensions/focus_scope_node_extensions.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';

class ScaffoldWithFab extends StatefulWidget {
  final Widget child;
  final PreferredSizeWidget? appbar;

  const ScaffoldWithFab({
    super.key,
    required this.child,
    this.appbar,
  });

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
