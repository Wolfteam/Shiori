import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/backups/widgets/restore_backup_warning_msg.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

enum OperationType {
  delete,
  restore,
}

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
          Text(backup.filename, style: theme.textTheme.titleMedium),
          Text(s.appVersion(backup.appVersion)),
          Text(s.dateX(DateFormat.yMd().add_Hm().format(backup.createdAt))),
          ...EnumUtils.getTranslatedAndSortedEnum<AppBackupDataType>(
            backup.dataTypes,
            (value, index) => s.translateAppBackupDataType(value),
          ).map(
            (e) => CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              title: Text(e.translation),
              activeColor: theme.primaryColor,
              value: true,
              enabled: false,
              onChanged: (_) {},
            ),
          ),
          const RestoreBackupWarningMsg(),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, OperationType.delete),
          child: Text(s.delete),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, OperationType.restore),
          child: Text(s.restore),
        ),
      ],
    );
  }
}
