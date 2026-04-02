import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/avatar.dart';
import '../../models/cloth_item.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/cloth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/app_theme.dart';
import 'tryon_editor_screen.dart';

final selectedClothProvider = StateProvider<ClothItem?>((ref) => null);

class TryOnSelectScreen extends ConsumerStatefulWidget {
  const TryOnSelectScreen({super.key});

  @override
  ConsumerState<TryOnSelectScreen> createState() => _TryOnSelectScreenState();
}

class _TryOnSelectScreenState extends ConsumerState<TryOnSelectScreen> {
  ClothType _selectedType = ClothType.top;
  double _previewScale = 1.0;
  double _previewRotation = 0.0;
  double _previewOpacity = 1.0;

  @override
  Widget build(BuildContext context) {
    final avatars = ref.watch(avatarListProvider);
    final clothes = ref.watch(clothListProvider);
    final selectedAvatar =
        ref.watch(selectedAvatarProvider) ?? _firstOrNull(avatars);
    final selectedCloth = ref.watch(selectedClothProvider) ??
        _firstOrNull(
            clothes.where((item) => item.type == _selectedType).toList());

    final typeClothes = clothes
        .where((item) => item.type == _selectedType)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                  child: _StudioHeader(
                    onMagicTap: _showAiHint,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: _PreviewCanvas(
                    avatar: selectedAvatar,
                    cloth: selectedCloth,
                    scale: _previewScale,
                    rotation: _previewRotation,
                    opacity: _previewOpacity,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _StudioSummary(
                    avatar: selectedAvatar,
                    cloth: selectedCloth,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionTitle(
                    title: '选择形象',
                    subtitle: '先确定试穿底图，后续编辑围绕当前形象展开',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 112,
                  child: avatars.isEmpty
                      ? _MissingCard(
                          icon: Icons.person_add_alt_1_outlined,
                          title: '还没有形象',
                          actionLabel: '去创建',
                          onTap: () => ref
                              .read(currentTabIndexProvider.notifier)
                              .state = 0,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final avatar = avatars[index];
                            final isSelected = avatar.id == selectedAvatar?.id;
                            return _AvatarChipCard(
                              avatar: avatar,
                              isSelected: isSelected,
                              onTap: () {
                                ref
                                    .read(selectedAvatarProvider.notifier)
                                    .state = avatar;
                              },
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemCount: avatars.length,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionTitle(
                    title: '选择单品',
                    subtitle: '按分类切换素材，把电商截图转成可编辑图层',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final type = _studioTypes[index];
                      final count =
                          clothes.where((item) => item.type == type).length;
                      return _TypeChip(
                        label: _typeName(type),
                        count: count,
                        isSelected: _selectedType == type,
                        onTap: () {
                          setState(() {
                            _selectedType = type;
                          });
                          final filtered = clothes
                              .where((item) => item.type == type)
                              .toList()
                            ..sort(
                                (a, b) => b.createdAt.compareTo(a.createdAt));
                          ref.read(selectedClothProvider.notifier).state =
                              filtered.isEmpty ? null : filtered.first;
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: _studioTypes.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 156,
                  child: typeClothes.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: _MissingCard(
                            icon: Icons.add_photo_alternate_outlined,
                            title: '当前分类还没有素材',
                            actionLabel: '去资产页导入',
                            onTap: () => ref
                                .read(currentTabIndexProvider.notifier)
                                .state = 1,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final cloth = typeClothes[index];
                            final isSelected = cloth.id == selectedCloth?.id;
                            return _ClothChipCard(
                              item: cloth,
                              isSelected: isSelected,
                              onTap: () {
                                ref.read(selectedClothProvider.notifier).state =
                                    cloth;
                              },
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemCount: typeClothes.length,
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionTitle(
                    title: '预调参数',
                    subtitle: '先做一次快速预览，进入编辑器后再细调',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      _ControlCard(
                        label: '缩放',
                        value: _previewScale,
                        min: 0.6,
                        max: 1.8,
                        valueText: '${(_previewScale * 100).round()}%',
                        onChanged: (value) =>
                            setState(() => _previewScale = value),
                      ),
                      const SizedBox(height: 12),
                      _ControlCard(
                        label: '旋转',
                        value: _previewRotation,
                        min: -0.8,
                        max: 0.8,
                        valueText: '${(_previewRotation * 57.3).round()}°',
                        onChanged: (value) =>
                            setState(() => _previewRotation = value),
                      ),
                      const SizedBox(height: 12),
                      _ControlCard(
                        label: '透明度',
                        value: _previewOpacity,
                        min: 0.2,
                        max: 1.0,
                        valueText: '${(_previewOpacity * 100).round()}%',
                        onChanged: (value) =>
                            setState(() => _previewOpacity = value),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    AppTheme.bottomNavHeight + 20,
                  ),
                  child: _StudioActions(
                    canStart: selectedAvatar != null && selectedCloth != null,
                    onPrimaryTap: () {
                      if (selectedAvatar == null || selectedCloth == null) {
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TryOnEditorScreen(
                            avatar: selectedAvatar,
                            clothItem: selectedCloth,
                            initialScale: _previewScale,
                            initialRotation: _previewRotation,
                            initialOpacity: _previewOpacity,
                          ),
                        ),
                      );
                    },
                    onSecondaryTap: () =>
                        ref.read(currentTabIndexProvider.notifier).state = 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAiHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('下一步会把 AI 点评接到试穿结果页，当前先完成画布和编辑流程。'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

const _studioTypes = [
  ClothType.top,
  ClothType.pants,
  ClothType.skirt,
  ClothType.dress,
  ClothType.shoes,
  ClothType.accessory,
];

T? _firstOrNull<T>(List<T> values) => values.isEmpty ? null : values.first;

String _typeName(ClothType type) => switch (type) {
      ClothType.top => '上衣',
      ClothType.pants => '下装',
      ClothType.skirt => '裙子',
      ClothType.dress => '连衣裙',
      ClothType.jacket => '外套',
      ClothType.shoes => '鞋履',
      ClothType.bag => '包袋',
      ClothType.accessory => '配饰',
    };

class _StudioHeader extends StatelessWidget {
  const _StudioHeader({required this.onMagicTap});

  final VoidCallback onMagicTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '创意工作室',
                style: TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '在同一张画布里完成素材选择、快速预览和进入编辑器。',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.64),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onMagicTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: AppTheme.primaryGlow,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewCanvas extends StatelessWidget {
  const _PreviewCanvas({
    required this.avatar,
    required this.cloth,
    required this.scale,
    required this.rotation,
    required this.opacity,
  });

  final Avatar? avatar;
  final ClothItem? cloth;
  final double scale;
  final double rotation;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 440,
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.stageBackgroundDark,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.95,
                    colors: [
                      AppTheme.primaryLight.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            if (avatar != null)
              Center(
                child: Image.file(
                  File(avatar!.photoPath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person_outline_rounded,
                    size: 84,
                    color: AppTheme.primaryLight,
                  ),
                ),
              )
            else
              const Center(
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 84,
                  color: AppTheme.primaryLight,
                ),
              ),
            if (cloth != null)
              Center(
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: SizedBox(
                        width: 180,
                        height: 240,
                        child: Image.file(
                          File(cloth!.croppedPath),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLg),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.10),
                              ),
                            ),
                            child: const Icon(
                              Icons.checkroom_rounded,
                              color: Colors.white38,
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.32),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AppTheme.primaryLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cloth == null
                            ? '先选择一个单品，把素材送进画布。'
                            : '预览已更新，继续微调后进入编辑器。',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioSummary extends StatelessWidget {
  const _StudioSummary({
    required this.avatar,
    required this.cloth,
  });

  final Avatar? avatar;
  final ClothItem? cloth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: '当前形象',
            value: avatar?.name ?? '未选择',
            icon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: '当前图层',
            value: cloth?.typeName ?? '未选择',
            icon: Icons.checkroom_outlined,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _SummaryCard(
            label: '下一步',
            value: '进入编辑器',
            icon: Icons.arrow_forward_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryLight, size: 18),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
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

class _AvatarChipCard extends StatelessWidget {
  const _AvatarChipCard({
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  final Avatar avatar;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Ink(
        width: 82,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.cardBackgroundDark
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: isSelected ? AppTheme.primaryGlow : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Image.file(
                  File(avatar.photoPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.surfaceDark,
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              avatar.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.64),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClothChipCard extends StatelessWidget {
  const _ClothChipCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final ClothItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Ink(
        width: 104,
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryLight
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: isSelected ? AppTheme.primaryGlow : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFE6E8EE),
                    child: item.croppedPath.isEmpty
                        ? const Icon(Icons.checkroom_rounded,
                            color: Colors.black26)
                        : Image.file(
                            File(item.croppedPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.checkroom_rounded,
                              color: Colors.black26,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.typeName,
                style: const TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.color.isEmpty ? '未标记颜色' : item.color,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.52),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: isSelected ? AppTheme.primaryGlow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.42),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.valueText,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String valueText;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.dividerDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                valueText,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.56),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryLight,
              inactiveTrackColor: Colors.white.withOpacity(0.10),
              thumbColor: AppTheme.primaryLight,
              overlayColor: AppTheme.primaryLight.withOpacity(0.20),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioActions extends StatelessWidget {
  const _StudioActions({
    required this.canStart,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  final bool canStart;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: canStart ? onPrimaryTap : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Ink(
            height: 58,
            decoration: BoxDecoration(
              gradient: canStart ? AppTheme.primaryGradient : null,
              color: canStart ? null : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: canStart ? AppTheme.primaryGlow : null,
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_fix_high_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    '进入编辑器',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onSecondaryTap,
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('先去资产页继续导入素材'),
        ),
      ],
    );
  }
}

class _MissingCard extends StatelessWidget {
  const _MissingCard({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      child: Ink(
        decoration: BoxDecoration(
          color: AppTheme.cardBackgroundDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.dividerDark),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppTheme.primaryLight),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onTap, child: Text(actionLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
