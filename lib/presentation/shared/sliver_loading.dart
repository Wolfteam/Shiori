import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/loading.dart';

class SliverLoading extends StatelessWidget {
  const SliverLoading();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(hasScrollBody: false, child: Loading(useScaffold: false));
  }
}
