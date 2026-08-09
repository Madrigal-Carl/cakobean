import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';

/// Gradient hero header with a wave-shaped bottom edge.
/// Used only on [HomePage].
class HomeHeader extends ConsumerWidget {
  final AppThemeExtension ext;
  const HomeHeader({super.key, required this.ext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final authUser = ref.watch(authStateProvider).value;
    final hubProfile = authUser == null
        ? null
        : ref.watch(hubUserProvider(authUser.uid)).value;

    // Registered profile first (Supabase `users` table), then the auth display
    // name, then a neutral fallback.
    final firstName = (hubProfile?.firstName ?? '').trim();
    final displayParts = (authUser?.displayName ?? '')
        .trim()
        .split(RegExp(r'\s+'));
    final greetingName = firstName.isNotEmpty
        ? firstName
        : (displayParts.isNotEmpty ? displayParts.first : 'Farmer');

    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x5,
          AppSpacing.x5,
          AppSpacing.x5,
          AppSpacing.x7,
        ),
        decoration: BoxDecoration(gradient: ext.primaryGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome,',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSpacing.x1),
            Text(
              greetingName,
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Wednesday, July 29',
              style: AppTypography.number(
                Colors.white.withValues(alpha: 0.9),
              ).copyWith(fontSize: 13, letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 26.0;
    final baseline = size.height - waveHeight;

    path.lineTo(0, baseline);

    // First half: gentle dip downward
    path.cubicTo(
      size.width * 0.22,
      baseline + waveHeight,
      size.width * 0.32,
      baseline + waveHeight,
      size.width * 0.5,
      baseline + waveHeight * 0.55,
    );

    // Second half: rise back up, flatter near the edge
    path.cubicTo(
      size.width * 0.68,
      baseline,
      size.width * 0.80,
      baseline - waveHeight * 0.3,
      size.width,
      baseline - waveHeight * 0.15,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
