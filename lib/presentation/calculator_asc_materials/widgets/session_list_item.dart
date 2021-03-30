import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/domain/models/models.dart';
import 'package:genshindb/generated/l10n.dart';
import 'package:genshindb/presentation/calculator_asc_materials/calculator_ascension_materials_page.dart';

import 'add_edit_session_dialog.dart';

class SessionListItem extends StatelessWidget {
  final CalculatorSessionModel session;

  const SessionListItem({
    Key key,
    @required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
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
        onTap: () => _gotoCalculatorAscensionMaterialsPage(context),
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
  }

  Future<void> _showEditSessionDialog(int sessionKey, String name, BuildContext context) async {
    await showDialog(context: context, builder: (_) => AddEditSessionDialog.update(sessionKey: sessionKey, name: name));
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

  Future<void> _gotoCalculatorAscensionMaterialsPage(BuildContext context) async {
    context.read<CalculatorAscMaterialsBloc>().add(CalculatorAscMaterialsEvent.init(sessionKey: session.key));
    final route = MaterialPageRoute(builder: (c) => CalculatorAscensionMaterialsPage(sessionKey: session.key));
    await Navigator.push(context, route);
    await route.completed;
    context.read<CalculatorAscMaterialsBloc>().add(const CalculatorAscMaterialsEvent.close());
    context.read<CalculatorAscMaterialsOrderBloc>().add(const CalculatorAscMaterialsOrderEvent.discardChanges());
  }
}
