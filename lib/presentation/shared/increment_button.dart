import 'package:flutter/material.dart';
import 'package:shiori/presentation/shared/styles.dart';

class IncrementButton extends StatelessWidget {
  final String title;
  final int value;
  final bool incrementIsDisabled;
  final bool decrementIsDisabled;
  final Function(int) onMinus;
  final Function(int) onAdd;

  const IncrementButton({
    super.key,
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onAdd,
    this.incrementIsDisabled = false,
    this.decrementIsDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Container(
      margin: Styles.edgeInsetVertical5,
      child: Column(
        children: [
          Text(title),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: const Icon(Icons.remove),
                  splashRadius: 20,
                  color: color,
                  constraints: const BoxConstraints(),
                  onPressed: decrementIsDisabled ? null : () => onMinus(value - 1),
                ),
              ),
              Text('$value'),
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  splashRadius: 20,
                  color: color,
                  constraints: const BoxConstraints(),
                  onPressed: incrementIsDisabled ? null : () => onAdd(value + 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
