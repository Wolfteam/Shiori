import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiori/domain/extensions/string_extensions.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/presentation/shared/extensions/media_query_extensions.dart';

class TextDialog extends StatefulWidget {
  final String? title;
  final String hintText;
  final String? value;
  final int maxLength;
  final Function(String) onSave;
  final bool isInEditMode;
  final Widget? child;
  final String? regexPattern;

  const TextDialog.create({
    Key? key,
    this.title,
    required this.hintText,
    required this.onSave,
    required this.maxLength,
    this.regexPattern,
    this.child,
  })  : value = '',
        isInEditMode = false,
        super(key: key);

  const TextDialog.update({
    Key? key,
    this.title,
    required this.hintText,
    required this.value,
    required this.maxLength,
    required this.onSave,
    this.regexPattern,
    this.child,
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
    final title = widget.title.isNotNullEmptyOrWhitespace
        ? widget.title!
        : widget.isInEditMode
            ? s.edit
            : s.add;

    final decoration = InputDecoration(
      hintText: widget.hintText,
      alignLabelWithHint: true,
      labelText: widget.hintText,
      errorText: !_isValid && _isDirty ? s.invalidValue : null,
    );

    return AlertDialog(
      scrollable: true,
      title: Text(title),
      content: SizedBox(
        width: mq.getWidthForDialogs(),
        child: widget.child == null
            ? TextField(
                maxLength: widget.maxLength,
                controller: _textEditingController,
                autofocus: true,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: decoration,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    maxLength: widget.maxLength,
                    controller: _textEditingController,
                    autofocus: true,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    decoration: decoration,
                  ),
                  widget.child!,
                ],
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
    bool isValid = newValue.isNotNullEmptyOrWhitespace && newValue.length <= widget.maxLength;
    if (isValid && widget.regexPattern.isNotNullEmptyOrWhitespace) {
      isValid = RegExp(widget.regexPattern!).hasMatch(newValue);
    }
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
