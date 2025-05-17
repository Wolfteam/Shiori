import 'package:hive_ce/hive.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/entities.dart';
import 'package:shiori/domain/models/entities/base_entity.dart';

part 'notification_realm_currency.g.dart';

@HiveType(typeId: 15)
class NotificationRealmCurrency extends BaseEntity implements NotificationBase {
  @override
  @HiveField(0)
  final int type;

  @override
  @HiveField(1)
  String itemKey;

  @override
  @HiveField(2)
  final DateTime createdAt;

  @override
  @HiveField(3)
  final DateTime originalScheduledDate;

  @override
  @HiveField(4)
  DateTime completesAt;

  @override
  @HiveField(5)
  bool showNotification;

  @override
  @HiveField(6)
  String? note;

  @override
  @HiveField(7)
  String title;

  @override
  @HiveField(8)
  String body;

  @HiveField(9)
  int realmTrustRank;

  @HiveField(10)
  int realmRankType;

  @HiveField(11)
  int realmCurrency;

  NotificationRealmCurrency({
    required this.itemKey,
    required this.createdAt,
    required this.completesAt,
    this.note,
    required this.showNotification,
    required this.title,
    required this.body,
    required this.realmTrustRank,
    required this.realmRankType,
    required this.realmCurrency,
  }) : type = AppNotificationType.realmCurrency.index,
       originalScheduledDate = completesAt;
}
