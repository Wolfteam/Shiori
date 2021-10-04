class ItemCommon {
  final String key;
  final String image;

  const ItemCommon(this.key, this.image);
}

class ItemCommonWithQuantity extends ItemCommon {
  final int quantity;

  ItemCommonWithQuantity(String key, String image, this.quantity) : super(key, image);
}

class ItemObtainedFrom {
  final String key;
  final List<ItemCommonWithQuantity> items;

  ItemObtainedFrom(this.key, this.items);
}
