import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TierListRowColorPicker extends StatefulWidget {
  final Color currentColor;

  const TierListRowColorPicker({
    Key key,
    @required this.currentColor,
  }) : super(key: key);

  @override
  _TierListRowColorPickerState createState() => _TierListRowColorPickerState();
}

class _TierListRowColorPickerState extends State<TierListRowColorPicker> {
  Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        // child: ColorPicker(
        //   pickerColor: Color(0xff443a49),
        //   onColorChanged: (color) => {},
        //   showLabel: true,
        //   pickerAreaHeightPercent: 0.8,
        // ),
        // Use Material color picker:
        //
        // child: MaterialPicker(
        //   pickerColor: Color(0xff443a49),
        //   onColorChanged: (color) => {},
        //   enableLabel: true,
        // ),
        //
        // Use Block color picker:
        //
        child: BlockPicker(
          pickerColor: widget.currentColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        ),
        //
        // child: MultipleChoiceBlockPicker(
        //   pickerColors: currentColors,
        //   onColorsChanged: changeColors,
        // ),
      ),
      actions: <Widget>[
        OutlineButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.primaryColor),
          ),
          onPressed: () => Navigator.of(context).pop(widget.currentColor),
        ),
        RaisedButton(
          child: Text('Ok'),
          onPressed: () => Navigator.of(context).pop(selectedColor ?? widget.currentColor),
        ),
      ],
    );
  }
}
