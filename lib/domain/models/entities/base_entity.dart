import 'package:hive_ce/hive.dart';

abstract class BaseEntity extends HiveObject {
  int get id => key as int;
}
