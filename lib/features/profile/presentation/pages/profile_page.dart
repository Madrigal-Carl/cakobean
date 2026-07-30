import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import '../../data/models/profile.dart';
import '../widgets/profile_row.dart';
import '../widgets/profile_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final profile = mockProfile;

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
                    profile.initials,
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
                profile.fullName,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: ext.cocoa),
              ),
              const SizedBox(height: 4),
              Text(
                '@${profile.username}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ext.cocoa50),
              ),
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
                    value: profile.firstName,
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.person_outline_rounded,
                    label: 'Middle Name',
                    value: profile.middleName,
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.person_outline_rounded,
                    label: 'Last Name',
                    value: profile.lastName,
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
                    value: profile.username,
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: profile.email,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x6),
              // ---- Log Out ----
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showComingSoon(context, 'Log out'),
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
