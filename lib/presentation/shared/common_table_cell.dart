import 'package:flutter/material.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CommonTableCell extends StatelessWidget {
  final EdgeInsets padding;
  final String? text;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  final Widget? child;

  const CommonTableCell({
    super.key,
    required this.text,
    this.textAlign = TextAlign.center,
    this.padding = Styles.edgeInsetVertical5,
    this.textStyle,
  }) : child = null;

  const CommonTableCell.child({
    super.key,
    required this.child,
  })  : text = null,
        textAlign = null,
        textStyle = null,
        padding = Styles.edgeInsetVertical5;

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
                    message: text,
                    child: Text(
                      text!,
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                      style: textStyle,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
