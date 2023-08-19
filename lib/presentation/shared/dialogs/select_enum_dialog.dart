import 'package:flutter/material.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';

typedef LeadingIcon<TEnum> = Widget Function(TEnum value, int index);
typedef TextResolver<TEnum> = String Function(TEnum value);
typedef OnSave<TEnum> = void Function(TEnum? value);

class SelectEnumDialog<TEnum> extends StatefulWidget {
  final String title;
  final List<TEnum> values;
  final List<TEnum> selectedValues;
  final List<TEnum> excluded;
  final LeadingIcon<TEnum>? leadingIconResolver;
  final TextResolver<TEnum> textResolver;
  final bool lineThroughOnSelectedValues;
  final OnSave<TEnum> onSave;

  const SelectEnumDialog({
    super.key,
    required this.title,
    required this.values,
    required this.selectedValues,
    required this.excluded,
    this.leadingIconResolver,
    required this.textResolver,
    this.lineThroughOnSelectedValues = false,
    required this.onSave,
  });

  @override
  _SelectEnumDialogState<TEnum> createState() => _SelectEnumDialogState<TEnum>();
}

class _SelectEnumDialogState<TEnum> extends State<SelectEnumDialog<TEnum>> {
  TEnum? currentSelectedType;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    final theme = Theme.of(context);
    final values = widget.values;
    if (widget.excluded.isNotEmpty) {
      values.removeWhere((el) => widget.excluded.contains(el));
    }

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        height: mq.getHeightForDialogs(values.length),
        child: ListView.builder(
          itemCount: values.length,
          itemBuilder: (ctx, index) {
            final type = values[index];
            //For some reason I need to wrap this thing on a material to avoid this problem
            // https://stackoverflow.com/questions/67912387/scrollable-listview-bleeds-background-color-to-adjacent-widgets
            final lineThrough = widget.selectedValues.contains(type) && widget.lineThroughOnSelectedValues;
            return Material(
              color: Colors.transparent,
              child: ListTile(
                key: Key('$index'),
                leading: widget.leadingIconResolver?.call(type, index),
                title: Text(
                  widget.textResolver(type),
                  overflow: TextOverflow.ellipsis,
                  style: lineThrough
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: theme.colorScheme.secondary,
                          decorationThickness: 2,
                        )
                      : null,
                ),
                selected: currentSelectedType == type,
                selectedTileColor: theme.colorScheme.secondary.withOpacity(0.2),
                onTap: () {
                  setState(() {
                    currentSelectedType = type;
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
          onPressed: () {
            widget.onSave(currentSelectedType);
          },
          child: Text(s.ok),
        ),
      ],
    );
  }
}
