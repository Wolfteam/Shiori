import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/backups/widgets/backup_details_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/styles.dart';

class BackupListItem extends StatelessWidget {
  final BackupFileItemModel backup;

  const BackupListItem({
    required this.backup,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        title: Tooltip(
          message: backup.filename,
          child: Text(
            backup.filename,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.subtitle2,
          ),
        ),
        subtitle: Text(
          DateFormat.yMd().add_Hm().format(backup.createdAt),
          style: theme.textTheme.caption,
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              splashRadius: Styles.smallButtonSplashRadius,
              icon: const Icon(Icons.settings_backup_restore, color: Colors.green),
              visualDensity: VisualDensity.compact,
              tooltip: s.restore,
              onPressed: () => showDialog<bool?>(
                context: context,
                builder: (_) => ConfirmDialog(title: s.confirm, content: 'Restore backup ${backup.filename} ?'),
              ).then((confirmed) {
                if (confirmed == true) {
                  context.read<BackupRestoreBloc>().add(BackupRestoreEvent.restore(backup.filePath));
                }
              }),
            ),
            IconButton(
              splashRadius: Styles.smallButtonSplashRadius,
              icon: const Icon(Icons.delete, color: Colors.red),
              visualDensity: VisualDensity.compact,
              tooltip: s.delete,
              onPressed: () => showDialog<bool?>(
                context: context,
                builder: (_) => ConfirmDialog(title: s.confirm, content: 'Delete backup ${backup.filename} ?'),
              ).then((confirmed) {
                if (confirmed == true) {
                  context.read<BackupRestoreBloc>().add(BackupRestoreEvent.delete(backup.filePath));
                }
              }),
            ),
          ],
        ),
        onTap: () => showDialog(
          context: context,
          builder: (_) => BackupDetailsDialog(backup: backup),
        ),
      ),
    );
  }
}
