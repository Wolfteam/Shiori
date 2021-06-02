import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:genshindb/presentation/shared/info_dialog.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'widgets/add_edit_session_dialog.dart';
import 'widgets/reoder_sessions_dialog.dart';
import 'widgets/session_list_item.dart';

class CalculatorSessionsPage extends StatefulWidget {
  @override
  _CalculatorSessionsPageState createState() => _CalculatorSessionsPageState();
}

class _CalculatorSessionsPageState extends State<CalculatorSessionsPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;
  int _numberOfItems = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _hideFabAnimController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      value: 1, // initially visible
    );
    _scrollController.addListener(() => _scrollController.handleScrollForFab(_hideFabAnimController, hideOnTop: false));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocConsumer<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
      listener: (ctx, state) {
        state.maybeMap(
          loaded: (state) {
            if (_numberOfItems != state.sessions.length) {
              _hideFabAnimController.forward();
            }
            _numberOfItems = state.sessions.length;
          },
          orElse: () {},
        );
      },
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
                  onPressed: () => _showReorderDialog(state.sessions, context),
                ),
              IconButton(
                tooltip: s.information,
                icon: const Icon(Icons.info),
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
        ),
        floatingActionButton: AppFab(
          onPressed: () => _showAddSessionDialog(context),
          icon: const Icon(Icons.add),
          hideFabAnimController: _hideFabAnimController,
          scrollController: _scrollController,
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
                  controller: _scrollController,
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

  @override
  void dispose() {
    _scrollController.dispose();
    _hideFabAnimController.dispose();
    super.dispose();
  }

  Future<void> _showAddSessionDialog(BuildContext context) async {
    await showDialog(context: context, builder: (_) => const AddEditSessionDialog.create());
    context.read<CalculatorAscMaterialsSessionFormBloc>().add(const CalculatorAscMaterialsSessionFormEvent.close());
  }

  Future<void> _showReorderDialog(List<CalculatorSessionModel> sessions, BuildContext context) async {
    context.read<CalculatorAscMaterialsSessionsOrderBloc>().add(CalculatorAscMaterialsSessionsOrderEvent.init(sessions: sessions));
    await showDialog(context: context, builder: (_) => ReorderSessionsDialog());
  }

  Future<void> _showInfoDialog(BuildContext context) async {
    final s = S.of(context);
    final explanations = [
      s.calcSessionInfoMsgA,
      s.calcSessionInfoMsgB,
      s.calcSessionInfoMsgC,
      s.calcSessionInfoMsgD(s.useMaterialsFromInventory),
      s.calcSessionInfoMsgE(s.myInventory)
    ];
    await showDialog(
      context: context,
      builder: (context) => InfoDialog(explanations: explanations),
    );
  }
}
