class SortableItem {
  final String key;
  final String text;

  SortableItem(this.key, this.text);
}

class SortableItemOfT<T> extends SortableItem {
  final T item;

  SortableItemOfT(super.key, super.text, this.item);
}
