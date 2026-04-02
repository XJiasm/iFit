import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 本地存储服务
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static late Directory _appDir;
  static late Directory _avatarDir;
  static late Directory _clothDir;
  static late Directory _tryOnDir;
  static late Directory _cacheDir;

  static bool _initialized = false;

  /// 初始化存储目录
  Future<void> init() async {
    if (_initialized) return;

    _appDir = await getApplicationDocumentsDirectory();
    _cacheDir = await getTemporaryDirectory();

    _avatarDir = Directory(p.join(_appDir.path, 'fitmirror', 'avatars'));
    _clothDir = Directory(p.join(_appDir.path, 'fitmirror', 'clothes'));
    _tryOnDir = Directory(p.join(_appDir.path, 'fitmirror', 'tryons'));

    // 确保目录存在
    if (!_avatarDir.existsSync()) _avatarDir.createSync(recursive: true);
    if (!_clothDir.existsSync()) _clothDir.createSync(recursive: true);
    if (!_tryOnDir.existsSync()) _tryOnDir.createSync(recursive: true);

    _initialized = true;
  }

  /// 保存形象照片
  Future<String> saveAvatarImage(File imageFile) async {
    await init();
    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final targetPath = p.join(_avatarDir.path, fileName);
    await imageFile.copy(targetPath);
    return targetPath;
  }

  /// 保存服装图片
  Future<String> saveClothImage(File imageFile, {bool isCropped = false}) async {
    await init();
    final prefix = isCropped ? 'cropped' : 'original';
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.png';
    final targetPath = p.join(_clothDir.path, fileName);
    await imageFile.copy(targetPath);
    return targetPath;
  }

  /// 保存试穿效果图
  Future<String> saveTryOnImage(File imageFile) async {
    await init();
    final fileName = 'tryon_${DateTime.now().millisecondsSinceEpoch}.png';
    final targetPath = p.join(_tryOnDir.path, fileName);
    await imageFile.copy(targetPath);
    return targetPath;
  }

  /// 创建缩略图
  Future<String?> createThumbnail(String imagePath, {int maxSize = 200}) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return null;

      // 简单实现：直接返回原图路径
      // 实际项目中可以使用 image 包进行缩放
      return imagePath;
    } catch (e) {
      print('创建缩略图失败: $e');
      return null;
    }
  }

  /// 删除文件
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize() async {
    await init();
    int size = 0;

    for (final dir in [_avatarDir, _clothDir, _tryOnDir]) {
      if (dir.existsSync()) {
        for (final file in dir.listSync()) {
          if (file is File) {
            size += file.lengthSync();
          }
        }
      }
    }

    return size;
  }

  /// 格式化文件大小
  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    await init();
    for (final dir in [_avatarDir, _clothDir, _tryOnDir]) {
      if (dir.existsSync()) {
        for (final file in dir.listSync()) {
          await file.delete(recursive: true);
        }
      }
    }
  }

  /// 获取应用文档目录
  Directory get appDir {
    init();
    return _appDir;
  }

  /// 获取缓存目录
  Directory get cacheDir {
    init();
    return _cacheDir;
  }
}
