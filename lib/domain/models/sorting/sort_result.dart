import 'package:shiori/domain/models/sorting/sortable_item.dart';

class SortResult<T extends SortableItem> {
  final bool somethingChanged;
  final List<T> items;

  SortResult(this.somethingChanged, this.items);
}
