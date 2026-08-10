import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/hub_user.dart';
import 'package:cakobean/ui/core/widgets/app_snackbar.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';
import 'package:cakobean/ui/features/profile/widgets/edit_profile_sheet.dart';
import 'package:cakobean/ui/features/profile/widgets/profile_row.dart';
import 'package:cakobean/ui/features/profile/widgets/profile_section.dart';
import 'package:cakobean/ui/features/profile/widgets/theme_mode_toggle.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _picker = ImagePicker();
  bool _uploadingAvatar = false;

  /// Latest uploaded avatar URL. Kept locally so the picture updates the
  /// instant an upload finishes, without waiting for the live profile stream
  /// (Realtime) to re-emit.
  String? _avatarUrlOverride;

  /// Forces the profile stream to re-fetch the current `users` row so the
  /// page — and anything else watching it — reflects saved changes even if
  /// the Realtime change event hasn't arrived.
  void _refreshProfile() {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid != null) ref.invalidate(hubUserProvider(uid));
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final letters = parts.where((p) => p.isNotEmpty).map((p) => p[0]).take(2);
    return letters.join().toUpperCase();
  }

  /// Opens the name/username editor, then persists the changes to the `users`
  /// table. The live profile stream reflects the update automatically.
  Future<void> _editAboutYou(HubUser profile) async {
    final result = await showEditProfileSheet(
      context,
      firstName: profile.firstName,
      middleName: profile.middleName,
      lastName: profile.lastName,
      username: profile.username ?? '',
    );
    if (result == null) return;
    try {
      await ref.read(hubRepositoryProvider).updateProfileNames(
            firstName: result.firstName,
            middleName: result.middleName,
            lastName: result.lastName,
            username: result.username,
          );
      if (mounted) {
        showAppSnackbar(
          context,
          'Profile updated.',
          kind: SnackbarKind.success,
        );
        _refreshProfile();
      }
    } on Exception catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Could not save changes: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  /// Lets the user pick a photo (camera/gallery), uploads it to Storage and
  /// updates their `users` row so the avatar reflects the new picture.
  Future<void> _changeAvatar() async {
    final source = await _showAvatarSourceSheet();
    if (source == null || !mounted) return;

    final XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
    } catch (_) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Could not open the photo picker.',
          kind: SnackbarKind.error,
        );
      }
      return;
    }
    if (picked == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final url = await ref.read(hubRepositoryProvider).updateAvatar(
            File(picked.path),
            filename: picked.name,
          );
      if (!mounted) return;
      setState(() => _avatarUrlOverride = url);
      showAppSnackbar(
        context,
        'Profile picture updated.',
        kind: SnackbarKind.success,
      );
      _refreshProfile();
    } on Exception catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Could not update picture: $e',
          kind: SnackbarKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<ImageSource?> _showAvatarSourceSheet() async {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: ext.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.x4),
            Text(
              'Profile picture',
              style: Theme.of(
                sheetContext,
              ).textTheme.headlineSmall?.copyWith(fontSize: 17),
            ),
            const SizedBox(height: AppSpacing.x2),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            const SizedBox(height: AppSpacing.x2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final user = ref.watch(authStateProvider).value;
    // No signed-in user → the router is about to bounce to /login. Render
    // nothing instead of a flash of empty names / a "farmer" placeholder.
    if (user == null) {
      return Scaffold(backgroundColor: ext.cream, body: const SizedBox());
    }
    final hubProfile = ref.watch(hubUserProvider(user.uid)).value;

    // Registered profile first (Supabase `users` table), then the auth
    // display name, then a neutral fallback — never the demo farmer.
    final nameParts = (user.displayName ?? '').trim().split(RegExp(r'\s+'));
    final firstName = hubProfile?.firstName.isNotEmpty == true
        ? hubProfile!.firstName
        : (nameParts.isNotEmpty ? nameParts.first : '');
    final middleName = hubProfile?.middleName?.isNotEmpty == true
        ? hubProfile!.middleName
        : (nameParts.length > 2 ? nameParts[1] : null);
    final lastName = hubProfile?.lastName.isNotEmpty == true
        ? hubProfile!.lastName
        : (nameParts.length > 1 ? nameParts.last : '');
    // Displayed names are "First Last" — the optional middle name is stored
    // but not shown.
    final displayName = '$firstName $lastName'.trim();
    // Prefer the stored username (set at registration / profile edit), then
    // fall back to deriving one from the email local-part.
    final username =
        hubProfile?.username?.isNotEmpty == true
            ? hubProfile!.username!
            : user.email.split('@').first;

    // Profile used for editing: backed by the `users` row when it exists,
    // otherwise derived from the auth user.
    final HubUser profile =
        hubProfile ??
        HubUser(
          uid: user.uid,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          email: user.email,
          avatarUrl: user.photoUrl,
        );

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.x6),
              // ---- Avatar (tap to change) ----
              Center(
                child: _ProfileAvatar(
                  ext: ext,
                  initials: _initialsFor(displayName),
                  imageUrl: _avatarUrlOverride ?? profile.avatarUrl,
                  hasPhoto:
                      _avatarUrlOverride != null || profile.hasPhoto,
                  uploading: _uploadingAvatar,
                  onTap: _uploadingAvatar ? null : _changeAvatar,
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  color: ext.cocoa,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@$username',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: ext.cocoa50),
              ),
              const SizedBox(height: AppSpacing.x3),
              // ---- Theme mode toggle ----
              const ThemeModeToggleButton(),
              const SizedBox(height: AppSpacing.x6),
              // ---- About You ----
              ProfileSection(
                ext: ext,
                title: 'About You',
                onEdit: () => _editAboutYou(profile),
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
                    value: (middleName == null || middleName.isEmpty)
                        ? 'Not set'
                        : middleName,
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.person_outline_rounded,
                    label: 'Last Name',
                    value: lastName.isEmpty ? 'Not set' : lastName,
                  ),
                  ProfileRow(
                    ext: ext,
                    icon: Icons.alternate_email_rounded,
                    label: 'Username',
                    value: '@$username',
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
                  },
                  child: const Text('Log Out'),
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

/// Circular avatar with a camera badge in the corner. Shows the uploaded
/// photo when the user has one, otherwise their initials. While a new photo
/// is uploading a spinner covers it.
class _ProfileAvatar extends StatelessWidget {
  final AppThemeExtension ext;
  final String initials;
  final String? imageUrl;
  final bool hasPhoto;
  final bool uploading;
  final VoidCallback? onTap;

  const _ProfileAvatar({
    required this.ext,
    required this.initials,
    this.imageUrl,
    this.hasPhoto = false,
    this.uploading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: ext.sand,
                  shape: BoxShape.circle,
                  border: Border.all(color: ext.hairline, width: 1.5),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasPhoto && imageUrl != null)
                      Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _initialsBox(),
                      )
                    else
                      _initialsBox(),
                    if (uploading)
                      ColoredBox(
                        color: Colors.black38,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.creamLight,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.ember,
                  shape: BoxShape.circle,
                  border: Border.all(color: ext.cream, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 14,
                  color: AppColors.creamLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialsBox() {
    return Container(
      alignment: Alignment.center,
      color: AppColors.ember.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: AppColors.ember,
        ),
      ),
    );
  }
}
