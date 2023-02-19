import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';

class RestoreBackupWarningMsg extends StatelessWidget {
  const RestoreBackupWarningMsg({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Text(
        s.restoreBackupMsgWarning,
        style: theme.textTheme.titleSmall!.copyWith(fontStyle: FontStyle.italic, color: theme.primaryColor),
      ),
    );
  }
}
