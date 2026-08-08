import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/article.dart';

/// Auto-scrolling "Newest Article" carousel on the home screen.
class ArticleCarousel extends StatefulWidget {
  final List<ArticleModel> articles;

  const ArticleCarousel({super.key, required this.articles});

  @override
  State<ArticleCarousel> createState() => _ArticleCarouselState();
}

class _ArticleCarouselState extends State<ArticleCarousel> {
  final _controller = PageController(viewportFraction: 1);
  int _page = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant ArticleCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.articles.length != oldWidget.articles.length) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.articles.isEmpty || !_controller.hasClients) return;

      final nextPage = (_page + 1) % widget.articles.length;

      _controller.animateToPage(
        nextPage,
        duration: AppMotion.base,
        curve: AppMotion.standard,
      );
    });
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final articles = widget.articles;

    return Listener(
      onPointerDown: (_) => _pauseAutoScroll(),
      onPointerUp: (_) => _resumeAutoScroll(),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _controller,
              itemCount: articles.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final article = articles[i];
                return InkWell(
                  onTap: () =>
                      context.push('/hub/article/${article.id}', extra: article),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: article.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: ext.sand),
                          errorWidget: (context, url, error) => Container(
                            color: ext.sand,
                            child: Icon(
                              article.tags.isEmpty
                                  ? Icons.article_outlined
                                  : article.tags.first.icon,
                              color: ext.cocoa50,
                              size: 32,
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.x4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.x1),
                              Text(
                                article.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(articles.length, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: AppMotion.fast,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.ember
                      : AppColors.cocoa50Light.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
