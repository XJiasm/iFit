import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/cloth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/app_theme.dart';
import '../closet/closet_screen.dart';
import '../profile/profile_screen.dart';
import '../stage/stage_screen.dart';
import '../tryon/tryon_select_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _tabs = [
    _TabConfig(
      label: '形象',
      iconOutlined: Icons.person_outline_rounded,
      iconFilled: Icons.person_rounded,
    ),
    _TabConfig(
      label: '资产',
      iconOutlined: Icons.inventory_2_outlined,
      iconFilled: Icons.inventory_2_rounded,
    ),
    _TabConfig(
      label: '创意',
      iconOutlined: Icons.auto_awesome_motion_outlined,
      iconFilled: Icons.auto_awesome_rounded,
    ),
    _TabConfig(
      label: '设置',
      iconOutlined: Icons.tune_outlined,
      iconFilled: Icons.tune_rounded,
    ),
  ];

  static const List<Widget> _screens = [
    StageScreen(),
    ClosetScreen(),
    TryOnSelectScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);
    final clothes = ref.watch(clothListProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: currentIndex,
        tabs: _tabs,
        closetBadge: clothes.isEmpty ? null : clothes.length.toString(),
        onTap: (index) =>
            ref.read(currentTabIndexProvider.notifier).state = index,
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final IconData iconOutlined;
  final IconData iconFilled;

  const _TabConfig({
    required this.label,
    required this.iconOutlined,
    required this.iconFilled,
  });
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
    this.closetBadge,
  });

  final int currentIndex;
  final List<_TabConfig> tabs;
  final String? closetBadge;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final textScaler =
        MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 92,
              decoration: BoxDecoration(
                gradient: AppTheme.glassGradient,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                ),
                boxShadow: AppTheme.navShadow,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 18,
                    right: 18,
                    top: 0,
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.20),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(tabs.length, (index) {
                      final badge = index == 1 ? closetBadge : null;
                      return _NavItem(
                        tab: tabs[index],
                        isSelected: currentIndex == index,
                        badge: badge,
                        onTap: () => onTap(index),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final _TabConfig tab;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Colors.white.withOpacity(0.42);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.06),
                      boxShadow: isSelected ? AppTheme.primaryGlow : null,
                    ),
                    child: Icon(
                      isSelected ? tab.iconFilled : tab.iconOutlined,
                      size: 17,
                      color: isSelected ? Colors.white : inactiveColor,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badge!,
                          textScaler: const TextScaler.linear(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 16,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    textScaler: const TextScaler.linear(1),
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryLight
                          : Colors.white.withOpacity(0.46),
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: isSelected ? 22 : 0,
                height: isSelected ? 4 : 0,
                decoration: BoxDecoration(
                  color: const Color(0xFF6D5CFF),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6D5CFF).withOpacity(0.4),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
