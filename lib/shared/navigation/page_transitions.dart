import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// A [Page] that fades and slides its [child] in while gently dimming the
/// page beneath it. Used on every route so all screen changes (tab switches,
/// detail pushes, login -> home) feel intentional instead of snapping.
///
/// This Flutter version removed `CustomTransitionPage` from the framework, so
/// this is a small `Page` subclass that builds a [PageRouteBuilder] with the
/// transition we want — the same pattern the old framework widget used.
class FadeSlidePage<T> extends Page<T> {
  const FadeSlidePage({
    required this.child,
    this.beginOffset = const Offset(0, 0.04),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;
  final Offset beginOffset;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      transitionDuration: AppMotion.base,
      reverseTransitionDuration: AppMotion.fast,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final incoming = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final beneath = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: beneath.drive(Tween(begin: 1.0, end: 0.88)),
          child: FadeTransition(
            opacity: incoming,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(incoming),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
