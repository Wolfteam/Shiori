import 'package:flutter/material.dart';

import 'bottom_sheet_title.dart';
import 'common_bottom_sheet_buttons.dart';
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
    this.onOk,
    this.onCancel,
    @required this.child,
    this.iconSize = 25,
    this.showOkButton = true,
    this.showCancelButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              CommonButtonSheetButtons(
                showOkButton: showOkButton,
                showCancelButton: showCancelButton,
                onCancel: onCancel,
                onOk: onOk,
              ),
          ],
        ),
      ),
    );
  }
}
