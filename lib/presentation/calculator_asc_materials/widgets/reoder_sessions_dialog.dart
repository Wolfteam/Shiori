import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';
import 'package:shiori/presentation/shared/utils/toast_utils.dart';

class ReorderSessionsDialog extends StatelessWidget {
  final List<CalculatorSessionModel> sessions;

  const ReorderSessionsDialog({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalculatorAscMaterialsSessionsOrderBloc>(
      create: (ctx) => Injection.getCalculatorAscMaterialsSessionsOrderBloc(context.read<CalculatorAscMaterialsSessionsBloc>())
        ..add(CalculatorAscMaterialsSessionsOrderEvent.init(sessions: sessions)),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final fToast = ToastUtils.of(context);
    final mq = MediaQuery.of(context);
    return AlertDialog(
      title: Text(s.priority),
      content: BlocBuilder<CalculatorAscMaterialsSessionsOrderBloc, CalculatorAscMaterialsSessionsOrderState>(
        builder: (ctx, state) => SizedBox(
          height: mq.getHeightForDialogs(state.sessions.length),
          width: mq.getWidthForDialogs(),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: state.sessions.length,
            itemBuilder: (ctx, index) {
              final session = state.sessions[index];
              final position = index + 1;
              return ListTile(
                key: Key('$index'),
                title: Text('#$position - ${session.name}', overflow: TextOverflow.ellipsis),
                onTap: () => ToastUtils.showInfoToast(fToast, s.holdToReorder),
              );
            },
            onReorder: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex, ctx),
          ),
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

  void _onReorder(int oldIndex, int newIndex, BuildContext context) => context
      .read<CalculatorAscMaterialsSessionsOrderBloc>()
      .add(CalculatorAscMaterialsSessionsOrderEvent.positionChanged(oldIndex: oldIndex, newIndex: newIndex));

  void _discardChanges(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _applyChanges(BuildContext context) {
    context.read<CalculatorAscMaterialsSessionsOrderBloc>().add(const CalculatorAscMaterialsSessionsOrderEvent.applyChanges());
    Navigator.of(context).pop();
  }
}
