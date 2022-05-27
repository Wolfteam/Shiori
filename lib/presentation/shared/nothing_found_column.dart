import 'package:flutter/material.dart';

import 'nothing_found.dart';

class NothingFoundColumn extends StatelessWidget {
  final String? msg;
  final IconData icon;
  final EdgeInsets padding;
  final MainAxisSize mainAxisSize;

  const NothingFoundColumn({
    this.msg,
    this.icon = Icons.info,
    this.padding = const EdgeInsets.only(bottom: 30, right: 20, left: 20),
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: mainAxisSize,
      children: [NothingFound(msg: msg, icon: icon, padding: padding)],
    );
  }
}
