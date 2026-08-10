import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/media.dart';
import 'package:cakobean/ui/core/widgets/app_snackbar.dart';
import 'package:cakobean/ui/core/widgets/empty_state.dart';
import 'package:cakobean/ui/features/farm/widgets/form_field.dart';
import 'package:cakobean/ui/features/home/view_models/home_viewmodel.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';

class CreateArticlePage extends ConsumerStatefulWidget {
  const CreateArticlePage({super.key});

  @override
  ConsumerState<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends ConsumerState<CreateArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  final List<PickedMedia> _media = [];
  final Set<ArticleTag> _selectedTags = {};
  bool _picking = false;
  bool _publishing = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFromSource({
    required ImageSource source,
    required MediaType type,
  }) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final XFile? picked = type == MediaType.video
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _media.add(
          PickedMedia(path: picked.path, name: picked.name, type: type),
        ));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open the photo/video picker.');
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _showAddMediaSheet() {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    showModalBottomSheet<void>(
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
              'Add media',
              style: Theme.of(
                sheetContext,
              ).textTheme.headlineSmall?.copyWith(fontSize: 17),
            ),
            const SizedBox(height: AppSpacing.x2),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromSource(
                  source: ImageSource.camera,
                  type: MediaType.image,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromSource(
                  source: ImageSource.gallery,
                  type: MediaType.image,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Video from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickFromSource(
                  source: ImageSource.gallery,
                  type: MediaType.video,
                );
              },
            ),
            const SizedBox(height: AppSpacing.x2),
          ],
        ),
      ),
    );
  }

  Future<void> _publish() async {
    FocusScope.of(context).unfocus();
    if (_publishing) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTags.isEmpty) {
      setState(() => _error = 'Pick at least one tag so farmers can find it.');
      return;
    }

    setState(() {
      _publishing = true;
      _error = null;
    });
    try {
      await ref.read(hubRepositoryProvider).createArticle(
        title: _titleController.text,
        description: _descriptionController.text,
        tags: _selectedTags.toList(),
        media: _media,
      );
      ref.invalidate(hubArticlesProvider);
      ref.invalidate(newestArticlesProvider);
      if (mounted) {
        showAppSnackbar(
          context,
          'Article published',
          kind: SnackbarKind.success,
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Could not publish. Check your connection and storage rules, '
              'then try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final userAsync = ref.watch(hubCurrentUserProvider);
    final canAuthor = ref.watch(hubCanAuthorProvider);

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        bottom: false,
        child: userAsync.isLoading
            ? const Center(child: CircularProgressIndicator())
            : !canAuthor
            ? EmptyState(
                ext: ext,
                icon: Icons.lock_outline,
                message:
                    'Only panuluyan accounts can publish articles.\nAsk an '
                    'admin to set your role.',
                actionLabel: 'Go back',
                onAction: () => context.pop(),
              )
            : _buildForm(context),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x3,
            AppSpacing.x5,
            0,
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.x2),
                  decoration: BoxDecoration(
                    color: ext.sand,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: ext.cocoa, size: 20),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Text(
                'Create Article',
                style: textTheme.headlineSmall?.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x5,
              AppSpacing.x4,
              AppSpacing.x5,
              AppSpacing.x6,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmFieldLabel(ext: ext, text: 'Title'),
                  const SizedBox(height: AppSpacing.x1),
                  FarmFormField(
                    ext: ext,
                    controller: _titleController,
                    hint: 'e.g. Sooty pod disease alert this rainy season',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  FarmFieldLabel(ext: ext, text: 'Description'),
                  const SizedBox(height: AppSpacing.x1),
                  FarmFormField(
                    ext: ext,
                    controller: _descriptionController,
                    hint: 'Share the details — what farmers should know...',
                    maxLines: 5,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  FarmFieldLabel(ext: ext, text: 'Tags'),
                  const SizedBox(height: AppSpacing.x2),
                  _TagSelector(
                    ext: ext,
                    selected: _selectedTags,
                    onToggle: (tag) => setState(() {
                      _selectedTags.contains(tag)
                          ? _selectedTags.remove(tag)
                          : _selectedTags.add(tag);
                    }),
                  ),
                  const SizedBox(height: AppSpacing.x4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FarmFieldLabel(
                        ext: ext,
                        text: _media.isEmpty
                            ? 'Photos & videos'
                            : 'Photos & videos (${_media.length})',
                      ),
                      TextButton.icon(
                        onPressed: _picking || _publishing
                            ? null
                            : _showAddMediaSheet,
                        icon: const Icon(Icons.add_photo_alternate_outlined,
                            size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  if (_media.isEmpty)
                    _EmptyMediaTile(
                      ext: ext,
                      enabled: !_picking && !_publishing,
                      onPickImage: () => _pickFromSource(
                        source: ImageSource.camera,
                        type: MediaType.image,
                      ),
                      onPickGallery: () => _pickFromSource(
                        source: ImageSource.gallery,
                        type: MediaType.image,
                      ),
                      onPickVideo: () => _pickFromSource(
                        source: ImageSource.gallery,
                        type: MediaType.video,
                      ),
                    )
                  else
                    _MediaGrid(
                      ext: ext,
                      items: _media,
                      onAdd: _picking || _publishing
                          ? null
                          : _showAddMediaSheet,
                      onRemove: _publishing
                          ? null
                          : (index) =>
                              setState(() => _media.removeAt(index)),
                    ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.x3),
                    _PublishErrorBanner(message: _error!),
                  ],
                  const SizedBox(height: AppSpacing.x5),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _publishing ? null : _publish,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.x3,
                        ),
                      ),
                      child: _publishing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.creamLight,
                              ),
                            )
                          : const Text('Publish'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Selectable tag pills matching the theme's tag-chip visual language.
class _TagSelector extends StatelessWidget {
  final AppThemeExtension ext;
  final Set<ArticleTag> selected;
  final ValueChanged<ArticleTag> onToggle;

  const _TagSelector({
    required this.ext,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.x2,
      runSpacing: AppSpacing.x2,
      children: [
        for (final tag in ArticleTag.values)
          InkWell(
            onTap: () => onToggle(tag),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x2,
              ),
              decoration: BoxDecoration(
                color: selected.contains(tag) ? ext.sand : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: selected.contains(tag) ? ext.ember : ext.hairline,
                  width: 1.4,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tag.icon,
                    size: 16,
                    color: selected.contains(tag) ? ext.ember : ext.cocoa50,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tag.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selected.contains(tag) ? ext.cocoa : ext.cocoa50,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Dashed-style empty state prompting the author to add their first media,
/// with one-tap quick actions for camera/gallery/video.
class _EmptyMediaTile extends StatelessWidget {
  final AppThemeExtension ext;
  final bool enabled;
  final VoidCallback onPickImage;
  final VoidCallback onPickGallery;
  final VoidCallback onPickVideo;

  const _EmptyMediaTile({
    required this.ext,
    this.enabled = true,
    required this.onPickImage,
    required this.onPickGallery,
    required this.onPickVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x5,
      ),
      decoration: BoxDecoration(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: ext.hairline),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ext.cardSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 24,
              color: ext.cocoa50,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'Add photos or videos of the crop condition',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: ext.cocoa50),
          ),
          const SizedBox(height: AppSpacing.x4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              _QuickMediaAction(
                ext: ext,
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onTap: enabled ? onPickImage : null,
              ),
              _QuickMediaAction(
                ext: ext,
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: enabled ? onPickGallery : null,
              ),
              _QuickMediaAction(
                ext: ext,
                icon: Icons.videocam_outlined,
                label: 'Video',
                onTap: enabled ? onPickVideo : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small bordered action chip used inside the media empty state.
class _QuickMediaAction extends StatelessWidget {
  final AppThemeExtension ext;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickMediaAction({
    required this.ext,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: ext.cardSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: ext.hairline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: ext.ember),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ext.cocoa,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail grid of picked media with a trailing "add more" tile. Videos show
/// a play badge since a video can't be thumbnailed without decoding its first
/// frame.
class _MediaGrid extends StatelessWidget {
  final AppThemeExtension ext;
  final List<PickedMedia> items;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemove;

  const _MediaGrid({
    required this.ext,
    required this.items,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.x2,
      crossAxisSpacing: AppSpacing.x2,
      childAspectRatio: 1,
      children: [
        for (var i = 0; i < items.length; i++)
          Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: items[i].type == MediaType.image
                    ? Image.file(File(items[i].path), fit: BoxFit.cover)
                    : Container(
                        color: ext.cocoa,
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          size: 36,
                          color: ext.cream,
                        ),
                      ),
              ),
              if (onRemove != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => onRemove!(i),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        if (onAdd != null)
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              decoration: BoxDecoration(
                color: ext.sand,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: ext.hairline),
              ),
              child: Icon(Icons.add_rounded, size: 28, color: ext.cocoa50),
            ),
          ),
      ],
    );
  }
}

class _PublishErrorBanner extends StatelessWidget {
  final String message;

  const _PublishErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: AppSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: ext.cocoa, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
