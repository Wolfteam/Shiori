import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shiori/generated/l10n.dart';

class TierListRowColorPicker extends StatefulWidget {
  final Color currentColor;

  const TierListRowColorPicker({
    super.key,
    required this.currentColor,
  });

  @override
  _TierListRowColorPickerState createState() => _TierListRowColorPickerState();
}

class _TierListRowColorPickerState extends State<TierListRowColorPicker> {
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.pickColor),
      content: BlockPicker(
        pickerColor: widget.currentColor,
        onColorChanged: (color) {
          setState(() {
            selectedColor = color;
          });
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(widget.currentColor),
          child: Text(
            s.cancel,
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(selectedColor ?? widget.currentColor),
          child: Text(s.ok),
        ),
      ],
    );
  }
}
