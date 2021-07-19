import 'package:flutter/material.dart';

class DetailAppBar extends StatelessWidget {
  final List<Widget> actions;

  const DetailAppBar({
    Key? key,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      actions: actions,
    );
  }
}
