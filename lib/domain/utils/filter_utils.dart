class FilterUtils {
  static List<T> handleTypeSelected<T extends Enum>(List<T> allValues, List<T> tempValues, T selectedValue) {
    if (tempValues.length == allValues.length) {
      return [selectedValue];
    }
    if (tempValues.length == 1 && tempValues.first == selectedValue) {
      return allValues.toList();
    }
    if (tempValues.contains(selectedValue)) {
      return tempValues.where((t) => t != selectedValue).toList();
    }
    return tempValues + [selectedValue];
  }
}