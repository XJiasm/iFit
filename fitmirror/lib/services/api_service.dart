import 'dart:io';
import 'package:dio/dio.dart';

/// API 服务
class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  /// 设置 Base URL
  static void setBaseUrl(String url) {
    dio.options.baseUrl = url;
  }

  /// 设置 Token
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// 清除 Token
  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }

  // ==================== 认证相关 ====================

  /// 用户注册
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? nickname,
    String? email,
  }) async {
    final response = await dio.post('/auth/register', data: {
      'username': username,
      'password': password,
      'nickname': nickname,
      'email': email,
    });
    return response.data;
  }

  /// 用户登录
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    return response.data;
  }

  /// 获取用户信息
  static Future<Map<String, dynamic>> getUserInfo() async {
    final response = await dio.get('/user/info');
    return response.data;
  }

  /// 更新用户资料
  static Future<Map<String, dynamic>> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    final response = await dio.put('/user/profile', data: {
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    });
    return response.data;
  }

  // ==================== AI 点评 ====================

  /// 获取 AI 点评
  static Future<Map<String, dynamic>> getAiComment({
    required String clothType,
    required String clothColor,
    String? productUrl,
    String? userStyle,
    String? occasion,
    List<String>? existingStyles,
  }) async {
    final response = await dio.post('/ai/comment', data: {
      'clothType': clothType,
      'clothColor': clothColor,
      'productUrl': productUrl,
      'userStyle': userStyle,
      'occasion': occasion,
      'existingStyles': existingStyles,
    });
    return response.data;
  }

  /// 获取支持的 AI 提供商
  static Future<List<String>> getAiProviders() async {
    final response = await dio.get('/ai/providers');
    return List<String>.from(response.data['data']);
  }

  // ==================== 健康检查 ====================

  static Future<bool> healthCheck() async {
    try {
      final response = await dio.get('/health');
      return response.data['status'] == 'ok';
    } catch (e) {
      return false;
    }
  }
}

/// AI 点评响应模型
class AiCommentResponse {
  final int score;
  final String summary;
  final ColorAnalysis color;
  final StyleAnalysis style;
  final List<String> occasions;
  final List<String> suggestions;
  final String conclusion;

  AiCommentResponse({
    required this.score,
    required this.summary,
    required this.color,
    required this.style,
    required this.occasions,
    required this.suggestions,
    required this.conclusion,
  });

  factory AiCommentResponse.fromJson(Map<String, dynamic> json) {
    return AiCommentResponse(
      score: json['score'] ?? 85,
      summary: json['summary'] ?? '',
      color: ColorAnalysis.fromJson(json['color'] ?? {}),
      style: StyleAnalysis.fromJson(json['style'] ?? {}),
      occasions: List<String>.from(json['occasions'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      conclusion: json['conclusion'] ?? '',
    );
  }
}

class ColorAnalysis {
  final int score;
  final String comment;
  final List<String> suitableSkinTones;

  ColorAnalysis({
    required this.score,
    required this.comment,
    required this.suitableSkinTones,
  });

  factory ColorAnalysis.fromJson(Map<String, dynamic> json) {
    return ColorAnalysis(
      score: json['score'] ?? 80,
      comment: json['comment'] ?? '',
      suitableSkinTones: List<String>.from(json['suitableSkinTones'] ?? []),
    );
  }
}

class StyleAnalysis {
  final int score;
  final String comment;
  final List<String> tags;

  StyleAnalysis({
    required this.score,
    required this.comment,
    required this.tags,
  });

  factory StyleAnalysis.fromJson(Map<String, dynamic> json) {
    return StyleAnalysis(
      score: json['score'] ?? 80,
      comment: json['comment'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
