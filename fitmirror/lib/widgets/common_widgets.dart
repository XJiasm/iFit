import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// 小红书风格卡片组件
class XHSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const XHSCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Material(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(12),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 小红书风格按钮
class XHSButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const XHSButton({
    super.key,
    required this.text,
    this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: AppTheme.fontMd,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );

    if (isPrimary) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: const BorderSide(color: AppTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// 小红书风格标签
class XHSTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const XHSTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isSelected ? AppTheme.primaryColor : Colors.grey[100]);
    final txtColor = textColor ??
        (isSelected ? Colors.white : AppTheme.textSecondaryLight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppTheme.fontSm,
            color: txtColor,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 小红书风格头像
class XHSAvatar extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  const XHSAvatar({
    super.key,
    this.imagePath,
    this.imageUrl,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: AppTheme.primaryColor,
      ),
    );
  }
}

/// 小红书风格图片网格
class XHSImageGrid extends StatelessWidget {
  final List<String> imagePaths;
  final int crossAxisCount;
  final double aspectRatio;
  final Function(int)? onTap;

  const XHSImageGrid({
    super.key,
    required this.imagePaths,
    this.crossAxisCount = 2,
    this.aspectRatio = 0.8,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: aspectRatio,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onTap?.call(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Image.asset(
              imagePaths[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 小红书风格底部弹出菜单
class XHSBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetItem> items,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            // 选项列表
            ...items.map((item) => ListTile(
                  leading: Icon(item.icon, color: item.iconColor),
                  title: Text(item.text),
                  onTap: () {
                    Navigator.pop(context, item.value);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class BottomSheetItem<T> {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final T value;

  const BottomSheetItem({
    required this.text,
    required this.icon,
    this.iconColor,
    required this.value,
  });
}

/// 空状态组件
class XHSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const XHSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppTheme.fontLg,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.textHintLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null) ...[
              const SizedBox(height: 20),
              XHSButton(
                text: actionText!,
                onTap: onAction,
                width: 160,
                height: 40,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 旧版 Loading（保留兼容性）
class XHSLoading extends StatelessWidget {
  final String? message;
  const XHSLoading({super.key, this.message});

  @override
  Widget build(BuildContext context) => FMAiLoading(message: message);
}

// ════════════════════════════════════════════════════════════
//  FitMirror 新设计系统组件
//  设计哲学：时尚杂志感 · 沉浸 · AI 智慧感
// ════════════════════════════════════════════════════════════

/// AI 扫描光效 Loading（规范：不使用传统旋转 Loading）
class FMAiLoading extends StatefulWidget {
  final String? message;
  final double width;
  final double height;

  const FMAiLoading({
    super.key,
    this.message,
    this.width = 200,
    this.height = 120,
  });

  @override
  State<FMAiLoading> createState() => _FMAiLoadingState();
}

class _FMAiLoadingState extends State<FMAiLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scanAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _scanAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              children: [
                // 背景框
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                // 扫描光条
                AnimatedBuilder(
                  animation: _scanAnim,
                  builder: (_, __) {
                    final top = _scanAnim.value * (widget.height - 4);
                    return Positioned(
                      top: top,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.primaryColor.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // 中心 AI 图标
                Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: AppTheme.fontSm,
                color: AppTheme.textHintLight,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 渐变主操作按钮
class FMGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isLoading;
  final Gradient gradient;

  const FMGradientButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.width,
    this.height = 52,
    this.isLoading = false,
    this.gradient = AppTheme.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: isLoading
              ? const LinearGradient(colors: [Color(0xFF999999), Color(0xFFBBBBBB)])
              : gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: isLoading ? null : AppTheme.primaryGlow,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTheme.fontMd,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 玻璃拟态卡片
class FMGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool isDark;
  final VoidCallback? onTap;

  const FMGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bright = Theme.of(context).brightness;
    final dark = isDark || bright == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.80),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: dark
                ? Colors.white.withOpacity(0.12)
                : Colors.white.withOpacity(0.90),
            width: 1,
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: child,
      ),
    );
  }
}

/// 风格标签（时尚感胶囊）
class FMStyleTag extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;

  const FMStyleTag({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? c : c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? c : c.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppTheme.fontSm,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? Colors.white : c,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

/// AI 综合评分环
class FMScoreRing extends StatelessWidget {
  final int score; // 0-100
  final double size;
  final String? label;

  const FMScoreRing({
    super.key,
    required this.score,
    this.size = 80,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final pct = score / 100.0;
    final color = score >= 80
        ? AppTheme.successColor
        : score >= 60
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: pct,
            strokeWidth: 5,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.13,
                    color: AppTheme.textHintLight,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 弥散投影内容卡片（FitMirror 标准卡片）
class FMCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final double? elevation;

  const FMCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardBackgroundDark : AppTheme.cardBackgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

