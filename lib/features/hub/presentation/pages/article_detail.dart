import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/shared/widgets/stat_chip.dart';
import '../../data/models/article.dart';
import '../../data/models/comment.dart';

class ArticleDetail extends StatefulWidget {
  final String articleId;
  final ArticleModel? article; // passed via go_router `extra` when available

  const ArticleDetail({super.key, required this.articleId, this.article});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  late final ArticleModel _article;
  late final List<CommentModel> _comments;
  final _commentController = TextEditingController();
  final _mediaPageController = PageController();
  int _mediaIndex = 0;
  bool _reacted = false;
  late int _reactionCount;

  @override
  void initState() {
    super.initState();
    _article =
        widget.article ??
        mockHubArticles.firstWhere(
          (a) => a.id == widget.articleId,
          orElse: () => mockHubArticles.first,
        );
    _comments = List.of(_article.comments);
    _reactionCount = _article.reactionCount;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _mediaPageController.dispose();
    super.dispose();
  }

  void _toggleReaction() {
    setState(() {
      _reacted = !_reacted;
      _reactionCount += _reacted ? 1 : -1;
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        CommentModel(
          id: 'local-${DateTime.now().microsecondsSinceEpoch}',
          authorName: 'You',
          avatarUrl: 'https://i.pravatar.cc/100?img=68',
          text: text,
          postedAt: DateTime.now(),
        ),
      );
    });
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final media = _article.displayMedia;

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
                  pageController: _mediaPageController,
                  currentIndex: _mediaIndex,
                  onPageChanged: (i) => setState(() => _mediaIndex = i),
                  // Extension point: if a mediaUrl ends in a video
                  // extension (.mp4 etc), swap Image.network below for a
                  // VideoPlayerController-backed widget (video_player pkg).
                  fallbackIcon: _article.tags.first.icon,
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
                        for (final tag in _article.tags)
                          StatChip(ext: ext, icon: tag.icon, label: tag.label),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Text(
                      _article.title,
                      style: textTheme.headlineSmall?.copyWith(
                        color: ext.cocoa,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    Row(
                      children: [
                        _ReactButton(
                          ext: ext,
                          reacted: _reacted,
                          count: _reactionCount,
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
                          '${_comments.length}',
                          style: TextStyle(color: ext.cocoa50, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    Text(
                      _article.description,
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
                  'Comments (${_comments.length})',
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 17,
                    color: ext.cocoa,
                  ),
                ),
              ),
            ),
            if (_comments.isEmpty)
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
                itemCount: _comments.length,
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
                  child: _CommentTile(ext: ext, comment: _comments[i]),
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
          onSubmit: _submitComment,
        ),
      ),
    );
  }
}

/// Swipeable image gallery with a dot indicator. Falls back to a tinted
/// icon tile per-image if the network image fails to load.
class _MediaCarousel extends StatelessWidget {
  final AppThemeExtension ext;
  final List<String> urls;
  final PageController pageController;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final IconData fallbackIcon;

  const _MediaCarousel({
    required this.ext,
    required this.urls,
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
              itemBuilder: (context, i) => Image.network(
                urls[i],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: ext.sand,
                  alignment: Alignment.center,
                  child: Icon(fallbackIcon, color: ext.cocoa50, size: 40),
                ),
              ),
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
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
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
/// bottom nav bar rather than replacing it.
class _CommentComposer extends StatelessWidget {
  final AppThemeExtension ext;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _CommentComposer({
    required this.ext,
    required this.controller,
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
            _Avatar(
              ext: ext,
              url: 'https://i.pravatar.cc/100?img=68',
              size: 30,
            ),
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
              onTap: onSubmit,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.x2),
                decoration: const BoxDecoration(
                  color: AppColors.ember,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
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
