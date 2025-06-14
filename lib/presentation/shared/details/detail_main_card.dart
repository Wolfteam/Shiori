import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CardRow {
  final CardColumn left;
  final CardColumn? right;

  CardRow({required this.left, this.right});
}

class CardColumn {
  final String title;
  final Widget child;

  CardColumn({required this.title, required this.child});
}

class DetailMainCard extends StatelessWidget {
  final String itemName;
  final Color color;
  final List<CardRow> rows;

  const DetailMainCard({
    super.key,
    required this.itemName,
    required this.color,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double width = MediaQuery.of(context).size.width;
    return Container(
      constraints: BoxConstraints(minWidth: min(300, width * 0.3), maxWidth: min(500, width * 0.8)),
      child: Card(
        color: color.withValues(alpha: 0.5),
        shape: Styles.cardShape,
        child: Padding(
          padding: Styles.edgeInsetAll10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              ...rows.map((e) => _Row(row: e)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final CardRow row;

  const _Row({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _Column(column: row.left)),
        if (row.right != null)
          Expanded(
            child: _Column(column: row.right!),
          ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  final CardColumn column;

  const _Column({required this.column});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          column.title,
          style: theme.textTheme.titleMedium!.copyWith(color: Colors.white),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: column.child,
        ),
      ],
    );
  }
}
