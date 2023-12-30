import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback? onOk;
  final VoidCallback? onCancel;
  final String? okText;
  final String? cancelText;
  final bool showOkButton;
  final bool showCancelButton;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.onOk,
    this.onCancel,
    this.okText,
    this.cancelText,
    this.showOkButton = true,
    this.showCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        if (showCancelButton)
          TextButton(
            onPressed: () {
              onCancel?.call();
              Navigator.pop(context, false);
            },
            child: Text(cancelText ?? s.cancel),
          ),
        if (showOkButton)
          FilledButton(
            onPressed: () {
              onOk?.call();
              Navigator.pop(context, true);
            },
            child: Text(okText ?? s.ok),
          ),
      ],
    );
  }
}
