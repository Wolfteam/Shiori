import 'package:shiori/domain/models/sorting/sortable_item.dart';

class SortResult {
  final bool somethingChanged;
  final List<SortableItem> items;

  SortResult(this.somethingChanged, this.items);
}
