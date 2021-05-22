import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:numberpicker/numberpicker.dart';

class NumberPickerDialog extends StatefulWidget {
  final int minItemLevel;
  final int maxItemLevel;
  final int value;
  final String title;

  const NumberPickerDialog({
    Key key,
    @required this.minItemLevel,
    @required this.maxItemLevel,
    @required this.value,
    @required this.title,
  }) : super(key: key);

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
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop<int>(context, _currentValue),
          child: Text(s.ok),
        )
      ],
      content: NumberPicker(
        minValue: widget.minItemLevel,
        maxValue: widget.maxItemLevel,
        value: _currentValue,
        infiniteLoop: true,
        onChanged: (newValue) => setState(() {
          _currentValue = newValue;
        }),
      ),
    );
  }
}
