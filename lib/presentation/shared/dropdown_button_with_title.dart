import 'package:flutter/material.dart';
import 'package:genshindb/domain/extensions/iterable_extensions.dart';

class DropdownButtonWithTitle<T> extends StatelessWidget {
  final String title;
  final T currentValue;
  final bool isExpanded;
  final Iterable<T> items;
  final void Function(T)? onChanged;
  final Widget Function(T, int) itemBuilder;
  final EdgeInsets margin;

  const DropdownButtonWithTitle({
    Key? key,
    required this.title,
    required this.currentValue,
    required this.items,
    required this.itemBuilder,
    this.onChanged,
    this.isExpanded = true,
    this.margin = const EdgeInsets.only(bottom: 15, top: 10),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            transform: Matrix4.translationValues(0.0, 5.0, 0.0),
            child: Text(title, style: theme.textTheme.caption),
          ),
          DropdownButton<T>(
            isExpanded: isExpanded,
            hint: Text(title),
            value: currentValue,
            onChanged: onChanged != null ? (v) => onChanged!(v!) : null,
            items: items.mapIndex((item, index) => DropdownMenuItem<T>(value: item, child: itemBuilder(item, index))).toList(),
          ),
        ],
      ),
    );
  }
}
