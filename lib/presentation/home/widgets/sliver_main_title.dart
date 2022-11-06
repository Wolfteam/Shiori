import 'package:flutter/material.dart';
import 'package:shiori/presentation/home/widgets/main_title.dart';

class SliverMainTitle extends StatelessWidget {
  final String title;

  const SliverMainTitle({
    super.key,
    required this.title,
  });

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
