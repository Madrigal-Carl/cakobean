import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/home/view_models/home_viewmodel.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';
import 'package:cakobean/ui/features/profile/widgets/profile_row.dart';
import 'package:cakobean/ui/features/profile/widgets/profile_section.dart';
import 'package:cakobean/ui/features/profile/widgets/theme_mode_toggle.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature — coming soon')));
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.where((p) => p.isNotEmpty).map((p) => p[0]).take(2);
    return letters.join().toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final user = ref.watch(authStateProvider).value;
    final hubProfile = user == null
        ? null
        : ref.watch(hubUserProvider(user.uid)).value;

    // Registered profile first (Firestore `users` doc), then the auth
    // display name, then a neutral fallback — never the demo farmer.
    final nameParts = (user?.displayName ?? '').trim().split(RegExp(r'\s+'));
    final firstName = hubProfile?.firstName.isNotEmpty == true
        ? hubProfile!.firstName
        : (nameParts.isNotEmpty ? nameParts.first : '');
    final lastName = hubProfile?.lastName.isNotEmpty == true
        ? hubProfile!.lastName
        : (nameParts.length > 1 ? nameParts.last : '');
    final displayName = '$firstName $lastName'.trim();
    final email = user?.email;
    final username = (email == null || email.isEmpty)
        ? (firstName.isNotEmpty ? firstName.toLowerCase() : 'farmer')
        : email.split('@').first;

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.x6),
              // ---- Avatar ----
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.ember.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initialsFor(displayName),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ember,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: ext.cocoa),
              ),
              const SizedBox(height: 4),
              Text(
                '@$username',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ext.cocoa50),
              ),
              const SizedBox(height: AppSpacing.x3),
              // ---- Theme mode toggle ----
              const ThemeModeToggleButton(),
              const SizedBox(height: AppSpacing.x6),
              // ---- About You ----
              ProfileSection(
                ext: ext,
                title: 'About You',
                onEdit: () => _showComingSoon(context, 'Editing About You'),
                rows: [
                  ProfileRow(
                    ext: ext,
                    icon: Icons.person_outline_rounded,
                    label: 'First Name',
                    value: firstName.isEmpty ? 'Not set' : firstName,
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.person_outline_rounded,
                    label: 'Middle Name',
                    value: 'Not set',
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.person_outline_rounded,
                    label: 'Last Name',
                    value: lastName.isEmpty ? 'Not set' : lastName,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x5),
              // ---- Account ----
              ProfileSection(
                ext: ext,
                title: 'Account',
                onEdit: () => _showComingSoon(context, 'Editing Account'),
                rows: [
                  ProfileRow(
                    ext: ext,
                    icon: Icons.alternate_email_rounded,
                    label: 'Username',
                    value: '@$username',
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user?.email ?? 'Not set',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x6),
              // ---- Log Out ----
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signOut();
                    // Don't leak the previous account's viewing history.
                    await ref
                        .read(recentViewsProvider.notifier)
                        .clear();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.x3,
                    ),
                    side: BorderSide(color: ext.hairline),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ext.cocoa50,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x6),
            ],
          ),
        ),
      ),
    );
  }
}
