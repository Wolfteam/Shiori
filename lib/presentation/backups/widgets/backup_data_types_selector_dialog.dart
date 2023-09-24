import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/app_backup_data_type.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/backups/widgets/restore_backup_warning_msg.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class BackupDataTypesSelectorDialog extends StatefulWidget {
  final String content;
  final List<AppBackupDataType> dataTypes;
  final bool showRestoreWarningMsg;

  const BackupDataTypesSelectorDialog({
    super.key,
    required this.content,
    required this.dataTypes,
    this.showRestoreWarningMsg = false,
  });

  @override
  State<BackupDataTypesSelectorDialog> createState() => _BackupDataTypesSelectorDialogState();
}

class _BackupDataTypesSelectorDialogState extends State<BackupDataTypesSelectorDialog> {
  List<AppBackupDataType> _selectedDataTypes = [];

  @override
  void initState() {
    _selectedDataTypes = [...widget.dataTypes];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(s.confirm),
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.content),
          ...EnumUtils.getTranslatedAndSortedEnum<AppBackupDataType>(
            widget.dataTypes,
            (value, index) => s.translateAppBackupDataType(value),
          ).map(
            (e) => CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              title: Text(e.translation),
              activeColor: theme.primaryColor,
              value: _selectedDataTypes.contains(e.enumValue),
              onChanged: (bool? value) => _onChange(e.enumValue),
            ),
          ),
          if (widget.showRestoreWarningMsg) const RestoreBackupWarningMsg(),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: _selectedDataTypes.isEmpty ? null : () => Navigator.pop(context, _selectedDataTypes),
          child: Text(s.ok),
        ),
      ],
    );
  }

  void _onChange(AppBackupDataType type) {
    setState(() {
      if (_selectedDataTypes.contains(type)) {
        _selectedDataTypes.remove(type);
      } else {
        _selectedDataTypes.add(type);
      }
    });
  }
}
