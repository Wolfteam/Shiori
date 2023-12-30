import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/number_picker.dart';

typedef ItemBuilder = String Function(String);

class NumberPickerDialog extends StatefulWidget {
  final int minItemLevel;
  final int maxItemLevel;
  final int value;
  final String title;
  final ItemBuilder? itemBuilder;

  const NumberPickerDialog({
    super.key,
    required this.minItemLevel,
    required this.maxItemLevel,
    required this.value,
    required this.title,
    this.itemBuilder,
  });

  @override
  _NumberPickerDialogState createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  int _currentValue = 0;

  @override
  void initState() {
    _currentValue = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(widget.title),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop<int>(context, _currentValue),
          child: Text(s.ok),
        ),
      ],
      content: NumberPicker(
        minValue: widget.minItemLevel,
        maxValue: widget.maxItemLevel,
        value: _currentValue,
        textMapper: widget.itemBuilder,
        infiniteLoop: true,
        onChanged: (newValue) => setState(() {
          _currentValue = newValue;
        }),
      ),
    );
  }
}
