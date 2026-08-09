import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  int _locationToIndex(String location) {
    final index = _navItems.indexWhere(
      (item) => location.startsWith(item.path),
    );
    return index == -1 ? 0 : index;
  }

  void _onTap(BuildContext context, int index) {
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: ext.cream,
            border: Border(top: BorderSide(color: ext.hairline)),
          ),
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final selected = i == currentIndex;
              final item = _navItems[i];
              return Expanded(
                child: InkWell(
                  onTap: () => _onTap(context, i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: AppMotion.fast,
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          key: ValueKey(selected),
                          color: selected ? AppColors.ember : ext.cocoa50,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? AppColors.ember : ext.cocoa50,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}

const _navItems = [
  _NavItemData(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
    path: '/home',
  ),
  _NavItemData(
    icon: Icons.eco_outlined,
    activeIcon: Icons.eco,
    label: 'Farm',
    path: '/farm',
  ),
  _NavItemData(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book,
    label: 'Hub',
    path: '/hub',
  ),
  _NavItemData(
    icon: Icons.local_shipping_outlined,
    activeIcon: Icons.local_shipping,
    label: 'Logistics',
    path: '/logistics',
  ),
  _NavItemData(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
    path: '/profile',
  ),
];
