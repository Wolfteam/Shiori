import 'package:flutter/material.dart';

import 'nothing_found_column.dart';

class SliverNothingFound extends StatelessWidget {
  final String msg;
  final IconData icon;
  final EdgeInsets padding;

  const SliverNothingFound({
    this.msg,
    this.icon = Icons.info,
    this.padding = const EdgeInsets.only(bottom: 30, right: 20, left: 20),
  });

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: NothingFoundColumn(),
    );
  }
}
