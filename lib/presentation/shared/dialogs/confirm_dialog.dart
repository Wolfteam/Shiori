import 'package:flutter/material.dart';
import 'package:genshindb/generated/l10n.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final Function onOk;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onOk,
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
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () {
            onOk();
            Navigator.pop(context);
          },
          child: Text(s.ok),
        )
      ],
    );
  }
}
