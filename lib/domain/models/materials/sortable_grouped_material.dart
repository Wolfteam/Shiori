import 'package:shiori/domain/enums/enums.dart';

abstract class SortableGroupedMaterial {
  MaterialType get type;

  int get rarity;

  int get position;

  double get level;

  bool get hasSiblings;
}
