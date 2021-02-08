import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';

import 'bottom_sheet_title.dart';
import 'modal_sheet_separator.dart';
import 'styles.dart';

class CommonBottomSheet extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final Widget child;
  final Function onOk;
  final Function onCancel;
  final double iconSize;
  final bool showOkButton;
  final bool showCancelButton;

  const CommonBottomSheet({
    Key key,
    @required this.title,
    @required this.titleIcon,
    @required this.onOk,
    this.onCancel,
    @required this.child,
    this.iconSize = 25,
    this.showOkButton = true,
    this.showCancelButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        margin: Styles.modalBottomSheetContainerMargin,
        padding: Styles.modalBottomSheetContainerPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ModalSheetSeparator(),
            BottomSheetTitle(icon: titleIcon, title: title, iconSize: iconSize),
            child,
            if (showOkButton || showCancelButton)
              ButtonBar(
                buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
                children: <Widget>[
                  if (showCancelButton)
                    OutlineButton(
                      onPressed: () => onCancel != null ? onCancel() : Navigator.pop(context),
                      child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
                    ),
                  if (showOkButton)
                    RaisedButton(
                      color: theme.primaryColor,
                      onPressed: () => onOk(),
                      child: Text(s.ok),
                    )
                ],
              )
          ],
        ),
      ),
    );
  }
}
