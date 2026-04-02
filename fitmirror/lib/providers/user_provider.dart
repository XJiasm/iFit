import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

/// 用户状态
class UserState {
  final bool isLoggedIn;
  final String? token;
  final int? userId;
  final String? username;
  final String? nickname;
  final String? avatarUrl;

  UserState({
    this.isLoggedIn = false,
    this.token,
    this.userId,
    this.username,
    this.nickname,
    this.avatarUrl,
  });

  UserState copyWith({
    bool? isLoggedIn,
    String? token,
    int? userId,
    String? username,
    String? nickname,
    String? avatarUrl,
  }) {
    return UserState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'isLoggedIn': isLoggedIn,
        'token': token,
        'userId': userId,
        'username': username,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
      };

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      isLoggedIn: json['isLoggedIn'] ?? false,
      token: json['token'],
      userId: json['userId'],
      username: json['username'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

/// 用户状态 Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState()) {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username');
      final nickname = prefs.getString('nickname');
      final avatarUrl = prefs.getString('avatarUrl');

      // 设置 API Token
      ApiService.setToken(token);

      state = UserState(
        isLoggedIn: true,
        token: token,
        userId: userId,
        username: username,
        nickname: nickname,
        avatarUrl: avatarUrl,
      );
    }
  }

  /// 登录成功后设置用户信息
  Future<void> login({
    required String token,
    required int userId,
    required String username,
    String? nickname,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);
    await prefs.setString('username', username);
    if (nickname != null) await prefs.setString('nickname', nickname);
    if (avatarUrl != null) await prefs.setString('avatarUrl', avatarUrl);

    // 设置 API Token
    ApiService.setToken(token);

    state = UserState(
      isLoggedIn: true,
      token: token,
      userId: userId,
      username: username,
      nickname: nickname,
      avatarUrl: avatarUrl,
    );
  }

  /// 更新用户信息
  Future<void> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (nickname != null) await prefs.setString('nickname', nickname);
    if (avatarUrl != null) await prefs.setString('avatarUrl', avatarUrl);

    state = state.copyWith(
      nickname: nickname,
      avatarUrl: avatarUrl,
    );
  }

  /// 退出登录
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('nickname');
    await prefs.remove('avatarUrl');

    // 清除 API Token
    ApiService.clearToken();

    state = UserState();
  }

  /// 检查登录状态
  bool get isLoggedIn => state.isLoggedIn;
}

/// 同步状态 Provider
final syncStatusProvider = StateNotifierProvider<SyncNotifier, SyncStatus>(
  (ref) => SyncNotifier(),
);

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncNotifier extends StateNotifier<SyncStatus> {
  SyncNotifier() : super(SyncStatus.idle);

  void setSyncing() => state = SyncStatus.syncing;
  void setSuccess() => state = SyncStatus.success;
  void setError() => state = SyncStatus.error;
  void setIdle() => state = SyncStatus.idle;
}
