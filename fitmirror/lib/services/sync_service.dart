import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/avatar.dart';
import '../models/cloth_item.dart';
import '../models/tryon_result.dart';
import 'api_service.dart';

/// 同步服务
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// 上传本地数据到云端
  Future<SyncResult> uploadToLocal() async {
    try {
      final avatarBox = Hive.box<Avatar>('avatars');
      final clothBox = Hive.box<ClothItem>('clothes');
      final tryOnBox = Hive.box<TryOnResult>('tryons');

      final avatars = avatarBox.values.toList();
      final clothes = clothBox.values.toList();
      final tryOns = tryOnBox.values.toList();

      final requestData = {
        'avatars': avatars
            .map(
              (a) => {
                'localId': a.id,
                'name': a.name,
                'photoUrl': a.photoPath,
                'thumbnailUrl': a.thumbnailPath,
                'createdAt': a.createdAt.millisecondsSinceEpoch,
              },
            )
            .toList(),
        'clothes': clothes
            .map(
              (c) => {
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
              },
            )
            .toList(),
        'tryOns': tryOns
            .map(
              (t) => {
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
              },
            )
            .toList(),
      };

      final response = await ApiService.dio.post('/sync/upload', data: requestData);

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        return SyncResult(
          success: true,
          message: data['message']?.toString() ?? '同步成功',
          syncedAvatars: _asInt(data['syncedAvatars']),
          syncedClothes: _asInt(data['syncedClothes']),
          syncedTryOns: _asInt(data['syncedTryOns']),
        );
      }

      return SyncResult(
        success: false,
        message: response.data['message']?.toString() ?? '同步失败',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: '同步失败: $e',
      );
    }
  }

  /// 从云端下载数据，并写入本地 Hive
  Future<DownloadResult> downloadFromCloud() async {
    try {
      final response = await ApiService.dio.get('/sync/download');

      if (response.data['code'] == 200) {
        final data = Map<String, dynamic>.from(response.data['data'] ?? {});
        await _saveCloudDataToLocal(data);
        return DownloadResult(
          success: true,
          message: '下载并写入本地成功',
          avatars: (data['avatars'] as List?)?.length ?? 0,
          clothes: (data['clothes'] as List?)?.length ?? 0,
          tryOns: (data['tryOns'] as List?)?.length ?? 0,
        );
      }

      return DownloadResult(
        success: false,
        message: response.data['message']?.toString() ?? '下载失败',
      );
    } catch (e) {
      return DownloadResult(
        success: false,
        message: '下载失败: $e',
      );
    }
  }

  Future<void> _saveCloudDataToLocal(Map<String, dynamic> data) async {
    final avatarBox = Hive.box<Avatar>('avatars');
    final clothBox = Hive.box<ClothItem>('clothes');
    final tryOnBox = Hive.box<TryOnResult>('tryons');

    final avatars = (data['avatars'] as List?) ?? const [];
    final clothes = (data['clothes'] as List?) ?? const [];
    final tryOns = (data['tryOns'] as List?) ?? const [];

    await avatarBox.clear();
    await clothBox.clear();
    await tryOnBox.clear();

    for (final item in avatars) {
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      final id = _asString(map['id']);
      if (id.isEmpty) {
        continue;
      }

      final avatar = Avatar(
        id: id,
        name: _asString(map['name']).isEmpty ? '未命名形象' : _asString(map['name']),
        photoPath: _asString(map['photoUrl']),
        thumbnailPath: _nullableString(map['thumbnailUrl']),
        createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(map['updatedAt']) ?? DateTime.now(),
      );
      await avatarBox.put(avatar.id, avatar);
    }

    for (final item in clothes) {
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      final id = _asString(map['id']);
      if (id.isEmpty) {
        continue;
      }

      final cloth = ClothItem(
        id: id,
        type: _parseClothType(map['type']),
        originalPath: _asString(map['originalUrl']),
        croppedPath: _asString(map['croppedUrl']),
        productUrl: _nullableString(map['productUrl']),
        sourcePlatform: _nullableString(map['sourcePlatform']),
        color: _asString(map['color']),
        styleTags: _parseStyleTags(map['styleTags']),
        status: _parseClothStatus(map['status']),
        createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      );
      await clothBox.put(cloth.id, cloth);
    }

    for (final item in tryOns) {
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      final id = _asString(map['id']);
      if (id.isEmpty) {
        continue;
      }

      final result = TryOnResult(
        id: id,
        avatarId: _asString(map['avatarId']),
        clothItemId: _asString(map['clothItemId']),
        resultImagePath: _asString(map['resultUrl']),
        offsetX: _asDouble(map['offsetX']),
        offsetY: _asDouble(map['offsetY']),
        scale: _asDouble(map['scale'], defaultValue: 1.0),
        rotation: _asDouble(map['rotation']),
        opacity: _asDouble(map['opacity'], defaultValue: 1.0),
        aiScore: _asIntNullable(map['aiScore']),
        aiComment: _nullableString(map['aiComment']),
        createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      );
      await tryOnBox.put(result.id, result);
    }
  }

  int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  String _asString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  String? _nullableString(dynamic value) {
    final text = _asString(value).trim();
    return text.isEmpty ? null : text;
  }

  double _asDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  int? _asIntNullable(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is List && value.length >= 3) {
      final numbers = value.whereType<num>().toList();
      if (numbers.length >= 3) {
        final year = numbers[0].toInt();
        final month = numbers[1].toInt();
        final day = numbers[2].toInt();
        final hour = numbers.length > 3 ? numbers[3].toInt() : 0;
        final minute = numbers.length > 4 ? numbers[4].toInt() : 0;
        final second = numbers.length > 5 ? numbers[5].toInt() : 0;
        return DateTime(year, month, day, hour, minute, second);
      }
    }
    return null;
  }

  ClothType _parseClothType(dynamic value) {
    final raw = _asString(value).toLowerCase();
    return ClothType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => ClothType.top,
    );
  }

  ClothStatus _parseClothStatus(dynamic value) {
    final raw = _asString(value).toLowerCase();
    return ClothStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => ClothStatus.wishlist,
    );
  }

  List<String> _parseStyleTags(dynamic value) {
    if (value == null) {
      return [];
    }
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return [];
      }
      if (trimmed.startsWith('[')) {
        try {
          final parsed = jsonDecode(trimmed);
          if (parsed is List) {
            return parsed.map((e) => e.toString()).toList();
          }
        } catch (_) {
          return [];
        }
      }
    }
    return [];
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

/// 同步服务 Provider
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());
