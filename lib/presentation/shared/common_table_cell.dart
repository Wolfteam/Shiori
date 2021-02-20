import 'package:flutter/material.dart';
import 'package:genshindb/domain/extensions/string_extensions.dart';
import 'package:genshindb/presentation/shared/styles.dart';

class CommonTableCell extends StatelessWidget {
  final EdgeInsets padding;
  final String text;
  final TextAlign textAlign;

  final Widget child;

  const CommonTableCell({
    Key key,
    @required this.text,
    this.textAlign = TextAlign.center,
    this.padding = Styles.edgeInsetVertical5,
  })  : child = null,
        super(key: key);

  const CommonTableCell.child({
    Key key,
    @required this.child,
    this.padding = Styles.edgeInsetVertical5,
  })  : text = null,
        textAlign = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: text.isNullEmptyOrWhitespace
          ? child
          : Center(
              child: Padding(
                padding: padding,
                child: Center(
                  child: Tooltip(
                    message: text,
                    child: Text(
                      text,
                      textAlign: textAlign,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
