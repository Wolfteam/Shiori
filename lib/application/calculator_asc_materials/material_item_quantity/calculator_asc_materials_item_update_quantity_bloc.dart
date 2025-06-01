import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/item_type.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_item_update_quantity_bloc.freezed.dart';
part 'calculator_asc_materials_item_update_quantity_event.dart';
part 'calculator_asc_materials_item_update_quantity_state.dart';

class CalculatorAscMaterialsItemUpdateQuantityBloc
    extends Bloc<CalculatorAscMaterialsItemUpdateQuantityEvent, CalculatorAscMaterialsItemUpdateQuantityState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;

  CalculatorAscMaterialsItemUpdateQuantityBloc(this._dataService, this._telemetryService)
    : super(const CalculatorAscMaterialsItemUpdateQuantityState.loading());

  @override
  Stream<CalculatorAscMaterialsItemUpdateQuantityState> mapEventToState(
    CalculatorAscMaterialsItemUpdateQuantityEvent event,
  ) async* {
    switch (event) {
      case CalculatorAscMaterialsItemUpdateQuantityEventLoad():
        final int quantity = _dataService.inventory.getItemQuantityFromInventory(event.key, ItemType.material);
        yield CalculatorAscMaterialsItemUpdateQuantityState.loaded(key: event.key, quantity: quantity);
      case CalculatorAscMaterialsItemUpdateQuantityEventUpdate():
        await _updateMaterialQuantity(event.key, event.quantity);
        yield CalculatorAscMaterialsItemUpdateQuantityState.saved(key: event.key, quantity: event.quantity);
    }
  }

  Future<void> _updateMaterialQuantity(String key, int quantity) async {
    await _telemetryService.trackItemUpdatedInInventory(key, quantity);
    await _dataService.inventory.addMaterialToInventory(
      key,
      quantity,
      redistribute: _dataService.calculator.redistributeInventoryMaterial,
    );
  }
}
