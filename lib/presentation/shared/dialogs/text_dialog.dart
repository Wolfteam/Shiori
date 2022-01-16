import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';

class TextDialog extends StatefulWidget {
  final String title;
  final String? value;
  final int maxLength;
  final Function(String) onSave;
  final bool isInEditMode;

  const TextDialog.create({
    Key? key,
    required this.title,
    required this.onSave,
    required this.maxLength,
  })  : value = '',
        isInEditMode = false,
        super(key: key);

  const TextDialog.update({
    Key? key,
    required this.title,
    required this.value,
    required this.maxLength,
    required this.onSave,
  })  : isInEditMode = true,
        super(key: key);

  @override
  State<TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<TextDialog> {
  late TextEditingController _textEditingController;
  String? _currentValue;
  bool _isValid = false;
  bool _isDirty = false;

  @override
  void initState() {
    _currentValue = widget.value;
    _textEditingController = TextEditingController(text: _currentValue);
    _textEditingController.addListener(_textChanged);

    if (widget.isInEditMode) {
      _isValid = true;
      _isDirty = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final mq = MediaQuery.of(context);
    return AlertDialog(
      title: Text(widget.isInEditMode ? s.edit : s.add),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        child: TextField(
          maxLength: widget.maxLength,
          controller: _textEditingController,
          autofocus: true,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          decoration: InputDecoration(
            hintText: widget.title,
            alignLabelWithHint: true,
            labelText: widget.title,
            errorText: !_isValid && _isDirty ? s.invalidValue : null,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _close,
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        ElevatedButton(
          onPressed: _isValid ? _save : null,
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
    final newValue = _textEditingController.text;
    final isValid = newValue.isNotNullEmptyOrWhitespace && newValue.length <= widget.maxLength;
    final isDirty = newValue != _currentValue;
    _currentValue = newValue;
    setState(() {
      _isValid = isValid;
      _isDirty = isDirty;
    });
  }

  void _save() {
    widget.onSave(_currentValue!);
    _close();
  }

  void _close() => Navigator.pop(context);
}
