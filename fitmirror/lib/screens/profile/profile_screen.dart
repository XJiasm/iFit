import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/avatar_provider.dart';
import '../../providers/cloth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/tryon_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/sync_service.dart';
import '../../utils/app_theme.dart';
import '../auth/auth_page.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final avatars = ref.watch(avatarListProvider);
    final clothes = ref.watch(clothListProvider);
    final tryOns = ref.watch(tryOnListProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _ProfileHero(
                    userState: userState,
                    avatars: avatars.length,
                    clothes: clothes.length,
                    tryOns: tryOns.length,
                    onTap: () => _handleUserTap(context, ref, userState),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _OfflineCard(isLoggedIn: userState.isLoggedIn),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionHeader(
                    title: '设置与同步',
                    subtitle: '账号、主题、同步和本地数据管理',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(
                    children: [
                      _SettingRow(
                        icon: Icons.dark_mode_outlined,
                        title: '深色主题',
                        subtitle: '默认启用 FitMirror 深色品牌模式',
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          activeColor: AppTheme.primaryLight,
                          onChanged: (value) {
                            ref.read(themeModeProvider.notifier).setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light);
                          },
                        ),
                      ),
                      _SettingRow(
                        icon: Icons.cloud_sync_outlined,
                        title: '数据同步',
                        subtitle:
                            userState.isLoggedIn ? '同步本地数据到云端' : '登录后可开启云端同步',
                        onTap: () =>
                            _showSyncDialog(context, ref, userState.isLoggedIn),
                      ),
                      _SettingRow(
                        icon: Icons.storage_outlined,
                        title: '本地存储',
                        subtitle: '查看缓存占用和清理策略',
                        onTap: () => _showStorageSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionHeader(
                    title: '会员权益',
                    subtitle: '将 AI 点评、试穿次数和多形象能力纳入同一品牌体系',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const _ProCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionHeader(
                    title: '更多',
                    subtitle: '反馈、隐私和账号操作',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    AppTheme.bottomNavHeight + 20,
                  ),
                  child: _SettingsGroup(
                    children: [
                      _SettingRow(
                        icon: Icons.feedback_outlined,
                        title: '意见反馈',
                        subtitle: '记录你对试穿体验和 AI 点评的建议',
                        onTap: () => _showMessage(context, '反馈入口后续接入'),
                      ),
                      _SettingRow(
                        icon: Icons.privacy_tip_outlined,
                        title: '隐私说明',
                        subtitle: '形象图片默认保存在本地，登录后才会同步',
                        onTap: () => _showMessage(context, '隐私文案后续补充'),
                      ),
                      _SettingRow(
                        icon: userState.isLoggedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                        title: userState.isLoggedIn ? '退出登录' : '登录账号',
                        subtitle: userState.isLoggedIn
                            ? '退出后本地数据仍会保留'
                            : '登录后可开启同步和会员能力',
                        iconColor: userState.isLoggedIn
                            ? AppTheme.errorColor
                            : AppTheme.primaryLight,
                        onTap: () async {
                          if (userState.isLoggedIn) {
                            await ref.read(userProvider.notifier).logout();
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AuthPage(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUserTap(
    BuildContext context,
    WidgetRef ref,
    UserState userState,
  ) async {
    if (userState.isLoggedIn) {
      _showMessage(context, '资料编辑入口后续补齐');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }
  void _showSyncDialog(
    BuildContext context,
    WidgetRef ref,
    bool isLoggedIn,
  ) {
    if (!isLoggedIn) {
      _showMessage(context, '请先登录账号再启用云端同步');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text('数据同步'),
        content: Text(
          '将执行：先上传本地数据，再下载云端最新数据覆盖本地',
          style: const TextStyle(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _runSync(context, ref);
            },
            child: const Text('开始同步'),
          ),
        ],
      ),
    );
  }

  Future<void> _runSync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final syncStatus = ref.read(syncStatusProvider.notifier);
    final syncService = ref.read(syncServiceProvider);

    syncStatus.setSyncing();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('正在同步数据，请稍候...'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final uploadResult = await syncService.uploadToLocal();
    if (!uploadResult.success) {
      syncStatus.setError();
      messenger.showSnackBar(
        SnackBar(
          content: Text(uploadResult.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final downloadResult = await syncService.downloadFromCloud();
    if (!downloadResult.success) {
      syncStatus.setError();
      messenger.showSnackBar(
        SnackBar(
          content: Text(downloadResult.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(avatarListProvider.notifier).reload();
    ref.read(clothListProvider.notifier).reload();
    ref.read(tryOnListProvider.notifier).reload();
    syncStatus.setSuccess();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '同步完成：头像 ${downloadResult.avatars}、单品 ${downloadResult.clothes}、试穿 ${downloadResult.tryOns}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStorageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundDark,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _StorageRow(label: '形象图片', size: '约 5.2 MB'),
                  const SizedBox(height: 10),
                  const _StorageRow(label: '服装素材', size: '约 8.3 MB'),
                  const SizedBox(height: 10),
                  const _StorageRow(label: '试穿结果', size: '约 2.1 MB'),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showMessage(context, '清理缓存逻辑后续补齐');
                    },
                    child: const Text('清理本地缓存'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.userState,
    required this.avatars,
    required this.clothes,
    required this.tryOns,
    required this.onTap,
  });

  final UserState userState;
  final int avatars;
  final int clothes;
  final int tryOns;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          gradient: AppTheme.profileGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
          boxShadow: AppTheme.primaryGlow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.32),
                      width: 2,
                    ),
                  ),
                  child: userState.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            userState.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userState.isLoggedIn
                            ? (userState.nickname ??
                                userState.username ??
                                'FitMirror 用户')
                            : '未登录',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        userState.isLoggedIn
                            ? '点击管理资料与同步能力'
                            : '登录后可同步形象、资产和试穿历史',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.86),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _HeroMetric(label: '形象', value: '$avatars')),
                const SizedBox(width: 10),
                Expanded(child: _HeroMetric(label: '单品', value: '$clothes')),
                const SizedBox(width: 10),
                Expanded(child: _HeroMetric(label: '试穿', value: '$tryOns')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard({required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.warningCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.warningColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isLoggedIn
                  ? '当前仍以本地数据为主，后续会补上真实同步状态。'
                  : '你现在处于离线优先模式，所有试穿结果默认只保存在本地。',
              style: const TextStyle(
                color: AppTheme.warningColor,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.56),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        children: children
            .expand(
              (child) => [
                child,
                if (child != children.last)
                  Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.06),
                  ),
              ],
            )
            .toList(),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryLight).withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primaryLight),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimaryDark,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondaryDark,
            fontSize: 12,
          ),
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textHintDark,
          ),
    );
  }
}

class _ProCard extends StatelessWidget {
  const _ProCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '￥19.9 / 月',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            '升级 FitMirror Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '解锁无限试穿、深度 AI 点评、多形象管理和周期性穿搭报告。',
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          const _ProFeature(text: '无限次试穿与更深的 AI 点评'),
          const SizedBox(height: 8),
          const _ProFeature(text: '最多 5 个数字形象'),
          const SizedBox(height: 8),
          const _ProFeature(text: '每周 / 每月穿搭报告'),
          const SizedBox(height: 18),
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: const Center(
              child: Text(
                '即将开放升级',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProFeature extends StatelessWidget {
  const _ProFeature({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.92),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _StorageRow extends StatelessWidget {
  const _StorageRow({
    required this.label,
    required this.size,
  });

  final String label;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_open_rounded, color: AppTheme.primaryLight),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            size,
            style: const TextStyle(color: AppTheme.textSecondaryDark),
          ),
        ],
      ),
    );
  }
}
