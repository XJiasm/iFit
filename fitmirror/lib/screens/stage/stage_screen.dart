import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/avatar.dart';
import '../../models/tryon_result.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/tryon_provider.dart';
import '../../utils/app_theme.dart';
import '../avatar/avatar_list_screen.dart';

class StageScreen extends ConsumerStatefulWidget {
  const StageScreen({super.key});

  @override
  ConsumerState<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends ConsumerState<StageScreen> {
  int _activeAvatarIndex = 0;

  @override
  Widget build(BuildContext context) {
    final avatars = ref.watch(avatarListProvider);
    final tryOns = ref.watch(tryOnListProvider);

    if (_activeAvatarIndex >= avatars.length && avatars.isNotEmpty) {
      _activeAvatarIndex = avatars.length - 1;
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: avatars.isEmpty
              ? _EmptyStage(
                  onCreateAvatar: _openAvatarManager,
                  onBrowseCloset: () =>
                      ref.read(currentTabIndexProvider.notifier).state = 1,
                  onStartStudio: () =>
                      ref.read(currentTabIndexProvider.notifier).state = 2,
                )
              : _buildContent(avatars, tryOns),
        ),
      ),
    );
  }

  Widget _buildContent(List<Avatar> avatars, List<TryOnResult> tryOns) {
    final activeAvatar = avatars[_activeAvatarIndex];
    final avatarTryOns = tryOns
        .where((item) => item.avatarId == activeAvatar.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _TopBar(onManageAvatar: _openAvatarManager),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _HeroCard(
              avatar: activeAvatar,
              avatarCount: avatars.length,
              tryOnCount: avatarTryOns.length,
              onPrimaryTap: () =>
                  ref.read(currentTabIndexProvider.notifier).state = 2,
              onSecondaryTap: _openAvatarManager,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppTheme.bottomNavHeight + 12),
        ),
      ],
    );
  }

  void _openAvatarManager() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AvatarListScreen()),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onManageAvatar});

  final VoidCallback onManageAvatar;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final compact = MediaQuery.sizeOf(context).width < 380;
    final greeting = switch (hour) {
      < 6 => '深夜好',
      < 12 => '早安',
      < 18 => '下午好',
      _ => '晚上好',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 360;

        Widget copyBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: const TextScaler.linear(1),
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: compact ? 24 : 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '从形象开始，进入你的数字试衣间',
              maxLines: stacked ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              textScaler: const TextScaler.linear(1),
              style: TextStyle(
                color: Colors.white.withOpacity(0.64),
                fontSize: compact ? 13 : 14,
                height: 1.4,
              ),
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copyBlock,
              const SizedBox(height: 12),
              _PillButton(
                icon: Icons.person_outline_rounded,
                label: '形象',
                onTap: onManageAvatar,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: copyBlock),
            const SizedBox(width: 12),
            _PillButton(
              icon: Icons.person_outline_rounded,
              label: '形象',
              onTap: onManageAvatar,
            ),
          ],
        );
      },
    );
  }
}

class _EmptyStage extends StatelessWidget {
  const _EmptyStage({
    required this.onCreateAvatar,
    required this.onBrowseCloset,
    required this.onStartStudio,
  });

  final VoidCallback onCreateAvatar;
  final VoidCallback onBrowseCloset;
  final VoidCallback onStartStudio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 380;
        final short = constraints.maxHeight < 760;
        final compact = narrow || short;
        final textScaler =
            MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.05);
        final heroWidth = compact ? 160.0 : 230.0;
        final heroHeight = compact ? 210.0 : 300.0;
        final heroRadius = compact ? 82.0 : 120.0;
        final iconSize = compact ? 68.0 : 98.0;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _TopBar(onManageAvatar: _noop),
                  SizedBox(height: compact ? 16 : 24),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      compact ? 16 : 24,
                      compact ? 18 : 28,
                      compact ? 16 : 24,
                      compact ? 18 : 28,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
                      border: Border.all(color: AppTheme.dividerDark),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: heroWidth,
                          height: heroHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(heroRadius),
                            gradient: AppTheme.stageBackgroundDark,
                            border: Border.all(
                              color: AppTheme.primaryLight.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: AppTheme.primaryGlow,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        AppTheme.primaryLight.withOpacity(0.22),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.person_outline_rounded,
                                size: iconSize,
                                color: AppTheme.primaryLight.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 26),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '开始你的数字展台',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontSize: compact ? 22 : 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            '先上传一张全身照，后续截图导入、试穿编辑、AI 点评都会围绕这个形象展开。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.64),
                              fontSize: compact ? 13 : 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 18 : 28),
                        _PrimaryButton(
                          label: '创建我的形象',
                          icon: Icons.add_photo_alternate_outlined,
                          onTap: onCreateAvatar,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 14 : 18),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _GhostLink(
                          label: '浏览资产',
                          icon: Icons.inventory_2_outlined,
                          onTap: onBrowseCloset,
                        ),
                        _GhostLink(
                          label: '进入创意',
                          icon: Icons.auto_awesome_rounded,
                          onTap: onStartStudio,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.avatar,
    required this.avatarCount,
    required this.tryOnCount,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final Avatar avatar;
  final int avatarCount;
  final int tryOnCount;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Eyebrow(label: 'Digital Stage'),
              const Spacer(),
              _MiniMetric(label: '形象', value: '$avatarCount'),
              const SizedBox(width: 8),
              _MiniMetric(label: '试穿', value: '$tryOnCount'),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            child: AspectRatio(
              aspectRatio: 0.9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(avatar.photoPath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.stageBackgroundDark,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 72,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.06),
                            Colors.black.withOpacity(0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            avatar.name,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '把当前形象作为试穿底图，进入创意工作室继续调服装、看效果、做决策。',
            style: TextStyle(
              color: Colors.white.withOpacity(0.64),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PrimaryButton(
                  label: '开始试穿',
                  icon: Icons.auto_awesome_rounded,
                  onTap: onPrimaryTap,
                ),
              ),
              const SizedBox(width: 12),
              _GhostButton(
                label: '管理',
                icon: Icons.tune_rounded,
                onTap: onSecondaryTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _EmptyRecentCard extends StatelessWidget {
  const _EmptyRecentCard({required this.onStartTap});

  final VoidCallback onStartTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.primaryGlow,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '还没有试穿结果',
                  style: TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '导入一张电商截图，开始第一套试穿方案。',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.64),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onStartTap,
            child: const Text('开始'),
          ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            textScaler: const TextScaler.linear(1),
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            value,
            textScaler: const TextScaler.linear(1),
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textScaler: const TextScaler.linear(1),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              textScaler: const TextScaler.linear(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: AppTheme.primaryGlow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              textScaler: const TextScaler.linear(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              textScaler: const TextScaler.linear(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GhostLink extends StatelessWidget {
  const _GhostLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white.withOpacity(0.72)),
      label: Text(
        label,
        textScaler: const TextScaler.linear(1),
        style: TextStyle(color: Colors.white.withOpacity(0.72)),
      ),
    );
  }
}

void _noop() {}
