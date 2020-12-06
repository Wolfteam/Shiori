import 'package:moor/moor.dart';

class BaseEntity extends Table {
  // autoIncrement automatically sets this to be the primary key
  IntColumn get id => integer().autoIncrement()();
}
