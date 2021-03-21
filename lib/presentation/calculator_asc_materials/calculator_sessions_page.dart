import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/app_fab.dart';
import 'package:genshindb/presentation/shared/extensions/scroll_controller_extensions.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';
import 'package:genshindb/presentation/shared/styles.dart';

import 'calculator_ascension_materials_page.dart';
import 'widgets/add_edit_session_dialog.dart';

class CalculatorSessionsPage extends StatefulWidget {
  @override
  _CalculatorSessionsPageState createState() => _CalculatorSessionsPageState();
}

class _CalculatorSessionsPageState extends State<CalculatorSessionsPage> with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  AnimationController _hideFabAnimController;

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
    return Scaffold(
      appBar: AppBar(title: Text(s.sessions)),
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
          child: BlocBuilder<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
            builder: (ctx, state) => state.map(
              loading: (_) => const Loading(useScaffold: false),
              loaded: (state) {
                if (state.sessions.isEmpty) {
                  return NothingFoundColumn(msg: s.noSessionsHaveBeenCreated);
                }

                return ListView.separated(
                  controller: _scrollController,
                  itemCount: state.sessions.length,
                  separatorBuilder: (ctx, index) => const Divider(),
                  itemBuilder: (ctx, index) {
                    final session = state.sessions[index];
                    final numberOfChars = session.items.where((e) => e.isCharacter).length;
                    final numberOfWeapons = session.items.where((e) => !e.isCharacter).length;
                    return Slidable(
                      actionPane: const SlidableDrawerActionPane(),
                      actions: [
                        IconSlideAction(
                          caption: s.delete,
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () => _showDeleteSessionDialog(session.key, session.name, context),
                        ),
                      ],
                      secondaryActions: [
                        IconSlideAction(
                          caption: s.edit,
                          color: Colors.lightBlueAccent,
                          icon: Icons.edit,
                          onTap: () => _showEditSessionDialog(session.key, session.name, context),
                        ),
                      ],
                      child: ListTile(
                        onLongPress: () => _showEditSessionDialog(session.key, session.name, context),
                        title: Text(session.name),
                        onTap: () => _gotoCalculatorAscensionMaterialsPage(session, context),
                        subtitle: Text('${s.charactersX(numberOfChars)} / ${s.weaponsX(numberOfWeapons)}'),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.list),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
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

  Future<void> _gotoCalculatorAscensionMaterialsPage(CalculatorSessionModel session, BuildContext context) async {
    context.read<CalculatorAscMaterialsBloc>().add(CalculatorAscMaterialsEvent.init(items: session.items));
    final route = MaterialPageRoute(builder: (c) => CalculatorAscensionMaterialsPage(sessionKey: session.key));
    await Navigator.push(context, route);
  }

  Future<void> _showAddSessionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const AddEditSessionDialog.create(),
    );
    context.read<CalculatorAscMaterialsSessionFormBloc>().add(const CalculatorAscMaterialsSessionFormEvent.close());
  }

  Future<void> _showEditSessionDialog(int sessionKey, String name, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AddEditSessionDialog.update(sessionKey: sessionKey, name: name),
    );
    context.read<CalculatorAscMaterialsSessionFormBloc>().add(const CalculatorAscMaterialsSessionFormEvent.close());
  }

  Future<void> _showDeleteSessionDialog(int sessionKey, String name, BuildContext context) async {
    final s = S.of(context);
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.deleteSession),
        content: Text(s.confirmDeleteSessionX(name)),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CalculatorAscMaterialsSessionsBloc>().add(CalculatorAscMaterialsSessionsEvent.deleteSession(key: sessionKey));
              Navigator.pop(context);
            },
            child: Text(s.ok),
          )
        ],
      ),
    );
  }
}
