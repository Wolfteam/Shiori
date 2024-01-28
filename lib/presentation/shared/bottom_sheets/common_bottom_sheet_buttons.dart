import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/bottom_sheets/common_button_bar.dart';

class CommonButtonSheetButtons extends StatelessWidget {
  final bool showCancelButton;
  final bool showOkButton;
  final VoidCallback? onOk;
  final VoidCallback? onCancel;

  final String? cancelText;
  final String? okText;

  const CommonButtonSheetButtons({
    super.key,
    this.showCancelButton = true,
    this.showOkButton = true,
    this.onOk,
    this.onCancel,
    this.cancelText,
    this.okText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    final cancel = cancelText ?? s.cancel;
    final ok = okText ?? s.ok;

    return CommonButtonBar(
      children: <Widget>[
        if (showCancelButton)
          TextButton(
            onPressed: () => onCancel != null ? onCancel!() : Navigator.pop(context),
            child: Text(cancel),
          ),
        if (showOkButton)
          FilledButton(
            onPressed: onOk != null ? () => onOk!() : null,
            child: Text(ok),
          ),
      ],
    );
  }
}
