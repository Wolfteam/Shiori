import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final Function? onOk;
  final String? okText;
  final String? cancelText;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.content,
    this.onOk,
    this.okText,
    this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText ?? s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () {
            onOk?.call();
            Navigator.pop(context, true);
          },
          child: Text(okText ?? s.ok),
        )
      ],
    );
  }
}
