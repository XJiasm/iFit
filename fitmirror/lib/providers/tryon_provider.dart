import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/tryon_result.dart';

/// 试穿记录列表 Provider
final tryOnListProvider = StateNotifierProvider<TryOnListNotifier, List<TryOnResult>>(
  (ref) => TryOnListNotifier(),
);

class TryOnListNotifier extends StateNotifier<List<TryOnResult>> {
  TryOnListNotifier() : super([]) {
    _loadTryOns();
  }

  void _loadTryOns() {
    final box = Hive.box<TryOnResult>('tryons');
    state = box.values.toList();
  }

  /// 重新从本地存储加载数据
  void reload() {
    _loadTryOns();
  }

  /// 添加试穿记录
  Future<TryOnResult> addTryOnResult({
    required String avatarId,
    required String clothItemId,
    required String resultImagePath,
    double offsetX = 0,
    double offsetY = 0,
    double scale = 1.0,
    double rotation = 0,
    double opacity = 1.0,
  }) async {
    final result = TryOnResult(
      id: const Uuid().v4(),
      avatarId: avatarId,
      clothItemId: clothItemId,
      resultImagePath: resultImagePath,
      offsetX: offsetX,
      offsetY: offsetY,
      scale: scale,
      rotation: rotation,
      opacity: opacity,
    );

    final box = Hive.box<TryOnResult>('tryons');
    await box.put(result.id, result);

    state = [...state, result];
    return result;
  }

  /// 更新试穿记录
  Future<void> updateTryOnResult(TryOnResult result) async {
    result.save();
    state = state.map((t) => t.id == result.id ? result : t).toList();
  }

  /// 删除试穿记录
  Future<void> deleteTryOnResult(String id) async {
    final box = Hive.box<TryOnResult>('tryons');
    await box.delete(id);

    state = state.where((t) => t.id != id).toList();
  }

  /// 按形象筛选
  List<TryOnResult> filterByAvatar(String avatarId) {
    return state.where((t) => t.avatarId == avatarId).toList();
  }

  /// 按服装筛选
  List<TryOnResult> filterByCloth(String clothItemId) {
    return state.where((t) => t.clothItemId == clothItemId).toList();
  }
}

/// 编辑状态 Provider
class EditState {
  final double offsetX;
  final double offsetY;
  final double scale;
  final double rotation;
  final double opacity;

  EditState({
    this.offsetX = 0,
    this.offsetY = 0,
    this.scale = 1.0,
    this.rotation = 0,
    this.opacity = 1.0,
  });

  EditState copyWith({
    double? offsetX,
    double? offsetY,
    double? scale,
    double? rotation,
    double? opacity,
  }) {
    return EditState(
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
    );
  }
}

final editStateProvider = StateNotifierProvider<EditStateNotifier, EditState>(
  (ref) => EditStateNotifier(),
);

class EditStateNotifier extends StateNotifier<EditState> {
  EditStateNotifier() : super(EditState());

  void updateOffset(Offset offset) {
    state = state.copyWith(offsetX: offset.dx, offsetY: offset.dy);
  }

  void updateScale(double scale) {
    state = state.copyWith(scale: scale);
  }

  void updateRotation(double rotation) {
    state = state.copyWith(rotation: rotation);
  }

  void updateOpacity(double opacity) {
    state = state.copyWith(opacity: opacity);
  }

  void reset() {
    state = EditState();
  }
}
