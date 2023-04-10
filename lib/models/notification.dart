import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 0)
class Notification {
  @HiveField(0)
  String title;

  @HiveField(1)
  String message;

  @HiveField(2)
  DateTime dateTime;

  Notification({required this.title, required this.message, required this.dateTime});
}
