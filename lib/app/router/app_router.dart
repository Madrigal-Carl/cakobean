import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/domain/models/article.dart';
import 'package:cakobean/domain/models/auth.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/ui/core/layouts/main_layout.dart';
import 'package:cakobean/ui/core/navigation/page_transitions.dart';
import 'package:cakobean/ui/features/auth/view_models/auth_viewmodel.dart';
import 'package:cakobean/ui/features/auth/views/login_page.dart';
import 'package:cakobean/ui/features/auth/views/register_page.dart';
import 'package:cakobean/ui/features/farm/views/farm_detail.dart';
import 'package:cakobean/ui/features/farm/views/farm_page.dart';
import 'package:cakobean/ui/features/home/views/home_page.dart';
import 'package:cakobean/ui/features/hub/views/article_detail.dart';
import 'package:cakobean/ui/features/hub/views/hub_page.dart';
import 'package:cakobean/ui/features/logistics/views/logistics_page.dart';
import 'package:cakobean/ui/features/profile/views/profile_page.dart';

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
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (!isLoggedIn) {
        return onAuthPage ? null : '/login';
      }
      if (onAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            FadeSlidePage<void>(key: state.pageKey, child: const LoginPage()),
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
            pageBuilder: (context, state) =>
                FadeSlidePage<void>(key: state.pageKey, child: const HubPage()),
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
