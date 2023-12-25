import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';

class ItemQuantityDialog extends StatelessWidget {
  final int quantity;
  final int quantityLength;
  final String? title;
  final void Function(int)? onSave;
  final VoidCallback? onClose;

  const ItemQuantityDialog({
    super.key,
    required this.quantity,
    this.quantityLength = 10,
    this.title,
    this.onSave,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => Injection.itemQuantityFormBloc,
      child: _Body(
        quantity: quantity,
        quantityLength: quantityLength,
        title: title,
        onSave: onSave,
        onClose: onClose,
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final int quantity;
  final int quantityLength;
  final String? title;
  final void Function(int)? onSave;
  final VoidCallback? onClose;

  const _Body({
    required this.quantity,
    required this.quantityLength,
    this.title,
    this.onSave,
    this.onClose,
  });

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
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
      title: Text(widget.title ?? s.quantity),
      content: BlocBuilder<ItemQuantityFormBloc, ItemQuantityFormState>(
        builder: (ctx, state) => TextField(
          maxLength: widget.quantityLength,
          controller: _textEditingController,
          autofocus: true,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
    final quantity = int.tryParse(_currentValue) ?? -1;
    context.read<ItemQuantityFormBloc>().add(ItemQuantityFormEvent.quantityChanged(quantity: quantity));
  }

  void _onSave() {
    if (widget.onSave != null) {
      widget.onSave!(int.parse(_currentValue));
      return;
    }
    Navigator.pop(context, int.parse(_currentValue));
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
      return;
    }
    Navigator.pop(context);
  }
}
