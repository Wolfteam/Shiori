import 'package:flutter/material.dart';

class DetailAppBar extends StatelessWidget {
  final List<Widget> actions;

  const DetailAppBar({
    super.key,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      actions: actions,
    );
  }
}
