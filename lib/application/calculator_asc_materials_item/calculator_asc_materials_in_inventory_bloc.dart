import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/item_type.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'calculator_asc_materials_in_inventory_bloc.freezed.dart';
part 'calculator_asc_materials_in_inventory_event.dart';
part 'calculator_asc_materials_in_inventory_state.dart';

class CalculatorAscMaterialsInInventoryBloc extends Bloc<CalculatorAscMaterialsInInventoryEvent, CalculatorAscMaterialsInInventoryState> {
  final DataService _dataService;
  final TelemetryService _telemetryService;

  CalculatorAscMaterialsInInventoryBloc(this._dataService, this._telemetryService) : super(const CalculatorAscMaterialsInInventoryState.loading());

  @override
  Stream<CalculatorAscMaterialsInInventoryState> mapEventToState(CalculatorAscMaterialsInInventoryEvent event) async* {
    final s = await event.map(
      load: (e) async {
        final material = _dataService.getMaterialFromInventoryByImage(e.image);
        return CalculatorAscMaterialsInInventoryState.loaded(key: material.key, quantity: material.quantity);
      },
      update: (e) async {
        await _updateMaterialQuantity(e.key, e.quantity);
        return CalculatorAscMaterialsInInventoryState.saved(key: e.key, quantity: e.quantity);
      },
      close: (_) async => const CalculatorAscMaterialsInInventoryState.loading(),
    );

    yield s;
  }

  Future<void> _updateMaterialQuantity(String key, int quantity) async {
    await _telemetryService.trackItemUpdatedInInventory(key, quantity);
    await _dataService.updateItemInInventory(key, ItemType.material, quantity);
  }
}