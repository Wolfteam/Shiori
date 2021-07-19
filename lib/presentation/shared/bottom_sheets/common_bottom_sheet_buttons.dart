import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';

class CommonButtonSheetButtons extends StatelessWidget {
  final bool showCancelButton;
  final bool showOkButton;
  final Function? onOk;
  final Function? onCancel;

  final String? cancelText;
  final String? okText;

  const CommonButtonSheetButtons({
    Key? key,
    this.showCancelButton = true,
    this.showOkButton = true,
    this.onOk,
    this.onCancel,
    this.cancelText,
    this.okText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    final cancel = cancelText ?? s.cancel;
    final ok = okText ?? s.ok;

    return ButtonBar(
      buttonPadding: const EdgeInsets.symmetric(horizontal: 10),
      children: <Widget>[
        if (showCancelButton)
          OutlinedButton(
            onPressed: () => onCancel != null ? onCancel!() : Navigator.pop(context),
            child: Text(cancel, style: TextStyle(color: theme.primaryColor)),
          ),
        if (showOkButton)
          ElevatedButton(
            onPressed: onOk != null ? () => onOk!() : null,
            child: Text(ok),
          )
      ],
    );
  }
}
