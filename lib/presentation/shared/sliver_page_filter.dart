import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/search_box.dart';

class SliverPageFilter extends StatelessWidget {
  final String title;
  final String? search;
  final VoidCallback onPressed;
  final SearchChanged searchChanged;

  const SliverPageFilter({
    super.key,
    required this.title,
    this.search,
    required this.onPressed,
    required this.searchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showClearButton = search != null && search!.isNotEmpty;
    return SliverToBoxAdapter(
      child: Column(
        children: [
          SearchBox(
            value: search,
            showClearButton: showClearButton,
            searchChanged: searchChanged,
            onFilterTap: onPressed,
          ),
        ],
      ),
    );
  }
}
