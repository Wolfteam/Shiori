import 'package:flutter/material.dart';

import 'nothing_found.dart';

class SliverNothingFound extends StatelessWidget {
  const SliverNothingFound();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [NothingFound()],
      ),
    );
  }
}
