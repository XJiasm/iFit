import 'package:hive/hive.dart';

part 'avatar.g.dart';

@HiveType(typeId: 0)
class Avatar extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String photoPath;

  @HiveField(3)
  String? thumbnailPath;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  Avatar({
    required this.id,
    required this.name,
    required this.photoPath,
    this.thumbnailPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  void update() {
    updatedAt = DateTime.now();
    save();
  }
}
