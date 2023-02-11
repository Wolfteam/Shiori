import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/search_box.dart';
import 'package:shiori/presentation/shared/shiori_icons.dart';

typedef OnPressed = void Function();

class SliverPageFilter extends StatelessWidget {
  final String title;
  final String? search;
  final OnPressed onPressed;
  final Function(String) searchChanged;

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
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Shiori.filter, size: 20),
                  onPressed: () => onPressed(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
