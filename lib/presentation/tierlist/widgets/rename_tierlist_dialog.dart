import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';

class RenameTierListRowDialog extends StatefulWidget {
  final int index;
  final String title;

  const RenameTierListRowDialog({
    Key key,
    @required this.index,
    @required this.title,
  }) : super(key: key);

  @override
  _RenameTierListRowDialogState createState() => _RenameTierListRowDialogState();
}

class _RenameTierListRowDialogState extends State<RenameTierListRowDialog> {
  TextEditingController _textController;

  @override
  void initState() {
    final text = widget.title ?? '';
    _textController = TextEditingController(text: text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.rename),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(s.cancel),
        ),
        FlatButton(
          onPressed: () {
            context.read<TierListBloc>().add(TierListEvent.rowTextChanged(index: widget.index, newValue: _textController.text));
            Navigator.pop(context);
          },
          child: Text(s.ok),
        )
      ],
      content: TextFormField(
        controller: _textController,
        keyboardType: TextInputType.text,
        minLines: 1,
        maxLength: 40,
        autofocus: true,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: s.name,
          hintText: s.tierListBuilder,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
