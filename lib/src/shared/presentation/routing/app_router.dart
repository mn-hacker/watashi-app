import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:watashi/src/modules/logs/presentation/logs_screen.dart';
import 'package:watashi/src/modules/main/presentation/main_screen.dart';
import 'package:watashi/src/modules/proxies/presentation/proxies_screen.dart';
import 'package:watashi/src/shared/errors/error_logger.dart';
import 'package:watashi/src/shared/presentation/routing/shell_route_widget.dart';

part 'app_router.g.dart';

const mainScreenName = "main";
const logsScreenName = "logs";
const proxiesScreenName = "proxies";
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: "/$mainScreenName",
    navigatorKey: rootNavigatorKey,
    onException: (context, state, router) => ref
        .read(errorLoggerProvider)
        .logError(state.error!, StackTrace.current),
    routes: [
      // Shell route with bottom navigation
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return BottomNavShell(
            homeScreen: const MainScreen(),
            proxiesScreen: const ProxiesScreen(),
          );
        },
        routes: [
          GoRoute(
            name: mainScreenName,
            path: "/$mainScreenName",
            builder: (context, state) => const MainScreen(),
            routes: [
              GoRoute(
                name: logsScreenName,
                path: logsScreenName,
                builder: (context, state) => const LogsScreen(),
              ),
            ],
          ),
          GoRoute(
            name: proxiesScreenName,
            path: "/$proxiesScreenName",
            builder: (context, state) => const ProxiesScreen(),
          ),
        ],
      ),
    ],
  );
});

/// main route ---------------------------------------------------------------
@TypedGoRoute<MainRoute>(
    name: mainScreenName,
    path: "/$mainScreenName",
    routes: [
      TypedGoRoute<LogsRoute>(
        name: logsScreenName,
        path: logsScreenName,
      ),
    ])
class MainRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => const MainScreen();
}

class LogsRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) => const LogsScreen();
}
