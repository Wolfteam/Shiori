import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shiori/application/backup_restore/backup_restore_bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';

class BackupDetailsDialog extends StatelessWidget {
  final BackupFileItemModel backup;

  const BackupDetailsDialog({
    super.key,
    required this.backup,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(s.details),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(backup.filename, style: theme.textTheme.subtitle1),
          Text(s.appVersion(backup.appVersion)),
          Text('Date: ${DateFormat.yMd().add_Hm().format(backup.createdAt)}'),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Text(
              'Keep in mind that restoring a backup will replace all your existing data and configuration',
              style: theme.textTheme.subtitle2!.copyWith(fontStyle: FontStyle.italic, color: theme.primaryColor),
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => context.read<BackupRestoreBloc>().add(BackupRestoreEvent.delete(backup.filePath)),
          child: Text(s.delete),
        ),
        ElevatedButton(
          onPressed: () => context.read<BackupRestoreBloc>().add(BackupRestoreEvent.restore(backup.filePath)),
          child: Text(s.restore),
        ),
      ],
    );
  }
}
