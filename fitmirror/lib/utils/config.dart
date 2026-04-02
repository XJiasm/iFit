/// 应用配置
class AppConfig {
  // 应用信息
  static const String appName = 'FitMirror';
  static const String appVersion = '1.0.0';

  // API 配置
  static const String defaultApiBaseUrl = 'http://localhost:8080/api';
  static String apiBaseUrl = defaultApiBaseUrl;

  // 存储键名
  static const String keyToken = 'token';
  static const String keyUserId = 'userId';
  static const String keyUsername = 'username';
  static const String keyNickname = 'nickname';
  static const String keyAvatarUrl = 'avatarUrl';
  static const String keyThemeMode = 'themeMode';

  // 存储盒子名称
  static const String avatarBoxName = 'avatars';
  static const String clothBoxName = 'clothes';
  static const String tryOnBoxName = 'tryons';
  static const String settingsBoxName = 'settings';

  // 图像处理配置
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int thumbnailSize = 200;
  static const int imageQuality = 85;

  // 试穿编辑器配置
  static const double defaultScale = 1.0;
  static const double defaultRotation = 0.0;
  static const double defaultOpacity = 1.0;
  static const double minScale = 0.3;
  static const double maxScale = 3.0;

  // 超时配置
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// 设置 API 基础 URL
  static void setApiBaseUrl(String url) {
    apiBaseUrl = url;
  }
}

/// 服装类型
enum ClothType {
  top,
  pants,
  skirt,
  dress,
  jacket,
  shoes,
  bag,
  accessory,
}

/// 服装类型扩展
extension ClothTypeExtension on ClothType {
  String get name {
    switch (this) {
      case ClothType.top:
        return '上衣';
      case ClothType.pants:
        return '裤子';
      case ClothType.skirt:
        return '裙子';
      case ClothType.dress:
        return '连衣裙';
      case ClothType.jacket:
        return '外套';
      case ClothType.shoes:
        return '鞋子';
      case ClothType.bag:
        return '包包';
      case ClothType.accessory:
        return '配饰';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static ClothType fromValue(String value) {
    return ClothType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClothType.top,
    );
  }
}

/// 服装状态
enum ClothStatus {
  wishlist,
  purchased,
  discarded,
}

/// 服装状态扩展
extension ClothStatusExtension on ClothStatus {
  String get name {
    switch (this) {
      case ClothStatus.wishlist:
        return '种草中';
      case ClothStatus.purchased:
        return '已购买';
      case ClothStatus.discarded:
        return '已淘汰';
    }
  }

  String get value {
    return toString().split('.').last;
  }
}

/// 常用颜色
class AppColors {
  static const List<String> commonColors = [
    '黑色', '白色', '灰色', '深灰', '浅灰',
    '红色', '酒红', '粉色', '浅粉',
    '橙色', '橘色', '卡其色',
    '黄色', '姜黄', '米黄',
    '绿色', '墨绿', '浅绿', '牛油果绿',
    '蓝色', '深蓝', '浅蓝', '藏青',
    '紫色', '深紫', '浅紫', '薰衣草紫',
    '棕色', '咖啡色', '驼色',
    '米色', '杏色', '奶油色',
    '金色', '银色',
  ];

  static const List<String> styleTags = [
    '休闲', '正式', '运动', '甜美', '街头', '简约',
    '优雅', '复古', '潮流', '文艺', '性感', '少女',
    '商务', '通勤', '约会', '度假', '居家',
  ];

  static const List<String> occasions = [
    '日常休闲', '通勤上班', '朋友聚会', '约会',
    '商务会议', '户外运动', '度假旅行', '居家',
  ];
}
