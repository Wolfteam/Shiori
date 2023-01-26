import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/backups/widgets/backup_data_types_selector_dialog.dart';
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
              icon: const Icon(Icons.settings_backup_restore, color: Colors.blue),
              visualDensity: VisualDensity.compact,
              tooltip: s.restore,
              onPressed: () => _restore(s, context),
            ),
/*            IconButton(
              splashRadius: Styles.smallButtonSplashRadius,
              icon: const Icon(Icons.share, color: Colors.green),
              visualDensity: VisualDensity.compact,
              tooltip: s.share,
              onPressed: () {},
            ),*/
            IconButton(
              splashRadius: Styles.smallButtonSplashRadius,
              icon: const Icon(Icons.delete, color: Colors.red),
              visualDensity: VisualDensity.compact,
              tooltip: s.delete,
              onPressed: () => _delete(s, context),
            ),
          ],
        ),
        onTap: () => showDialog<OperationType?>(
          context: context,
          builder: (_) => BlocProvider<BackupRestoreBloc>.value(
            value: context.read<BackupRestoreBloc>(),
            child: BackupDetailsDialog(backup: backup),
          ),
        ).then((op) async {
          switch (op) {
            case OperationType.delete:
              await _delete(s, context);
              break;
            case OperationType.restore:
              await _restore(s, context);
              break;
            case null:
              break;
          }
        }),
      ),
    );
  }

  Future<void> _restore(S s, BuildContext context) {
    return showDialog<List<AppBackupDataType>?>(
      context: context,
      builder: (_) => BackupDataTypesSelectorDialog(
        content: s.restoreBackupConfirmation(backup.filename),
        dataTypes: backup.dataTypes,
        showRestoreWarningMsg: true,
      ),
    ).then((dataTypes) {
      if (dataTypes?.isNotEmpty == true) {
        context.read<BackupRestoreBloc>().add(BackupRestoreEvent.restore(filePath: backup.filePath, dataTypes: dataTypes!));
      }
    });
  }

  Future<void> _delete(S s, BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (_) => ConfirmDialog(title: s.confirm, content: s.deleteBackupConfirmation(backup.filename)),
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<BackupRestoreBloc>().add(BackupRestoreEvent.delete(filePath: backup.filePath));
      }
    });
  }
}
