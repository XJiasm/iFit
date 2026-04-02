/// 工具函数
class Helpers {
  /// 格式化日期
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return '刚刚';
        }
        return '${diff.inMinutes}分钟前';
      }
      return '${diff.inHours}小时前';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else {
      return '${(diff.inDays / 365).floor()}年前';
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// 生成唯一ID
  static String generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_randomString(6)}';
  }

  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(chars[DateTime.now().microsecondsSinceEpoch % chars.length]);
    }
    return buffer.toString();
  }

  /// 计算评分等级
  static String getScoreLevel(int score) {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '中等';
    if (score >= 60) return '及格';
    return '待改进';
  }

  /// 获取评分颜色（十六进制）
  static String getScoreColor(int score) {
    if (score >= 80) return '#00C853'; // 绿色
    if (score >= 60) return '#FFB800'; // 黄色
    return '#FF5722'; // 橙色
  }
}
