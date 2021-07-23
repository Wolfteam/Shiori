import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genshindb/application/bloc.dart';
import 'package:genshindb/generated/l10n.dart';

class ItemQuantityDialog extends StatefulWidget {
  final int quantity;
  final int quantityLength;

  const ItemQuantityDialog({
    Key? key,
    required this.quantity,
    this.quantityLength = 10,
  }) : super(key: key);

  @override
  _ItemQuantityDialogState createState() => _ItemQuantityDialogState();
}

class _ItemQuantityDialogState extends State<ItemQuantityDialog> {
  late TextEditingController _textEditingController;
  late String _currentValue;

  @override
  void initState() {
    _currentValue = '${widget.quantity}';
    _textEditingController = TextEditingController(text: _currentValue);
    _textEditingController.addListener(_textChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.quantity),
      content: BlocBuilder<ItemQuantityFormBloc, ItemQuantityFormState>(
        builder: (ctx, state) => TextField(
          maxLength: widget.quantityLength,
          controller: _textEditingController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            alignLabelWithHint: true,
            labelText: s.quantity,
            errorText: !state.isQuantityValid ? s.invalidValue : null,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _close,
          child: Text(s.cancel, style: TextStyle(color: theme.primaryColor)),
        ),
        BlocBuilder<ItemQuantityFormBloc, ItemQuantityFormState>(
          builder: (ctx, state) => ElevatedButton(
            onPressed: state.isQuantityValid ? _onSave : null,
            child: Text(s.save),
          ),
        )
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
    final quantity = int.tryParse(_currentValue) ?? -1;
    context.read<ItemQuantityFormBloc>().add(ItemQuantityFormEvent.quantityChanged(quantity: quantity));
  }

  void _onSave() => Navigator.pop(context, int.parse(_currentValue));

  void _close() => Navigator.pop(context);
}
