import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/presentation/shared/styles.dart';

class ItemCommonWithNameAppBarSearchDelegate extends SearchDelegate<List<String>> {
  final List<ItemCommonWithName> items;
  final List<String> selected;

  ItemCommonWithNameAppBarSearchDelegate(this.items, this.selected);

  ItemCommonWithNameAppBarSearchDelegate.withNameOnly({
    required List<ItemCommonWithNameOnly> itemsWithNameOnly,
    required this.selected,
  }) : items = itemsWithNameOnly.map((e) => ItemCommonWithName(e.key, '', e.name)).toList();

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () => close(context, selected),
          splashRadius: Styles.mediumButtonSplashRadius,
        ),
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.red),
          splashRadius: Styles.mediumButtonSplashRadius,
          onPressed: () {
            if (query.isNullEmptyOrWhitespace) {
              close(context, []);
            } else {
              query = '';
            }
          },
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, selected),
        splashRadius: Styles.mediumButtonSplashRadius,
      );

  @override
  Widget buildResults(BuildContext context) => Text(
        query,
        overflow: TextOverflow.ellipsis,
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final possibilities = query.isNullEmptyOrWhitespace ? items : items.where((el) => el.name.toLowerCase().contains(query.toLowerCase())).toList();
    possibilities.sort((x, y) => x.name.compareTo(y.name));

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => ListView.builder(
        itemCount: possibilities.length,
        itemBuilder: (ctx, index) {
          final item = possibilities[index];
          final isSelected = selected.any((el) => el == item.key);
          return ListTile(
            title: Text(item.name, overflow: TextOverflow.ellipsis),
            leading: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
            minLeadingWidth: 10,
            onTap: () {
              if (isSelected) {
                setState(() => selected.remove(item.key));
              } else {
                setState(() => selected.add(item.key));
              }
            },
          );
        },
      ),
    );
  }
}
