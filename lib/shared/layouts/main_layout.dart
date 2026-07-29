import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      body: child,
      bottomNavigationBar: CurvedNavigationBar(
        index: _locationToIndex(location),
        onTap: (index) => _onTap(context, index),
        items: const [
          Icon(Icons.home, size: 28),
          Icon(Icons.agriculture, size: 28),
          Icon(Icons.hub, size: 28),
          Icon(Icons.local_shipping, size: 28),
          Icon(Icons.person, size: 28),
        ],
      ),
    );
  }
}
