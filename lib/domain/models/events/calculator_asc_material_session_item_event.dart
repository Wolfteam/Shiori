class CalculatorAscMaterialSessionItemEvent {
  final int sessionKey;
  final int itemKey;
  final bool added;
  final bool isCharacter;

  CalculatorAscMaterialSessionItemEvent(this.sessionKey, this.itemKey, this.added, this.isCharacter);

  CalculatorAscMaterialSessionItemEvent.created(this.sessionKey, this.itemKey, this.isCharacter) : added = true;

  CalculatorAscMaterialSessionItemEvent.deleted(this.sessionKey, this.itemKey, this.isCharacter) : added = false;
}
