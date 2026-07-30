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

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/farm',
          builder: (context, state) => const FarmPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => FarmDetail(
                farmId: state.pathParameters['id']!,
                farm: state.extra as FarmModel?,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/hub',
          builder: (context, state) => const HubPage(),
          routes: [
            GoRoute(
              path: 'article/:id',
              builder: (context, state) => ArticleDetail(
                articleId: state.pathParameters['id']!,
                article: state.extra as ArticleModel?,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/logistics',
          builder: (context, state) => const LogisticsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
  ],
);
