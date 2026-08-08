import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/features/auth/presentation/pages/login_page.dart';
import 'package:cakobean/features/auth/presentation/pages/register_page.dart';
import 'package:cakobean/features/home/presentation/pages/home_page.dart';
import 'package:cakobean/features/farm/presentation/pages/farm_page.dart';
import 'package:cakobean/features/farm/data/models/farm.dart';
import 'package:cakobean/features/farm/presentation/pages/farm_detail.dart';
import 'package:cakobean/features/hub/presentation/pages/hub_page.dart';
import 'package:cakobean/features/hub/data/models/article.dart';
import 'package:cakobean/features/hub/presentation/pages/article_detail.dart';
import 'package:cakobean/features/logistics/presentation/pages/logistics_page.dart';
import 'package:cakobean/features/profile/presentation/pages/profile_page.dart';
import 'package:cakobean/shared/layouts/main_layout.dart';
import 'package:cakobean/shared/navigation/page_transitions.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => FadeSlidePage<void>(
        key: state.pageKey,
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => FadeSlidePage<void>(
        key: state.pageKey,
        child: const RegisterPage(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => FadeSlidePage<void>(
            key: state.pageKey,
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: '/farm',
          pageBuilder: (context, state) => FadeSlidePage<void>(
            key: state.pageKey,
            child: const FarmPage(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) => FadeSlidePage<void>(
                key: state.pageKey,
                child: FarmDetail(
                  farmId: state.pathParameters['id']!,
                  farm: state.extra as FarmModel?,
                ),
                beginOffset: const Offset(0, 0.08),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/hub',
          pageBuilder: (context, state) => FadeSlidePage<void>(
            key: state.pageKey,
            child: const HubPage(),
          ),
          routes: [
            GoRoute(
              path: 'article/:id',
              pageBuilder: (context, state) => FadeSlidePage<void>(
                key: state.pageKey,
                child: ArticleDetail(
                  articleId: state.pathParameters['id']!,
                  article: state.extra as ArticleModel?,
                ),
                beginOffset: const Offset(0, 0.08),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/logistics',
          pageBuilder: (context, state) => FadeSlidePage<void>(
            key: state.pageKey,
            child: const LogisticsPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => FadeSlidePage<void>(
            key: state.pageKey,
            child: const ProfilePage(),
          ),
        ),
      ],
    ),
  ],
);
