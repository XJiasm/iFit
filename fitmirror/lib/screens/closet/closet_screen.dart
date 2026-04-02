import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/cloth_item.dart';
import '../../providers/cloth_provider.dart';
import '../../utils/app_theme.dart';
import 'cloth_crop_screen.dart';

class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  ClothType? _selectedType;
  String _query = '';

  static const List<ClothType> _types = [
    ClothType.top,
    ClothType.pants,
    ClothType.skirt,
    ClothType.dress,
    ClothType.jacket,
    ClothType.shoes,
    ClothType.bag,
    ClothType.accessory,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clothes = ref.watch(clothListProvider);
    final filtered = clothes.where(_matchesFilter).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final wishlistCount =
        clothes.where((item) => item.status == ClothStatus.wishlist).length;
    final purchasedCount =
        clothes.where((item) => item.status == ClothStatus.purchased).length;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundDark,
      floatingActionButton: _ImportButton(onTap: _importCloth),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _ClosetHeader(totalCount: clothes.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _SearchBar(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: '总资产',
                          value: '${clothes.length}',
                          hint: '已存入数字衣橱',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: '种草中',
                          value: '$wishlistCount',
                          hint: '待决策单品',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: '已购买',
                          value: '$purchasedCount',
                          hint: '确认入手',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: _SectionHeader(
                    title: '分类筛选',
                    subtitle: '把衣橱管理成可复用的数字资产库',
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
                      final type = _types[index];
                      final isSelected = _selectedType == type;
                      final typeCount =
                          clothes.where((item) => item.type == type).length;
                      return _TypeChip(
                        label: _typeName(type),
                        count: typeCount,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedType = isSelected ? null : type;
                          });
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: _types.length,
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyClosetState(
                    hasAnyClothes: clothes.isNotEmpty,
                    onImportTap: _importCloth,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    AppTheme.bottomNavHeight + 20,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _ClosetItemCard(
                        item: filtered[index],
                        onMore: () => _showClothOptions(filtered[index]),
                      ),
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matchesFilter(ClothItem item) {
    final matchesType = _selectedType == null || item.type == _selectedType;
    if (!matchesType) {
      return false;
    }
    if (_query.trim().isEmpty) {
      return true;
    }
    final keyword = _query.trim().toLowerCase();
    return item.typeName.toLowerCase().contains(keyword) ||
        item.color.toLowerCase().contains(keyword) ||
        item.styleTags.any((tag) => tag.toLowerCase().contains(keyword)) ||
        (item.sourcePlatform ?? '').toLowerCase().contains(keyword);
  }

  Future<void> _importCloth() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (image == null || !mounted) {
      return;
    }

    final result = await Navigator.push<ClothItem>(
      context,
      MaterialPageRoute(
        builder: (_) => ClothCropScreen(
          imagePath: image.path,
          initialType: _selectedType ?? ClothType.top,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    await ref.read(clothListProvider.notifier).addClothItem(
          type: result.type,
          originalPath: result.originalPath,
          croppedPath: result.croppedPath,
          productUrl: result.productUrl,
          sourcePlatform: result.sourcePlatform,
          color: result.color,
          styleTags: result.styleTags,
        );

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('服装已加入数字资产库'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteCloth(ClothItem item) async {
    await ref.read(clothListProvider.notifier).deleteClothItem(item.id);
  }

  void _showClothOptions(ClothItem item) {
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
                  _StatusActionTile(
                    label: '标记为种草中',
                    icon: Icons.favorite_border_rounded,
                    isSelected: item.status == ClothStatus.wishlist,
                    onTap: () async {
                      item.status = ClothStatus.wishlist;
                      await ref
                          .read(clothListProvider.notifier)
                          .updateClothItem(item);
                      if (mounted) Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 10),
                  _StatusActionTile(
                    label: '标记为已购买',
                    icon: Icons.check_circle_outline_rounded,
                    isSelected: item.status == ClothStatus.purchased,
                    onTap: () async {
                      item.status = ClothStatus.purchased;
                      await ref
                          .read(clothListProvider.notifier)
                          .updateClothItem(item);
                      if (mounted) Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 10),
                  _StatusActionTile(
                    label: '标记为已淘汰',
                    icon: Icons.remove_circle_outline_rounded,
                    isSelected: item.status == ClothStatus.discarded,
                    onTap: () async {
                      item.status = ClothStatus.discarded;
                      await ref
                          .read(clothListProvider.notifier)
                          .updateClothItem(item);
                      if (mounted) Navigator.pop(sheetContext);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    tileColor: AppTheme.errorColor.withOpacity(0.10),
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppTheme.errorColor,
                    ),
                    title: const Text(
                      '删除单品',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _deleteCloth(item);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _typeName(ClothType type) => switch (type) {
        ClothType.top => '上衣',
        ClothType.pants => '裤子',
        ClothType.skirt => '裙子',
        ClothType.dress => '连衣裙',
        ClothType.jacket => '外套',
        ClothType.shoes => '鞋履',
        ClothType.bag => '包袋',
        ClothType.accessory => '配饰',
      };
}

class _ClosetHeader extends StatelessWidget {
  const _ClosetHeader({required this.totalCount});

  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '数字资产库',
          style: TextStyle(
            color: AppTheme.textPrimaryDark,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '当前已收录 $totalCount 件可复用单品，方便后续试穿、搭配和 AI 点评。',
          style: TextStyle(
            color: Colors.white.withOpacity(0.64),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: '搜索颜色、风格、来源平台',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.textHintDark,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

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
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.56),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(
              color: Colors.white.withOpacity(0.48),
              fontSize: 11,
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

class _EmptyClosetState extends StatelessWidget {
  const _EmptyClosetState({
    required this.hasAnyClothes,
    required this.onImportTap,
  });

  final bool hasAnyClothes;
  final VoidCallback onImportTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.goldColor.withOpacity(0.10),
                border: Border.all(
                  color: AppTheme.goldColor.withOpacity(0.20),
                ),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 46,
                color: AppTheme.goldColor,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              hasAnyClothes ? '这个分类还没有资产' : '你的数字衣橱还是空的',
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasAnyClothes ? '换个分类试试，或者继续导入新的电商截图。' : '先从一张商品截图开始，把衣橱搭起来。',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onImportTap,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('导入服装'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClosetItemCard extends StatelessWidget {
  const _ClosetItemCard({
    required this.item,
    required this.onMore,
  });

  final ClothItem item;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onMore();
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.cardBackgroundDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppTheme.dividerDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusXl),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFE4E7EE),
                        child: item.croppedPath.isEmpty
                            ? const _ImagePlaceholder()
                            : Image.file(
                                File(item.croppedPath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _ImagePlaceholder(),
                              ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _StatusBadge(status: item.status),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: InkWell(
                        onTap: onMore,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.36),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            item.typeName,
                            style: const TextStyle(
                              color: AppTheme.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.color.isEmpty ? '未标记' : item.color,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.48),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.styleTags.isEmpty
                          ? '等待补充风格标签'
                          : item.styleTags.take(2).join(' · '),
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.sourcePlatform?.isNotEmpty == true
                          ? item.sourcePlatform!
                          : '本地导入',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.52),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ClothStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ClothStatus.purchased => (AppTheme.successColor, '已购买'),
      ClothStatus.wishlist => (AppTheme.goldColor, '种草中'),
      ClothStatus.discarded => (AppTheme.textHintDark, '已淘汰'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF313748),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white24,
          size: 38,
        ),
      ),
    );
  }
}

class _StatusActionTile extends StatelessWidget {
  const _StatusActionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      tileColor: isSelected
          ? AppTheme.primaryColor.withOpacity(0.14)
          : Colors.white.withOpacity(0.04),
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryLight : AppTheme.textSecondaryDark,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? AppTheme.textPrimaryDark
              : AppTheme.textSecondaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppTheme.primaryLight)
          : null,
      onTap: onTap,
    );
  }
}

class _ImportButton extends StatelessWidget {
  const _ImportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: AppTheme.primaryGlow,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text(
                '导入服装',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
