import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/shared/loading.dart';
import 'package:genshindb/presentation/shared/nothing_found_column.dart';

import 'calculator_ascension_materials_page.dart';
import 'widgets/add_edit_session_dialog.dart';

class CalculatorSessionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.sessions)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSessionDialog(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<CalculatorAscMaterialsSessionsBloc, CalculatorAscMaterialsSessionsState>(
          builder: (ctx, state) => state.map(
            loading: (_) => const Loading(useScaffold: false),
            loaded: (state) {
              if (state.sessions.isEmpty) {
                return NothingFoundColumn(msg: s.noSessionsHaveBeenCreated);
              }

              return ListView.separated(
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
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
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
  }

  Future<void> _showEditSessionDialog(int sessionKey, String name, BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AddEditSessionDialog.update(sessionKey: sessionKey, name: name),
    );
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
