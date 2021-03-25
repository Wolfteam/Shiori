import 'package:flutter/foundation.dart';
import 'package:genshindb/domain/models/models.dart';

class CalculatorSessionModel {
  final int key;
  final String name;
  final int position;
  final List<ItemAscensionMaterials> items;

  CalculatorSessionModel({
    @required this.key,
    @required this.name,
    @required this.position,
    @required this.items,
  });
}
