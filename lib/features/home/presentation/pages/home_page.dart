import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cakobean/app/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HomeHeader(ext: ext),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.x5),
                    Text('Newest Article', style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.x2),
                    const _ArticleCarousel(),
                    const SizedBox(height: AppSpacing.x5),
                    Text('Recent Articles', style: textTheme.headlineSmall),
                    const SizedBox(height: AppSpacing.x2),
                    ..._recentArticles.map(
                      (a) => _RecentArticleTile(article: a, ext: ext),
                    ),
                    const SizedBox(height: AppSpacing.x6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---- Header: gradient hero with wave bottom edge ----
class _HomeHeader extends StatelessWidget {
  final AppThemeExtension ext;
  const _HomeHeader({required this.ext});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
              'Demo Farmer',
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontSize: 30,
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

/// ---- Newest article carousel ----
class _ArticleData {
  final String label;
  final String title;
  final Color color;
  const _ArticleData({
    required this.label,
    required this.title,
    required this.color,
  });
}

const _carouselArticles = [
  _ArticleData(
    label: 'ARTICLE',
    title: 'Shade Tree Management for Sustainable Cacao Farming',
    color: Color(0xFF3B6E91),
  ),
  _ArticleData(
    label: 'ARTICLE',
    title: 'Post-Harvest Fermentation Techniques',
    color: Color(0xFF6E4B3B),
  ),
  _ArticleData(
    label: 'ARTICLE',
    title: 'Improving Yield with Proper Pruning',
    color: Color(0xFF3B914E),
  ),
];

class _ArticleCarousel extends StatefulWidget {
  const _ArticleCarousel();

  @override
  State<_ArticleCarousel> createState() => _ArticleCarouselState();
}

class _ArticleCarouselState extends State<_ArticleCarousel> {
  final _controller = PageController(viewportFraction: 1);
  int _page = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_controller.hasClients) return;

      final nextPage = (_page + 1) % _carouselArticles.length;

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
    return Listener(
      onPointerDown: (_) => _pauseAutoScroll(),
      onPointerUp: (_) => _resumeAutoScroll(),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: _controller,
              itemCount: _carouselArticles.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final article = _carouselArticles[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: article.color),
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
                            Text(
                              article.label,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
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
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_carouselArticles.length, (i) {
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

/// ---- Recent articles list ----
class _RecentArticle {
  final String title;
  final String timeAgo;
  const _RecentArticle({required this.title, required this.timeAgo});
}

const _recentArticles = [
  _RecentArticle(
    title: 'How to Identify and Treat Pod Borer in Cacao',
    timeAgo: '1h ago',
  ),
  _RecentArticle(
    title: 'Market Update: Cacao Prices Rise 12% This Quarter',
    timeAgo: '4h ago',
  ),
];

class _RecentArticleTile extends StatelessWidget {
  final _RecentArticle article;
  final AppThemeExtension ext;
  const _RecentArticleTile({required this.article, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ext.hairline)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.ember,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ext.cocoa,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x2,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ext.sand,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        'Opened',
                        style: TextStyle(
                          fontSize: 11,
                          color: ext.cocoa50,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    Text(
                      article.timeAgo,
                      style: TextStyle(fontSize: 12, color: ext.cocoa50),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
