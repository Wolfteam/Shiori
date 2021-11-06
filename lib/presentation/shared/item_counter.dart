import 'package:flutter/material.dart';

class ItemCounter extends StatelessWidget {
  final int _items;
  const ItemCounter(
    this._items,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Align(
        child: Text(
          '$_items',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
