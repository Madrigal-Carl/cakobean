import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/comment.dart';
import 'package:cakobean/domain/models/media.dart';
import 'package:cakobean/ui/core/widgets/stat_chip.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/home/view_models/home_viewmodel.dart';
import 'package:cakobean/ui/features/hub/view_models/hub_viewmodel.dart';

const _guestAvatarUrl = 'https://i.pravatar.cc/100?img=68';

class ArticleDetail extends ConsumerStatefulWidget {
  final String articleId;
  final ArticleModel? article; // passed via go_router `extra` when available

  const ArticleDetail({super.key, required this.articleId, this.article});

  @override
  ConsumerState<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends ConsumerState<ArticleDetail> {
  final _commentController = TextEditingController();
  final _mediaPageController = PageController();
  int _mediaIndex = 0;
  bool _likeBusy = false;
  bool _commentBusy = false;

  @override
  void initState() {
    super.initState();
    // Record this as "recently viewed" on the home screen.
    ref.read(recentViewsProvider.notifier).record(widget.articleId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _mediaPageController.dispose();
    super.dispose();
  }

  Future<void> _toggleReaction() async {
    if (_likeBusy) return;
    setState(() => _likeBusy = true);
    try {
      await ref.read(hubRepositoryProvider).toggleLike(widget.articleId);
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _commentBusy) return;
    setState(() => _commentBusy = true);
    try {
      await ref.read(hubRepositoryProvider).addComment(
        articleId: widget.articleId,
        text: text,
      );
      _commentController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _commentBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    final articleAsync = ref.watch(hubArticleProvider(widget.articleId));
    final commentsAsync = ref.watch(hubCommentsProvider(widget.articleId));
    final likedAsync = ref.watch(hubLikedProvider(widget.articleId));
    final likeCount =
        ref.watch(hubLikeCountProvider(widget.articleId)).value ?? 0;
    final commentCount =
        ref.watch(hubCommentCountProvider(widget.articleId)).value ?? 0;
    final authUser = ref.watch(authStateProvider).value;

    final article = articleAsync.value ?? widget.article;
    if (article == null && articleAsync.isLoading) {
      return Scaffold(
        backgroundColor: ext.cream,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (article == null) {
      return Scaffold(
        backgroundColor: ext.cream,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.article_outlined, size: 48, color: ext.cocoa50),
                const SizedBox(height: AppSpacing.x3),
                const Text('This article is no longer available.'),
                const SizedBox(height: AppSpacing.x4),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final comments = commentsAsync.value ?? const <CommentModel>[];
    final authorId = article.authorId;
    final author = authorId == null
        ? null
        : ref.watch(hubUserProvider(authorId)).value;
    final liked = likedAsync.value ?? false;
    final media = article.displayMedia;
    final fallbackIcon = article.tags.isEmpty
        ? Icons.article_outlined
        : article.tags.first.icon;

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
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
                        child: Icon(
                          Icons.arrow_back,
                          color: ext.cocoa,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x5,
                  AppSpacing.x4,
                  AppSpacing.x5,
                  0,
                ),
                child: _MediaCarousel(
                  ext: ext,
                  urls: media,
                  heroTag: 'article-thumb-${article.id}',
                  pageController: _mediaPageController,
                  currentIndex: _mediaIndex,
                  onPageChanged: (i) => setState(() => _mediaIndex = i),
                  fallbackIcon: fallbackIcon,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x5,
                  AppSpacing.x4,
                  AppSpacing.x5,
                  AppSpacing.x5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.x1,
                      runSpacing: AppSpacing.x1,
                      children: [
                        for (final tag in article.tags)
                          StatChip(ext: ext, icon: tag.icon, label: tag.label),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Text(
                      article.title,
                      style: textTheme.headlineSmall?.copyWith(
                        color: ext.cocoa,
                      ),
                    ),
                    if (author != null) ...[
                      const SizedBox(height: AppSpacing.x1),
                      Row(
                        children: [
                          Text(
                            author.fullName,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: ext.cocoa50,
                            ),
                          ),
                          if (article.createdAt != null) ...[
                            const SizedBox(width: AppSpacing.x1),
                            Text(
                              '·',
                              style: TextStyle(color: ext.cocoa50),
                            ),
                            const SizedBox(width: AppSpacing.x1),
                            Text(
                              timeAgo(article.createdAt!),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: ext.cocoa50,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.x3),
                    Row(
                      children: [
                        _ReactButton(
                          ext: ext,
                          reacted: liked,
                          count: likeCount,
                          onTap: _toggleReaction,
                        ),
                        const SizedBox(width: AppSpacing.x4),
                        Icon(
                          Icons.mode_comment_outlined,
                          size: 18,
                          color: ext.cocoa50,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$commentCount',
                          style: TextStyle(color: ext.cocoa50, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      article.description,
                      style: textTheme.bodyLarge?.copyWith(color: ext.cocoa),
                    ),
                    const SizedBox(height: AppSpacing.x5),
                    Divider(color: ext.hairline, height: 1),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x5,
                  AppSpacing.x4,
                  AppSpacing.x5,
                  AppSpacing.x2,
                ),
                child: Text(
                  'Comments ($commentCount)',
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 17,
                    color: ext.cocoa,
                  ),
                ),
              ),
            ),
            if (comments.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x5,
                    vertical: AppSpacing.x4,
                  ),
                  child: Text(
                    'No comments yet — be the first to share your thoughts.',
                    style: TextStyle(color: ext.cocoa50, fontSize: 13.5),
                  ),
                ),
              )
            else
              SliverList.separated(
                itemCount: comments.length,
                separatorBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x5,
                  ),
                  child: Divider(color: ext.hairline, height: AppSpacing.x5),
                ),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x5,
                  ),
                  child: _CommentTile(ext: ext, comment: comments[i]),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x6)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _CommentComposer(
          ext: ext,
          controller: _commentController,
          busy: _commentBusy,
          avatarUrl: authUser?.photoUrl ?? _guestAvatarUrl,
          onSubmit: _submitComment,
        ),
      ),
    );
  }
}

/// Swipeable media gallery with a dot indicator. Slides can be images or
/// videos (detected by file extension); videos get an inline player with a
/// play/pause toggle. Falls back to a tinted icon tile if loading fails.
class _MediaCarousel extends StatelessWidget {
  final AppThemeExtension ext;
  final List<String> urls;
  final String? heroTag;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final IconData fallbackIcon;

  const _MediaCarousel({
    required this.ext,
    required this.urls,
    this.heroTag,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: pageController,
              itemCount: urls.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) {
                final url = urls[i];
                final isVideo = mediaTypeForUrl(url) == MediaType.video;
                final Widget media = isVideo
                    ? _VideoMedia(
                        ext: ext,
                        url: url,
                        fallbackIcon: fallbackIcon,
                      )
                    : _ImageMedia(
                        ext: ext,
                        url: url,
                        fallbackIcon: fallbackIcon,
                      );
                // Hero only on the first slide so the tag stays unique —
                // a PageView can build sibling pages while swiping. Videos
                // don't participate in hero transitions.
                if (heroTag == null || i != 0 || isVideo) return media;
                return Hero(tag: heroTag!, child: media);
              },
            ),
          ),
        ),
        if (urls.length > 1) ...[
          const SizedBox(height: AppSpacing.x2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(urls.length, (i) {
              final active = i == currentIndex;
              return AnimatedContainer(
                duration: AppMotion.fast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.ember : ext.hairline,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Network image slide, cached on-device by [CachedNetworkImage].
class _ImageMedia extends StatelessWidget {
  final AppThemeExtension ext;
  final String url;
  final IconData fallbackIcon;

  const _ImageMedia({
    required this.ext,
    required this.url,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(color: ext.sand),
      errorWidget: (context, url, error) => Container(
        color: ext.sand,
        alignment: Alignment.center,
        child: Icon(fallbackIcon, color: ext.cocoa50, size: 40),
      ),
    );
  }
}

/// Video slide. Initializes lazily, stays paused until tapped, and shows a
/// play/pause badge so network video isn't loaded until the user wants it.
class _VideoMedia extends StatefulWidget {
  final AppThemeExtension ext;
  final String url;
  final IconData fallbackIcon;

  const _VideoMedia({
    required this.ext,
    required this.url,
    required this.fallbackIcon,
  });

  @override
  State<_VideoMedia> createState() => _VideoMediaState();
}

class _VideoMediaState extends State<_VideoMedia> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _failed = true;
      });
      return;
    }
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _initializing = false);
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return Container(
        color: widget.ext.sand,
        alignment: Alignment.center,
        child: Icon(widget.fallbackIcon, color: widget.ext.cocoa50, size: 40),
      );
    }

    final controller = _controller;
    final ready = !_initializing &&
        controller != null &&
        controller.value.isInitialized;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (ready)
          VideoPlayer(controller)
        else
          Container(
            color: widget.ext.sand,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
        // Always-visible "video" badge.
        Positioned(
          top: AppSpacing.x2,
          left: AppSpacing.x2,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x2,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_rounded, size: 13, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Video',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (ready)
          GestureDetector(
            onTap: _togglePlay,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: AppMotion.fast,
                opacity: controller.value.isPlaying ? 0.0 : 1.0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReactButton extends StatelessWidget {
  final AppThemeExtension ext;
  final bool reacted;
  final int count;
  final VoidCallback onTap;

  const _ReactButton({
    required this.ext,
    required this.reacted,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: reacted ? 1.1 : 1.0,
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            child: Icon(
              reacted ? Icons.emoji_objects : Icons.emoji_objects_outlined,
              size: 18,
              color: reacted ? AppColors.ember : ext.cocoa50,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              color: reacted ? AppColors.ember : ext.cocoa50,
              fontSize: 13,
              fontWeight: reacted ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final AppThemeExtension ext;
  final CommentModel comment;

  const _CommentTile({required this.ext, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(ext: ext, url: comment.avatarUrl, size: 34),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    comment.authorName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: ext.cocoa,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Text(
                    timeAgo(comment.postedAt),
                    style: TextStyle(fontSize: 12, color: ext.cocoa50),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                comment.text,
                style: TextStyle(fontSize: 13.5, color: ext.cocoa, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final AppThemeExtension ext;
  final String url;
  final double size;

  const _Avatar({required this.ext, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          color: ext.sand,
        ),
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size,
          color: ext.sand,
          child: Icon(Icons.person, color: ext.cocoa50, size: size * 0.55),
        ),
      ),
    );
  }
}

/// Fixed footer input bar for posting a new comment. Sits inside this
/// page's own Scaffold, so it renders directly above the app's shared
/// bottom nav bar rather than replacing it. Shows the signed-in user's
/// avatar so comments are clearly authored by them.
class _CommentComposer extends StatelessWidget {
  final AppThemeExtension ext;
  final TextEditingController controller;
  final bool busy;
  final String avatarUrl;
  final VoidCallback onSubmit;

  const _CommentComposer({
    required this.ext,
    required this.controller,
    required this.busy,
    required this.avatarUrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: AppMotion.fast,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x4,
          AppSpacing.x2,
          AppSpacing.x4,
          AppSpacing.x2,
        ),
        decoration: BoxDecoration(
          color: ext.cream,
          border: Border(top: BorderSide(color: ext.hairline)),
        ),
        child: Row(
          children: [
            _Avatar(ext: ext, url: avatarUrl, size: 30),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x2,
                ),
                decoration: BoxDecoration(
                  color: ext.sand,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit(),
                  style: TextStyle(fontSize: 13.5, color: ext.cocoa),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Write a comment…',
                    hintStyle: TextStyle(color: ext.cocoa50, fontSize: 13.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.x2),
            InkWell(
              onTap: busy ? null : onSubmit,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.x2),
                decoration: BoxDecoration(
                  color: busy ? ext.cocoa50 : AppColors.ember,
                  shape: BoxShape.circle,
                ),
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
