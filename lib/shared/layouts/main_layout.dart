import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/farm')) return 1;
    if (location.startsWith('/hub')) return 2;
    if (location.startsWith('/logistics')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/farm');
        break;
      case 2:
        context.go('/hub');
        break;
      case 3:
        context.go('/logistics');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final currentIndex = _locationToIndex(location);

    const items = [
      (_NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      )),
      (_NavItemData(
        icon: Icons.eco_outlined,
        activeIcon: Icons.eco,
        label: 'Farm',
      )),
      (_NavItemData(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: 'Hub',
      )),
      (_NavItemData(
        icon: Icons.local_shipping_outlined,
        activeIcon: Icons.local_shipping,
        label: 'Logistics',
      )),
      (_NavItemData(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      )),
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: ext.cream,
            border: Border(top: BorderSide(color: ext.hairline)),
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
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
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
