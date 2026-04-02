import 'package:hive/hive.dart';

part 'tryon_result.g.dart';

@HiveType(typeId: 2)
class TryOnResult extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String avatarId;

  @HiveField(2)
  String clothItemId;

  @HiveField(3)
  String resultImagePath; // 合成效果图路径

  // 编辑参数（用于再次编辑）
  @HiveField(4)
  double offsetX;

  @HiveField(5)
  double offsetY;

  @HiveField(6)
  double scale;

  @HiveField(7)
  double rotation;

  @HiveField(8)
  double opacity;

  // AI 点评结果
  @HiveField(9)
  int? aiScore; // 综合评分 0-100

  @HiveField(10)
  String? aiComment; // AI 点评内容

  @HiveField(11)
  Map<String, dynamic>? aiDetails; // 详细点评

  @HiveField(12)
  DateTime createdAt;

  TryOnResult({
    required this.id,
    required this.avatarId,
    required this.clothItemId,
    required this.resultImagePath,
    this.offsetX = 0,
    this.offsetY = 0,
    this.scale = 1.0,
    this.rotation = 0,
    this.opacity = 1.0,
    this.aiScore,
    this.aiComment,
    this.aiDetails,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 更新编辑参数
  void updateEditParams({
    double? offsetX,
    double? offsetY,
    double? scale,
    double? rotation,
    double? opacity,
  }) {
    if (offsetX != null) this.offsetX = offsetX;
    if (offsetY != null) this.offsetY = offsetY;
    if (scale != null) this.scale = scale;
    if (rotation != null) this.rotation = rotation;
    if (opacity != null) this.opacity = opacity;
    save();
  }

  /// 更新 AI 点评
  void updateAiComment({
    required int score,
    required String comment,
    Map<String, dynamic>? details,
  }) {
    aiScore = score;
    aiComment = comment;
    aiDetails = details;
    save();
  }
}
