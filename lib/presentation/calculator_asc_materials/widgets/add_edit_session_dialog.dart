import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';

class AddEditSessionDialog extends StatefulWidget {
  final int sessionKey;
  final String name;

  const AddEditSessionDialog.create({
    Key key,
  })  : sessionKey = null,
        name = '',
        super(key: key);

  const AddEditSessionDialog.update({
    Key key,
    @required this.sessionKey,
    @required this.name,
  }) : super(key: key);

  @override
  _AddEditSessionDialogState createState() => _AddEditSessionDialogState();
}

class _AddEditSessionDialogState extends State<AddEditSessionDialog> {
  TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.name);
    _textEditingController.addListener(_textChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return AlertDialog(
      title: Text(widget.sessionKey != null ? "Edit session" : "Add session"),
      content: BlocBuilder<CalculatorAscMaterialsSessionFormBloc, CalculatorAscMaterialsSessionFormState>(
        builder: (ctx, state) => TextField(
          maxLength: CalculatorAscMaterialsSessionFormBloc.nameMaxLength,
          controller: _textEditingController,
          decoration: InputDecoration(
            hintText: s.name,
            alignLabelWithHint: true,
            labelText: s.name,
            errorText: !state.isNameValid && state.isNameDirty ? 'Invalid name' : null,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _close,
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        BlocBuilder<CalculatorAscMaterialsSessionFormBloc, CalculatorAscMaterialsSessionFormState>(
          builder: (ctx, state) => ElevatedButton(
            onPressed: state.isNameValid ? _saveSession : null,
            child: Text(s.save),
          ),
        )
      ],
    );
  }

  void _textChanged() => context
      .read<CalculatorAscMaterialsSessionFormBloc>()
      .add(CalculatorAscMaterialsSessionFormEvent.nameChanged(name: _textEditingController.text));

  void _saveSession() {
    if (widget.sessionKey != null) {
      _updateSession();
    } else {
      _createSession();
    }

    _close();
  }

  void _createSession() =>
      context.read<CalculatorAscMaterialsSessionsBloc>().add(CalculatorAscMaterialsSessionsEvent.createSession(name: _textEditingController.text));

  void _updateSession() => context
      .read<CalculatorAscMaterialsSessionsBloc>()
      .add(CalculatorAscMaterialsSessionsEvent.updateSession(key: widget.sessionKey, name: _textEditingController.text));

  void _close() => Navigator.pop(context);
}
