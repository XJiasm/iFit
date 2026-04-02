import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 图像处理服务
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  /// 合成试穿效果图
  Future<String?> composeTryOnImage({
    required String avatarPath,
    required String clothPath,
    required double offsetX,
    required double offsetY,
    required double scale,
    required double rotation,
    required double opacity,
  }) async {
    try {
      // 读取图片
      final avatarFile = File(avatarPath);
      final clothFile = File(clothPath);

      if (!avatarFile.existsSync() || !clothFile.existsSync()) {
        return null;
      }

      final avatarBytes = await avatarFile.readAsBytes();
      final clothBytes = await clothFile.readAsBytes();

      final avatarImg = img.decodeImage(avatarBytes);
      final clothImg = img.decodeImage(clothBytes);

      if (avatarImg == null || clothImg == null) {
        return null;
      }

      // 缩放服装
      final scaledWidth = (clothImg.width * scale).toInt();
      final scaledHeight = (clothImg.height * scale).toInt();

      if (scaledWidth <= 0 || scaledHeight <= 0) {
        return null;
      }

      final scaledCloth = img.copyResize(clothImg, width: scaledWidth, height: scaledHeight);

      // 旋转服装
      final rotationDegrees = rotation * 180 / 3.14159;
      final rotatedCloth = img.copyRotate(scaledCloth, angle: rotationDegrees);

      // 计算合成位置
      final posX = offsetX.toInt();
      final posY = offsetY.toInt();

      // 创建结果图像
      final resultImg = img.Image(width: avatarImg.width, height: avatarImg.height);

      // 先绘制背景（用户形象）
      img.compositeImage(resultImg, avatarImg, dstX: 0, dstY: 0);

      // 再绘制服装图层
      if (posX >= 0 && posY >= 0 &&
          posX + rotatedCloth.width <= resultImg.width &&
          posY + rotatedCloth.height <= resultImg.height) {
        img.compositeImage(
          resultImg,
          rotatedCloth,
          dstX: posX,
          dstY: posY,
        );
      }

      // 保存结果
      final tempDir = await getTemporaryDirectory();
      final resultPath = p.join(tempDir.path, 'tryon_${DateTime.now().millisecondsSinceEpoch}.png');
      final resultFile = File(resultPath);
      await resultFile.writeAsBytes(img.encodePng(resultImg));

      return resultPath;
    } catch (e) {
      print('图像合成失败: $e');
      return null;
    }
  }

  /// 创建缩略图
  Future<String?> createThumbnail(String imagePath, {int maxSize = 200}) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // 计算缩放比例
      final ratio = image.width > image.height
          ? maxSize / image.width
          : maxSize / image.height;

      final thumbnail = img.copyResize(
        image,
        width: (image.width * ratio).toInt(),
        height: (image.height * ratio).toInt(),
      );

      // 保存缩略图
      final dir = p.dirname(imagePath);
      final fileName = p.basenameWithoutExtension(imagePath);
      final ext = p.extension(imagePath);
      final thumbPath = p.join(dir, '${fileName}_thumb$ext');
      final thumbFile = File(thumbPath);
      await thumbFile.writeAsBytes(img.encodeJpg(thumbnail, quality: 80));

      return thumbPath;
    } catch (e) {
      print('创建缩略图失败: $e');
      return null;
    }
  }

  /// 压缩图片
  Future<File?> compressImage(File imageFile, {int quality = 85, int maxWidth = 1024}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // 如果图片过大，进行缩放
      img.Image result = image;
      if (image.width > maxWidth) {
        final ratio = maxWidth / image.width;
        result = img.copyResize(
          image,
          width: maxWidth,
          height: (image.height * ratio).toInt(),
        );
      }

      // 压缩保存
      final compressedBytes = img.encodeJpg(result, quality: quality);
      final compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('压缩图片失败: $e');
      return null;
    }
  }

  /// 获取图片信息
  Future<Map<String, dynamic>?> getImageInfo(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      return {
        'width': image.width,
        'height': image.height,
        'size': bytes.length,
      };
    } catch (e) {
      return null;
    }
  }
}
