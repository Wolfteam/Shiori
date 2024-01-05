import 'package:flutter/material.dart';

class ModalSheetSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        child: SizedBox(
          width: 100,
          height: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
