/// 应用常量
class AppConstants {
  // 应用信息
  static const String appName = 'FitMirror';
  static const String appVersion = '1.0.0';

  // 存储
  static const String avatarBoxName = 'avatars';
  static const String clothBoxName = 'clothes';
  static const String tryOnBoxName = 'tryons';
  static const String settingsBoxName = 'settings';

  // 图像处理
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int thumbnailSize = 200;
  static const int imageQuality = 85;

  // 试穿编辑器默认值
  static const double defaultScale = 1.0;
  static const double defaultRotation = 0.0;
  static const double defaultOpacity = 1.0;
  static const double minScale = 0.1;
  static const double maxScale = 3.0;
}

/// 服装类型映射
class ClothTypeMapping {
  static const Map<String, String> typeNames = {
    'top': '上衣',
    'pants': '裤子',
    'skirt': '裙子',
    'dress': '连衣裙',
    'jacket': '外套',
    'shoes': '鞋子',
    'bag': '包包',
    'accessory': '配饰',
  };

  static const Map<String, List<String>> styleTags = {
    'top': ['休闲', '正式', '运动', '甜美', '街头', '简约'],
    'pants': ['休闲', '正式', '运动', '阔腿', '紧身', '直筒'],
    'skirt': ['休闲', '正式', '甜美', '优雅', '性感', '少女'],
    'dress': ['休闲', '正式', '甜美', '优雅', '性感', '少女'],
    'jacket': ['休闲', '正式', '运动', '街头', '工装', '西装'],
    'shoes': ['休闲', '正式', '运动', '高跟', '平底', '靴子'],
    'bag': ['休闲', '正式', '链条', '托特', '斜挎', '手提'],
    'accessory': ['项链', '耳环', '手链', '戒指', '帽子', '围巾'],
  };
}

/// 颜色映射
class ColorMapping {
  static const List<String> commonColors = [
    '黑色',
    '白色',
    '灰色',
    '红色',
    '粉色',
    '橙色',
    '黄色',
    '绿色',
    '蓝色',
    '紫色',
    '棕色',
    '米色',
  ];
}

/// 场合映射
class OccasionMapping {
  static const List<String> occasions = [
    '日常',
    '通勤',
    '约会',
    '休闲',
    '运动',
    '派对',
    '正式',
    '度假',
  ];
}
