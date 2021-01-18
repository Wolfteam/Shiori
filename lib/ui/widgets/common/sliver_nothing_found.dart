import 'package:flutter/material.dart';

import 'nothing_found_column.dart';

class SliverNothingFound extends StatelessWidget {
  const SliverNothingFound();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: NothingFoundColumn(),
    );
  }
}
