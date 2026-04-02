import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/cloth_item.dart';

/// 服装列表 Provider
final clothListProvider = StateNotifierProvider<ClothListNotifier, List<ClothItem>>(
  (ref) => ClothListNotifier(),
);

class ClothListNotifier extends StateNotifier<List<ClothItem>> {
  ClothListNotifier() : super([]) {
    _loadClothes();
  }

  void _loadClothes() {
    final box = Hive.box<ClothItem>('clothes');
    state = box.values.toList();
  }

  /// 重新从本地存储加载数据
  void reload() {
    _loadClothes();
  }

  /// 添加服装
  Future<ClothItem> addClothItem({
    required ClothType type,
    required String originalPath,
    required String croppedPath,
    String? productUrl,
    String? sourcePlatform,
    String color = '',
    List<String>? styleTags,
    ClothStatus status = ClothStatus.wishlist,
  }) async {
    final item = ClothItem(
      id: const Uuid().v4(),
      type: type,
      originalPath: originalPath,
      croppedPath: croppedPath,
      productUrl: productUrl,
      sourcePlatform: sourcePlatform,
      color: color,
      styleTags: styleTags,
      status: status,
    );

    final box = Hive.box<ClothItem>('clothes');
    await box.put(item.id, item);

    state = [...state, item];
    return item;
  }

  /// 更新服装
  Future<void> updateClothItem(ClothItem item) async {
    item.save();
    state = state.map((c) => c.id == item.id ? item : c).toList();
  }

  /// 删除服装
  Future<void> deleteClothItem(String id) async {
    final box = Hive.box<ClothItem>('clothes');
    await box.delete(id);

    state = state.where((c) => c.id != id).toList();
  }

  /// 按类型筛选
  List<ClothItem> filterByType(ClothType type) {
    return state.where((c) => c.type == type).toList();
  }

  /// 按状态筛选
  List<ClothItem> filterByStatus(ClothStatus status) {
    return state.where((c) => c.status == status).toList();
  }
}
