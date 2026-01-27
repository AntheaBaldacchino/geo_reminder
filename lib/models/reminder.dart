import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 1)
class Reminder extends HiveObject {
  @HiveField(0)
  final String id;
  
  var longitude;
  
  var title;
  
  var latitude;
  
  var radiusMeters;
  
  var createdAt;
  
  var notified;


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