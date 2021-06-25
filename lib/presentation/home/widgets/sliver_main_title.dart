import 'package:flutter/material.dart';

import 'main_title.dart';

class SliverMainTitle extends StatelessWidget {
  final String title;

  const SliverMainTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: MainTitle(title: title),
      ),
    );
  }
}
