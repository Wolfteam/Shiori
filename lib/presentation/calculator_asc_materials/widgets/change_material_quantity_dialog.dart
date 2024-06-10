import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/generated/l10n.dart';
import 'package:shiori/injection.dart';
import 'package:shiori/presentation/shared/dialogs/item_quantity_dialog.dart';
import 'package:shiori/presentation/shared/loading.dart';

class ChangeMaterialQuantityDialog extends StatelessWidget {
  final String itemKey;

  const ChangeMaterialQuantityDialog({
    super.key,
    required this.itemKey,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (_) => Injection.calculatorAscMaterialsItemUpdateQuantityBloc..add(CalculatorAscMaterialsItemUpdateQuantityEvent.load(key: itemKey)),
      child: BlocConsumer<CalculatorAscMaterialsItemUpdateQuantityBloc, CalculatorAscMaterialsItemUpdateQuantityState>(
        listener: (context, state) {
          state.maybeMap(
            saved: (_) {
              Navigator.of(context).pop(true);
            },
            orElse: () => {},
          );
        },
        builder: (context, state) => state.map(
          loading: (_) => AlertDialog(
            content: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: const Loading(useScaffold: false),
            ),
          ),
          loaded: (state) => ItemQuantityDialog(
            quantity: state.quantity,
            title: s.inInventory,
            onSave: (qty) => _onSave(state.key, qty, context),
          ),
          saved: (state) => ItemQuantityDialog(
            quantity: state.quantity,
            title: s.inInventory,
            onSave: (qty) => _onSave(state.key, qty, context),
          ),
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
