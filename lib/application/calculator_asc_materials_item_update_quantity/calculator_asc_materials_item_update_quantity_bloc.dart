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
  Stream<CalculatorAscMaterialsItemUpdateQuantityState> mapEventToState(CalculatorAscMaterialsItemUpdateQuantityEvent event) async* {
    final s = await event.map(
      load: (e) async {
        final material = _dataService.getMaterialFromInventoryByImage(e.image);
        return CalculatorAscMaterialsItemUpdateQuantityState.loaded(key: material.key, quantity: material.quantity);
      },
      update: (e) async {
        await _updateMaterialQuantity(e.key, e.quantity);
        return CalculatorAscMaterialsItemUpdateQuantityState.saved(key: e.key, quantity: e.quantity);
      },
      close: (_) async => const CalculatorAscMaterialsItemUpdateQuantityState.loading(),
    );

    yield s;
  }

  Future<void> _updateMaterialQuantity(String key, int quantity) async {
    await _telemetryService.trackItemUpdatedInInventory(key, quantity);
    await _dataService.updateItemInInventory(key, ItemType.material, quantity);
  }
}
