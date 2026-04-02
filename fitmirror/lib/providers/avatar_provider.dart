import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/avatar.dart';

/// 形象列表 Provider
final avatarListProvider = StateNotifierProvider<AvatarListNotifier, List<Avatar>>(
  (ref) => AvatarListNotifier(),
);

class AvatarListNotifier extends StateNotifier<List<Avatar>> {
  AvatarListNotifier() : super([]) {
    _loadAvatars();
  }

  void _loadAvatars() {
    final box = Hive.box<Avatar>('avatars');
    state = box.values.toList();
  }

  /// 添加形象
  Future<Avatar> addAvatar({
    required String name,
    required String photoPath,
    String? thumbnailPath,
  }) async {
    final avatar = Avatar(
      id: const Uuid().v4(),
      name: name,
      photoPath: photoPath,
      thumbnailPath: thumbnailPath,
    );

    final box = Hive.box<Avatar>('avatars');
    await box.put(avatar.id, avatar);

    state = [...state, avatar];
    return avatar;
  }

  /// 更新形象
  Future<void> updateAvatar(Avatar avatar) async {
    avatar.update();
    state = state.map((a) => a.id == avatar.id ? avatar : a).toList();
  }

  /// 删除形象
  Future<void> deleteAvatar(String id) async {
    final box = Hive.box<Avatar>('avatars');
    await box.delete(id);

    state = state.where((a) => a.id != id).toList();
  }

  /// 获取形象
  Avatar? getAvatar(String id) {
    return state.where((a) => a.id == id).firstOrNull;
  }
}

/// 当前选中的形象 Provider
final selectedAvatarProvider = StateProvider<Avatar?>((ref) => null);
