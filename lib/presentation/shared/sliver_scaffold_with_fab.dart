import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/extensions/focus_scope_node_extensions.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';

class SliverScaffoldWithFab extends StatefulWidget {
  final List<Widget> slivers;
  final PreferredSizeWidget? appbar;
  final ScrollController? scrollController;

  const SliverScaffoldWithFab({
    super.key,
    required this.slivers,
    this.appbar,
    this.scrollController,
  });

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
            controller: widget.scrollController ?? scrollController,
            slivers: widget.slivers,
          ),
        ),
        floatingActionButton: getAppFab(customController: widget.scrollController),
      ),
    );
  }
}
