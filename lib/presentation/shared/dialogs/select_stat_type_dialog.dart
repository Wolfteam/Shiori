import 'package:flutter/material.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/i18n_extensions.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/utils/enum_utils.dart';

class SelectStatTypeDialog extends StatefulWidget {
  final List<StatType> values;

  const SelectStatTypeDialog({
    Key? key,
    required this.values,
  }) : super(key: key);

  @override
  State<SelectStatTypeDialog> createState() => _SelectStatTypeDialogState();
}

class _SelectStatTypeDialogState extends State<SelectStatTypeDialog> {
  StatType? currentSelectedType;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);
    final values = EnumUtils.getTranslatedAndSortedEnum<StatType>(widget.values, (type, _) => s.translateStatTypeWithoutValue(type));

    return AlertDialog(
      title: Text(s.stats),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        height: mq.getHeightForDialogs(widget.values.length),
        child: ListView.builder(
          itemCount: values.length,
          itemBuilder: (ctx, index) {
            final type = values[index];
            //For some reason I need to wrap this thing on a material to avoid this problem
            // https://stackoverflow.com/questions/67912387/scrollable-listview-bleeds-background-color-to-adjacent-widgets
            return Material(
              color: Colors.transparent,
              child: ListTile(
                key: Key('$index'),
                title: Text(
                  type.translation,
                  overflow: TextOverflow.ellipsis,
                ),
                selected: currentSelectedType == type.enumValue,
                selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                onTap: () {
                  setState(() {
                    currentSelectedType = type.enumValue;
                  });
                },
              ),
            );
          },
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop<StatType>(context, currentSelectedType),
          child: Text(s.ok),
        )
      ],
    );
  }
}
