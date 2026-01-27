import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final double radiusMeters;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  bool notified;

  Reminder({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.createdAt,
    this.notified = false,
  });
}
