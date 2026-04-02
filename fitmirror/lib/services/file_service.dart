import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';

/// 文件上传服务
class FileService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  /// 设置 Base URL
  static void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// 设置 Token
  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// 上传单个文件
  static Future<FileUploadResult> uploadFile({
    required File file,
    required String type,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': type,
      });

      final response = await _dio.post(
        '/files/upload',
        data: formData,
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
        },
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'];
        return FileUploadResult(
          success: true,
          url: data['url'],
          fileName: data['fileName'],
          fileSize: data['fileSize'],
        );
      } else {
        return FileUploadResult(
          success: false,
          message: response.data['message'] ?? '上传失败',
        );
      }
    } catch (e) {
      return FileUploadResult(
        success: false,
        message: '上传失败: $e',
      );
    }
  }

  /// 上传多个文件
  static Future<List<FileUploadResult>> uploadMultipleFiles({
    required List<File> files,
    required String type,
  }) async {
    List<MultipartFile> multipartFiles = [];
    for (var file in files) {
      String fileName = file.path.split('/').last;
      multipartFiles.add(await MultipartFile.fromFile(file.path, filename: fileName));
    }

    FormData formData = FormData.fromMap({
      'files': multipartFiles,
      'type': type,
    });

    try {
      final response = await _dio.post('/files/upload/multiple', data: formData);

      if (response.data['code'] == 200) {
        List<FileUploadResult> results = [];
        for (var data in response.data['data']) {
          results.add(FileUploadResult(
            success: true,
            url: data['url'],
            fileName: data['fileName'],
            fileSize: data['fileSize'],
          ));
        }
        return results;
      } else {
        return [FileUploadResult(success: false, message: response.data['message'])];
      }
    } catch (e) {
      return [FileUploadResult(success: false, message: '上传失败: $e')];
    }
  }

  /// 获取完整 URL
  static String getFullUrl(String? relativeUrl) {
    if (relativeUrl == null) return '';
    if (relativeUrl.startsWith('http')) return relativeUrl;
    return '${_dio.options.baseUrl.replaceAll('/api', '')}$relativeUrl';
  }
}

class FileUploadResult {
  final bool success;
  final String? url;
  final String? fileName;
  final int? fileSize;
  final String? message;

  FileUploadResult({
    required this.success,
    this.url,
    this.fileName,
    this.fileSize,
    this.message,
  });
}
