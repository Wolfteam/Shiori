import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/add_edit_session_dialog.dart';
import 'package:shiori/presentation/calculator_asc_materials/widgets/session_list_item.dart';
import 'package:shiori/presentation/shared/app_fab.dart';
import 'package:shiori/presentation/shared/dialogs/confirm_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/info_dialog.dart';
import 'package:shiori/presentation/shared/dialogs/sort_items_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';
import 'package:shiori/presentation/shared/mixins/app_fab_mixin.dart';
import 'package:shiori/presentation/shared/nothing_found_column.dart';
import 'package:shiori/presentation/shared/styles.dart';

class CalculatorSessionsPage extends StatelessWidget {
  const CalculatorSessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalculatorAscMaterialsSessionsBloc>(
      create: (ctx) => Injection.calculatorAscMaterialsSessionsBloc..add(const CalculatorAscMaterialsSessionsEvent.init()),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin, AppFabMixin {
  @override
  bool get isInitiallyVisible => true;

  @override
  bool get hideOnTop => false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocBuilder<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      builder: (ctx, state) => Scaffold(
        appBar: state.map(
          loading: (_) => null,
          loaded: (state) => AppBar(
            title: Text(s.sessions),
            actions: [
              if (state.sessions.length > 1)
                IconButton(
                  tooltip: s.priority,
                  icon: const Icon(Icons.unfold_more),
                  onPressed: () => _showReorderDialog(state.sessions),
                ),
              if (state.sessions.isNotEmpty)
                IconButton(
                  tooltip: s.delete,
                  icon: const Icon(Icons.clear_all),
                  onPressed: () => _showDeleteAllSessionsDialog(),
                ),
              IconButton(
                tooltip: s.information,
                icon: const Icon(Icons.info),
                onPressed: () => _showInfoDialog(),
              ),
            ],
          ),
        ),
        floatingActionButton: AppFab(
          onPressed: () => _showAddSessionDialog(),
          icon: const Icon(Icons.add),
          hideFabAnimController: hideFabAnimController,
          scrollController: scrollController,
          mini: false,
        ),
        body: SafeArea(
          child: Container(
            padding: Styles.edgeInsetVertical5,
            child: state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) {
                if (state.sessions.isEmpty) {
                  return NothingFoundColumn(msg: s.noSessionsHaveBeenCreated);
                }
                return ListView.separated(
                  controller: scrollController,
                  itemCount: state.sessions.length,
                  separatorBuilder: (ctx, index) => const Divider(height: 1),
                  itemBuilder: (ctx, index) => SessionListItem(session: state.sessions[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddSessionDialog() async {
    await showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CalculatorAscMaterialsSessionsBloc>(),
        child: const AddEditSessionDialog.create(),
      ),
    );
  }

  Future<void> _showReorderDialog(List<CalculatorSessionModel> sessions) {
    return showDialog<SortResult<SortableItemOfT<CalculatorSessionModel>>>(
      context: context,
      builder: (_) => SortItemsDialog<SortableItemOfT<CalculatorSessionModel>>(
        items: sessions.map((e) => SortableItemOfT('${e.key}', e.name, e)).toList(),
      ),
    ).then((result) {
      if (result == null || !result.somethingChanged || !context.mounted) {
        return;
      }

      final sorted = result.items.map((e) => e.item).toList();
      context.read<CalculatorAscMaterialsSessionsBloc>().add(CalculatorAscMaterialsSessionsEvent.itemsReordered(sorted));
    });
  }

  Future<void> _showInfoDialog() async {
    final s = S.of(context);
    final explanations = [
      s.calcSessionInfoMsgA,
      s.calcSessionInfoMsgB,
      s.calcSessionInfoMsgC,
      s.calcSessionInfoMsgD(s.useMaterialsFromInventory),
      s.calcSessionInfoMsgE(s.myInventory),
    ];
    await showDialog(
      context: context,
      builder: (context) => InfoDialog(explanations: explanations),
    );
  }

  Future<void> _showDeleteAllSessionsDialog() async {
    final s = S.of(context);
    await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: s.deleteAllSessions,
        content: s.confirmQuestion,
        onOk: () =>
            context.read<CalculatorAscMaterialsSessionsBloc>().add(const CalculatorAscMaterialsSessionsEvent.deleteAllSessions()),
      ),
    );
  }
}
