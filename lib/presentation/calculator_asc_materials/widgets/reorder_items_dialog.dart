import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class ReorderItemsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    final mq = MediaQuery.of(context);
    return AlertDialog(
      title: Text(s.priority),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<CalculatorAscMaterialsOrderBloc, CalculatorAscMaterialsOrderState>(
            builder: (ctx, state) => SizedBox(
              height: mq.getHeightForDialogs(state.items.length),
              width: mq.getWidthForDialogs(),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: state.items.length,
                itemBuilder: (ctx, index) {
                  final item = state.items[index];
                  final position = index + 1;
                  return ListTile(
                    key: Key('$index'),
                    title: Text('#$position - ${item.name}', overflow: TextOverflow.ellipsis),
                    onTap: () => ToastUtils.showInfoToast(fToast, s.holdToReorder),
                  );
                },
                onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, context),
              ),
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => _discardChanges(context),
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: () => _applyChanges(context),
          child: Text(s.save),
        )
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex, BuildContext context) =>
      context.read<CalculatorAscMaterialsOrderBloc>().add(CalculatorAscMaterialsOrderEvent.positionChanged(oldIndex: oldIndex, newIndex: newIndex));

  void _discardChanges(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _applyChanges(BuildContext context) {
    context.read<CalculatorAscMaterialsOrderBloc>().add(const CalculatorAscMaterialsOrderEvent.applyChanges());
    Navigator.of(context).pop();
  }
}
