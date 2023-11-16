import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shiori/application/bloc.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/services/data_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

import '../../../mocks.mocks.dart';

void main() {
  final TelemetryService telemetryService = MockTelemetryService();

  test(
    'Initial state',
    () => expect(
      CalculatorAscMaterialsItemUpdateQuantityBloc(MockDataService(), telemetryService).state,
      const CalculatorAscMaterialsItemUpdateQuantityState.loading(),
    ),
  );

  blocTest<CalculatorAscMaterialsItemUpdateQuantityBloc, CalculatorAscMaterialsItemUpdateQuantityState>(
    'Get material count',
    build: () {
      final inventoryMock = MockInventoryDataService();
      when(inventoryMock.getItemQuantityFromInventory('mora', ItemType.material)).thenReturn(10);
      final DataService dataService = MockDataService();
      when(dataService.inventory).thenReturn(inventoryMock);
      return CalculatorAscMaterialsItemUpdateQuantityBloc(dataService, telemetryService);
    },
    act: (bloc) => bloc.add(const CalculatorAscMaterialsItemUpdateQuantityEvent.load(key: 'mora')),
    expect: () => const [
      CalculatorAscMaterialsItemUpdateQuantityState.loaded(key: 'mora', quantity: 10),
    ],
  );

  blocTest<CalculatorAscMaterialsItemUpdateQuantityBloc, CalculatorAscMaterialsItemUpdateQuantityState>(
    'Update material count',
    build: () {
      final dataServiceMock = MockDataService();
      final calcMock = MockCalculatorAscMaterialsDataService();
      final inventoryMock = MockInventoryDataService();
      when(dataServiceMock.inventory).thenReturn(inventoryMock);
      when(dataServiceMock.calculator).thenReturn(calcMock);
      return CalculatorAscMaterialsItemUpdateQuantityBloc(dataServiceMock, telemetryService);
    },
    act: (bloc) => bloc.add(const CalculatorAscMaterialsItemUpdateQuantityEvent.update(key: 'mora', quantity: 666)),
    expect: () => const [
      CalculatorAscMaterialsItemUpdateQuantityState.saved(key: 'mora', quantity: 666),
    ],
  );
}
