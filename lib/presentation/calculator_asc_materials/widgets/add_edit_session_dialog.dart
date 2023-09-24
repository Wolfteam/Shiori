import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';

class AddEditSessionDialog extends StatelessWidget {
  final int? sessionKey;
  final String? name;

  const AddEditSessionDialog.create({
    super.key,
  })  : sessionKey = null,
        name = '';

  const AddEditSessionDialog.update({
    super.key,
    required this.sessionKey,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CalculatorAscMaterialsSessionFormBloc>(
      create: (ctx) => Injection.calculatorAscMaterialsSessionFormBloc,
      child: _Body(sessionKey: sessionKey, name: name),
    );
  }
}

class _Body extends StatefulWidget {
  final int? sessionKey;
  final String? name;

  const _Body({this.sessionKey, this.name});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late TextEditingController _textEditingController;
  String? _currentValue;

  @override
  void initState() {
    _currentValue = widget.name;
    _textEditingController = TextEditingController(text: _currentValue);
    _textEditingController.addListener(_textChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(widget.sessionKey != null ? s.editSession : s.addSession),
      content: BlocBuilder<CalculatorAscMaterialsSessionFormBloc, CalculatorAscMaterialsSessionFormState>(
        builder: (ctx, state) => TextField(
          maxLength: CalculatorAscMaterialsSessionFormBloc.nameMaxLength,
          controller: _textEditingController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: s.name,
            alignLabelWithHint: true,
            labelText: s.name,
            errorText: !state.isNameValid && state.isNameDirty ? s.invalidValue : null,
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
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textEditingController.removeListener(_textChanged);
    _textEditingController.dispose();
    super.dispose();
  }

  void _textChanged() {
    //Focusing the text field triggers text changed, that why we used it like this
    if (_currentValue == _textEditingController.text) {
      return;
    }
    _currentValue = _textEditingController.text;
    context.read<CalculatorAscMaterialsSessionFormBloc>().add(CalculatorAscMaterialsSessionFormEvent.nameChanged(name: _currentValue!));
  }

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
      .add(CalculatorAscMaterialsSessionsEvent.updateSession(key: widget.sessionKey!, name: _textEditingController.text));

  void _close() => Navigator.pop(context);
}
