import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/generated/l10n.dart';

const int _nameMaxLength = 25;

class AddEditSessionDialog extends StatelessWidget {
  final int? sessionKey;
  final String? name;
  final bool showMaterialUsage;

  const AddEditSessionDialog.create({
    super.key,
  })  : sessionKey = null,
        name = '',
        showMaterialUsage = true;

  const AddEditSessionDialog.update({
    super.key,
    required this.sessionKey,
    required this.name,
    required this.showMaterialUsage,
  });

  @override
  Widget build(BuildContext context) {
    return _Body(sessionKey: sessionKey, name: name, showMaterialUsage: showMaterialUsage);
  }
}

class _Body extends StatefulWidget {
  final int? sessionKey;
  final String? name;
  final bool showMaterialUsage;

  const _Body({this.sessionKey, this.name, this.showMaterialUsage = false});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late TextEditingController _textEditingController;
  String? _name;
  bool _showMaterialUsage = false;
  bool _isValid = false;
  bool _isDirty = false;

  @override
  void initState() {
    _name = widget.name;
    _showMaterialUsage = widget.showMaterialUsage;
    if (widget.name.isNotNullEmptyOrWhitespace) {
      _isValid = true;
    }
    _textEditingController = TextEditingController(text: _name);
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
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            maxLength: _nameMaxLength,
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: s.name,
              alignLabelWithHint: true,
              labelText: s.name,
              errorText: !_isValid && _isDirty ? s.invalidValue : null,
            ),
          ),
          CheckboxListTile(
            title: Text(s.showMaterialUsage),
            value: _showMaterialUsage,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) => setState(() {
              _showMaterialUsage = value ?? false;
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _close,
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        FilledButton(
          onPressed: _isValid ? _saveSession : null,
          child: Text(s.save),
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
    if (_name == _textEditingController.text) {
      return;
    }

    final actualValue = _name;
    final newValue = _textEditingController.text;

    final isValid = newValue.isNotNullEmptyOrWhitespace && newValue.length <= _nameMaxLength;
    final isDirty = newValue != actualValue;

    setState(() {
      _name = newValue;
      _isValid = isValid;
      _isDirty = isDirty;
    });
  }

  void _saveSession() {
    if (widget.sessionKey != null) {
      _updateSession();
    } else {
      _createSession();
    }

    _close();
  }

  void _createSession() => context
      .read<CalculatorAscMaterialsSessionsBloc>()
      .add(CalculatorAscMaterialsSessionsEvent.createSession(name: _textEditingController.text, showMaterialUsage: _showMaterialUsage));

  void _updateSession() => context.read<CalculatorAscMaterialsSessionsBloc>().add(
        CalculatorAscMaterialsSessionsEvent.updateSession(
          key: widget.sessionKey!,
          name: _textEditingController.text,
          showMaterialUsage: _showMaterialUsage,
        ),
      );

  void _close() => Navigator.pop(context);
}
