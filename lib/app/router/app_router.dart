import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/features/auth/data/models/auth.dart';
import 'package:cakobean/features/auth/presentation/pages/login_page.dart';
import 'package:cakobean/features/auth/presentation/pages/register_page.dart';
import 'package:cakobean/features/auth/viewmodels/auth_viewmodel.dart';
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

/// Listens to auth state changes and pokes the router so its `redirect`
/// re-evaluates immediately (sign-in bounces to /home, sign-out to /login).
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Stream<AuthUser?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  StreamSubscription<AuthUser?>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Builds the app router. Created as a provider so it can react to the
/// Firebase auth stream; pages only ever see `routerProvider`.
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = _AuthRouterRefresh(auth.userStream);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isLoggedIn = auth.currentUser != null;
      final onAuthPage =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!isLoggedIn) {
        return onAuthPage ? null : '/login';
      }
      if (onAuthPage) return '/home';
      return null;
    },
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
});
