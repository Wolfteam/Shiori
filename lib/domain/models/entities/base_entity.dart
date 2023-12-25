import 'package:hive/hive.dart';

abstract class BaseEntity extends HiveObject {
  int get id => key as int;
}
