import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

typedef OnAddOrRemove = void Function(int);
typedef GetValueString = String Function(int);

class IncrementButton extends StatelessWidget {
  final String title;
  final int value;
  final bool incrementIsDisabled;
  final bool decrementIsDisabled;
  final OnAddOrRemove onMinus;
  final OnAddOrRemove onAdd;
  final GetValueString? getValueString;
  final EdgeInsets margin;

  const IncrementButton({
    super.key,
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onAdd,
    this.incrementIsDisabled = false,
    this.decrementIsDisabled = false,
    this.getValueString,
    this.margin = Styles.edgeInsetVertical5,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                color: color,
                onPressed: decrementIsDisabled ? null : () => onMinus(value - 1),
              ),
              Text(getValueString?.call(value) ?? '$value'),
              IconButton(
                icon: const Icon(Icons.add),
                color: color,
                onPressed: incrementIsDisabled ? null : () => onAdd(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
