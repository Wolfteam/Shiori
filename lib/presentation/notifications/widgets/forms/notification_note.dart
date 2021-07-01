import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';

class NotificationNote extends StatefulWidget {
  final String? note;

  const NotificationNote({Key? key, required this.note}) : super(key: key);

  @override
  _NotificationNoteState createState() => _NotificationNoteState();
}

class _NotificationNoteState extends State<NotificationNote> {
  late TextEditingController _textController;
  String? _currentValue;

  @override
  void initState() {
    _currentValue = widget.note;
    _textController = TextEditingController(text: _currentValue);
    _textController.addListener(_textChanged);
    super.initState();
  }

  @override
  void dispose() {
    _textController.removeListener(_textChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return TextField(
      maxLength: NotificationBloc.maxNoteLength,
      controller: _textController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: s.note,
        alignLabelWithHint: true,
        labelText: s.note,
      ),
    );
  }

  void _textChanged() {
    //Focusing the text field triggers text changed, that why we used it like this
    if (_currentValue == _textController.text) {
      return;
    }
    _currentValue = _textController.text;
    context.read<NotificationBloc>().add(NotificationEvent.noteChanged(newValue: _textController.text));
  }
}
