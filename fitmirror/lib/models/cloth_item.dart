import 'package:hive/hive.dart';

part 'cloth_item.g.dart';

/// 服装类型
enum ClothType {
  @HiveField(0)
  top, // 上衣
  @HiveField(1)
  pants, // 裤子
  @HiveField(2)
  skirt, // 裙子
  @HiveField(3)
  dress, // 连衣裙
  @HiveField(4)
  jacket, // 外套
  @HiveField(5)
  shoes, // 鞋子
  @HiveField(6)
  bag, // 包包
  @HiveField(7)
  accessory, // 配饰
}

/// 服装状态
enum ClothStatus {
  @HiveField(0)
  purchased, // 已购买
  @HiveField(1)
  wishlist, // 种草中
  @HiveField(2)
  discarded, // 已淘汰
}

@HiveType(typeId: 1)
class ClothItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  ClothType type;

  @HiveField(2)
  String originalPath; // 原始截图路径

  @HiveField(3)
  String croppedPath; // 裁剪后服装图片

  @HiveField(4)
  String? productUrl; // 商品链接

  @HiveField(5)
  String? sourcePlatform; // 来源平台

  @HiveField(6)
  String color; // 主色调

  @HiveField(7)
  List<String> styleTags; // 风格标签

  @HiveField(8)
  ClothStatus status;

  @HiveField(9)
  DateTime createdAt;

  ClothItem({
    required this.id,
    required this.type,
    required this.originalPath,
    required this.croppedPath,
    this.productUrl,
    this.sourcePlatform,
    this.color = '',
    List<String>? styleTags,
    this.status = ClothStatus.wishlist,
    DateTime? createdAt,
  })  : styleTags = styleTags ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// 获取类型显示名称
  String get typeName {
    switch (type) {
      case ClothType.top:
        return '上衣';
      case ClothType.pants:
        return '裤子';
      case ClothType.skirt:
        return '裙子';
      case ClothType.dress:
        return '连衣裙';
      case ClothType.jacket:
        return '外套';
      case ClothType.shoes:
        return '鞋子';
      case ClothType.bag:
        return '包包';
      case ClothType.accessory:
        return '配饰';
    }
  }
}
