import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

import '../models/avatar.dart';
import '../models/cloth_item.dart';
import '../models/tryon_result.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// 同步服务
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// 上传本地数据到云端
  Future<SyncResult> uploadToLocal() async {
    try {
      // 获取本地数据
      final avatarBox = Hive.box<Avatar>('avatars');
      final clothBox = Hive.box<ClothItem>('clothes');
      final tryOnBox = Hive.box<TryOnResult>('tryons');

      final avatars = avatarBox.values.toList();
      final clothes = clothBox.values.toList();
      final tryOns = tryOnBox.values.toList();

      // 构建请求数据
      final requestData = {
        'avatars': avatars.map((a) => {
          'localId': a.id,
          'name': a.name,
          'photoUrl': a.photoPath,
          'thumbnailUrl': a.thumbnailPath,
          'createdAt': a.createdAt.millisecondsSinceEpoch,
        }).toList(),
        'clothes': clothes.map((c) => {
          'localId': c.id,
          'type': c.type.name,
          'originalUrl': c.originalPath,
          'croppedUrl': c.croppedPath,
          'productUrl': c.productUrl,
          'sourcePlatform': c.sourcePlatform,
          'color': c.color,
          'styleTags': c.styleTags,
          'status': c.status.name,
          'createdAt': c.createdAt.millisecondsSinceEpoch,
        }).toList(),
        'tryOns': tryOns.map((t) => {
          'localId': t.id,
          'avatarLocalId': t.avatarId,
          'clothLocalId': t.clothItemId,
          'resultUrl': t.resultImagePath,
          'offsetX': t.offsetX,
          'offsetY': t.offsetY,
          'scale': t.scale,
          'rotation': t.rotation,
          'opacity': t.opacity,
          'aiScore': t.aiScore,
          'aiComment': t.aiComment,
          'createdAt': t.createdAt.millisecondsSinceEpoch,
        }).toList(),
      };

      // 调用后端API
      final response = await ApiService.dio.post('/sync/upload', data: requestData);

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        return SyncResult(
          success: true,
          message: data['message'] ?? '同步成功',
          syncedAvatars: data['syncedAvatars'] ?? 0,
          syncedClothes: data['syncedClothes'] ?? 0,
          syncedTryOns: data['syncedTryOns'] ?? 0,
        );
      } else {
        return SyncResult(
          success: false,
          message: response.data['message'] ?? '同步失败',
        );
      }
    } catch (e) {
      return SyncResult(
        success: false,
        message: '同步失败: $e',
      );
    }
  }

  /// 从云端下载数据
  Future<DownloadResult> downloadFromCloud() async {
    try {
      final response = await ApiService.dio.get('/sync/download');

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        // TODO: 将云端数据保存到本地
        return DownloadResult(
          success: true,
          message: '下载成功',
          avatars: (data['avatars'] as List?)?.length ?? 0,
          clothes: (data['clothes'] as List?)?.length ?? 0,
          tryOns: (data['tryOns'] as List?)?.length ?? 0,
        );
      } else {
        return DownloadResult(
          success: false,
          message: response.data['message'] ?? '下载失败',
        );
      }
    } catch (e) {
      return DownloadResult(
        success: false,
        message: '下载失败: $e',
      );
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedAvatars;
  final int syncedClothes;
  final int syncedTryOns;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedAvatars = 0,
    this.syncedClothes = 0,
    this.syncedTryOns = 0,
  });
}

class DownloadResult {
  final bool success;
  final String message;
  final int avatars;
  final int clothes;
  final int tryOns;

  DownloadResult({
    required this.success,
    required this.message,
    this.avatars = 0,
    this.clothes = 0,
    this.tryOns = 0,
  });
}

/// 同步状态 Provider
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());
