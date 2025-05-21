import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';

class ClearAllDialog extends StatefulWidget {
  const ClearAllDialog({super.key});

  @override
  _ClearAllDialogState createState() => _ClearAllDialogState();
}

class _ClearAllDialogState extends State<ClearAllDialog> {
  String? _itemToClear;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final items = [
      s.characters,
      s.weapons,
      s.materials,
    ];
    return AlertDialog(
      title: Text(s.clearAll),
      content: SizedBox(
        width: MediaQuery.of(context).getWidthForDialogs(),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (ctx, index) {
            final item = items.elementAt(index);
            return ListTile(
              key: Key('$index'),
              title: Text(item, overflow: TextOverflow.ellipsis),
              selectedTileColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
              selected: _itemToClear == item,
              onTap: () {
                setState(() {
                  _itemToClear = item;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () => _clearAll(context),
          child: Text(s.ok),
        ),
      ],
    );
  }

  void _clearAll(BuildContext context) {
    final s = S.of(context);

    if (_itemToClear == s.characters) {
      context.read<InventoryBloc>().add(const InventoryEvent.clearAllCharacters());
    } else if (_itemToClear == s.weapons) {
      context.read<InventoryBloc>().add(const InventoryEvent.clearAllWeapons());
    } else if (_itemToClear == s.materials) {
      context.read<InventoryBloc>().add(const InventoryEvent.clearAllMaterials());
    }

    Navigator.pop(context);
  }
}
