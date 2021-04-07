extension IterableExtensions<E> on Iterable<E> {
  /// Like Iterable<T>.map but callback have index as second argument
  Iterable<T> mapIndex<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  void forEachIndex(void Function(E e, int i) f) {
    var i = 0;
    forEach((e) => f(e, i++));
  }
}

extension ListExtensions<E> on List<E> {
  /// Moves the item in the [oldIndex] to the [newIndex]
  List<E> moveTo(int oldIndex, int newIndex) {
    final updatedItems = <E>[];
    final item = elementAt(oldIndex);
    for (int i = 0; i < length; i++) {
      if (i == oldIndex) {
        continue;
      }

      final item = this[i];
      updatedItems.add(item);
    }

    final indexToUse = newIndex >= length ? length - 1 : newIndex;
    updatedItems.insert(indexToUse, item);

    return updatedItems;
  }
}
