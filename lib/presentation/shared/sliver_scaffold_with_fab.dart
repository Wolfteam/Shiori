import 'package:flutter/material.dart';

import 'extensions/focus_scope_node_extensions.dart';
import 'mixins/app_fab_mixin.dart';

class SliverScaffoldWithFab extends StatefulWidget {
  final List<Widget> slivers;
  final PreferredSizeWidget? appbar;

  const SliverScaffoldWithFab({
    Key? key,
    required this.slivers,
    this.appbar,
  }) : super(key: key);

  @override
  _SliverScaffoldWithFabState createState() => _SliverScaffoldWithFabState();
}

class _SliverScaffoldWithFabState extends State<SliverScaffoldWithFab> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).removeFocus();
      },
      child: Scaffold(
        appBar: widget.appbar,
        body: SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: widget.slivers,
          ),
        ),
        floatingActionButton: getAppFab(),
      ),
    );
  }
}
