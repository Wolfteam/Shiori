import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CommonTableCell extends StatelessWidget {
  final EdgeInsets padding;
  final String? text;
  final TextAlign? textAlign;

  final Widget? child;

  const CommonTableCell({
    Key? key,
    required this.text,
    this.textAlign = TextAlign.center,
    this.padding = Styles.edgeInsetVertical5,
  })  : child = null,
        super(key: key);

  const CommonTableCell.child({
    Key? key,
    required this.child,
  })  : text = null,
        textAlign = null,
        padding = Styles.edgeInsetVertical5,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: text.isNullEmptyOrWhitespace
          ? child!
          : Center(
              child: Padding(
                padding: padding,
                child: Center(
                  child: Tooltip(
                    message: text!,
                    child: Text(
                      text!,
                      textAlign: textAlign,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
