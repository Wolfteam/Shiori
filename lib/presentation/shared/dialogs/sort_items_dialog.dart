import 'package:flutter/material.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class SortItemsDialog extends StatefulWidget {
  final List<SortableItem> items;
  final void Function(SortResult result) onSave;

  const SortItemsDialog({
    super.key,
    required this.items,
    required this.onSave,
  });

  @override
  State<SortItemsDialog> createState() => _SortItemsDialogState();
}

class _SortItemsDialogState extends State<SortItemsDialog> {
  List<SortableItem> _items = [];

  @override
  void initState() {
    _items = [...widget.items];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    final mq = MediaQuery.of(context);
    return AlertDialog(
      title: Text(s.sort),
      content: SizedBox(
        height: mq.getHeightForDialogs(_items.length),
        width: mq.getWidthForDialogs(),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          itemCount: _items.length,
          itemBuilder: (ctx, index) {
            final item = _items[index];
            final position = index + 1;
            return ListTile(
              key: Key('$index'),
              title: Text('#$position - ${item.text}', overflow: TextOverflow.ellipsis),
              onTap: () => ToastUtils.showInfoToast(fToast, s.holdToReorder),
            );
          },
          onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, context),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => _discardChanges(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => _applyChanges(context),
          child: Text(s.save),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex, BuildContext context) {
    final item = _items.elementAt(oldIndex);

    int updatedNewIndex = newIndex;
    if (updatedNewIndex >= _items.length) {
      updatedNewIndex--;
    }
    if (updatedNewIndex < 0) {
      updatedNewIndex = 0;
    }

    setState(() {
      _items.removeAt(oldIndex);
      _items.insert(updatedNewIndex, item);
    });
  }

  void _discardChanges(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _applyChanges(BuildContext context) {
    bool somethingChanged = false;
    for (var i = 0; i < widget.items.length; i++) {
      final current = widget.items[i];
      if (current.key != _items[i].key) {
        somethingChanged = true;
        break;
      }
    }

    widget.onSave(SortResult(somethingChanged, _items));
    Navigator.of(context).pop();
  }
}
