import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/presentation/shared/dialogs/item_quantity_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';

class ChangeMaterialQuantityDialog extends StatelessWidget {
  final int? sessionKey;

  const ChangeMaterialQuantityDialog({
    Key? key,
    this.sessionKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CalculatorAscMaterialsItemUpdateQuantityBloc, CalculatorAscMaterialsItemUpdateQuantityState>(
      listener: (ctx, state) {
        state.maybeMap(
          saved: (_) {
            if (sessionKey != null) {
              context.read<CalculatorAscMaterialsBloc>().add(CalculatorAscMaterialsEvent.init(sessionKey: sessionKey!));
            }
            context.read<CalculatorAscMaterialsItemUpdateQuantityBloc>().add(const CalculatorAscMaterialsItemUpdateQuantityEvent.close());
            Navigator.of(context).pop();
          },
          orElse: () => {},
        );
      },
      builder: (ctx, state) => state.map(
        loading: (_) => AlertDialog(
          content: Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: const Loading(useScaffold: false),
          ),
        ),
        loaded: (state) => ItemQuantityDialog(
          quantity: state.quantity,
          onSave: (qty) => _onSave(state.key, qty, context),
        ),
        saved: (state) => ItemQuantityDialog(
          quantity: state.quantity,
          onSave: (qty) => _onSave(state.key, qty, context),
        ),
      ),
    );
  }

  void _onSave(String key, int newQuantity, BuildContext context) {
    context
        .read<CalculatorAscMaterialsItemUpdateQuantityBloc>()
        .add(CalculatorAscMaterialsItemUpdateQuantityEvent.update(key: key, quantity: newQuantity));
  }
}
