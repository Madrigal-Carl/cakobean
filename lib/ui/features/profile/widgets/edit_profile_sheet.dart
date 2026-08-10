import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/ui/features/farm/widgets/form_field.dart';

/// Result handed back to the caller when the user saves the name form.
class ProfileNamesResult {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String username;

  const ProfileNamesResult({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.username,
  });
}

/// Bottom-sheet form for editing the "About You" profile fields
/// (first/middle/last name, username). Shown via [showEditProfileSheet].
/// The middle name is optional; first, last and username are required.
class EditProfileSheet extends StatefulWidget {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String username;

  const EditProfileSheet({
    super.key,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.username,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _middleNameController = TextEditingController(text: widget.middleName ?? '');
    _lastNameController = TextEditingController(text: widget.lastName);
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ProfileNamesResult(
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty
            ? null
            : _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: Container(
          decoration: BoxDecoration(
            color: ext.cream,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x3,
                AppSpacing.x5,
                AppSpacing.x5,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.x4),
                        decoration: BoxDecoration(
                          color: ext.hairline,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ext.sand,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.badge_outlined,
                            color: AppColors.ember,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.x3),
                        Text(
                          'Edit profile',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: ext.cocoa),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    FarmFieldLabel(ext: ext, text: 'First name'),
                    const SizedBox(height: AppSpacing.x1),
                    FarmFormField(
                      ext: ext,
                      controller: _firstNameController,
                      hint: 'e.g. Maria',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    FarmFieldLabel(ext: ext, text: 'Middle name'),
                    const SizedBox(height: AppSpacing.x1),
                    FarmFormField(
                      ext: ext,
                      controller: _middleNameController,
                      hint: 'Optional',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    FarmFieldLabel(ext: ext, text: 'Last name'),
                    const SizedBox(height: AppSpacing.x1),
                    FarmFormField(
                      ext: ext,
                      controller: _lastNameController,
                      hint: 'e.g. Santos',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    FarmFieldLabel(ext: ext, text: 'Username'),
                    const SizedBox(height: AppSpacing.x1),
                    FarmFormField(
                      ext: ext,
                      controller: _usernameController,
                      hint: 'e.g. maria_santos',
                      prefixIcon: Icons.alternate_email_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.x5),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience opener. Pass the current names to pre-fill the form.
Future<ProfileNamesResult?> showEditProfileSheet(
  BuildContext context, {
  required String firstName,
  String? middleName,
  required String lastName,
  required String username,
}) {
  return showModalBottomSheet<ProfileNamesResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EditProfileSheet(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      username: username,
    ),
  );
}
