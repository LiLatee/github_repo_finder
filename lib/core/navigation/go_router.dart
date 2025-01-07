import 'package:flutter/material.dart';
import 'package:github_repo_finder/core/widgets/grf_annotated_region.dart';
import 'package:github_repo_finder/features/repositories/presentation/repositories_page/repositories_page.dart';
import 'package:github_repo_finder/features/repositories/presentation/repository_details_page/repository_details_page.dart';
import 'package:github_repo_finder/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKeyRepositories = GlobalKey<NavigatorState>(debugLabel: 'shellRepositories');
final _shellNavigatorKeyRepositories2 = GlobalKey<NavigatorState>(debugLabel: 'shellRepositories2');

final goRouter = GoRouter(
  initialLocation: RepositoriesPage.routeToPush,
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyRepositories,
          routes: [
            GoRoute(
              path: RepositoriesPage.routeToPush,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: RepositoriesPage(),
              ),
              routes: [
                repositoryDetailsPage,
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKeyRepositories2,
          routes: [
            GoRoute(
              path: RepositoriesGQLPage.routeToPush,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: RepositoriesGQLPage(),
              ),
              routes: [
                repositoryDetailsPage,
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
final repositoryDetailsPage = GoRoute(
  path: RepositoryDetailsPage.route,
  parentNavigatorKey: _rootNavigatorKey,
  builder: (context, state) => RepositoryDetailsPage(
    ownerName: state.pathParameters['owner']!,
    repoName: state.pathParameters['repo']!,
  ),
);

class ScaffoldWithNestedNavigation extends StatelessWidget {
  const ScaffoldWithNestedNavigation({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GrfAnnotatedRegion(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          destinations: [
            NavigationDestination(label: context.l10n.tabRestApi, icon: const Icon(Icons.home)),
            NavigationDestination(label: context.l10n.tabGraphqlApi, icon: const Icon(Icons.broken_image)),
          ],
          onDestinationSelected: _goBranch,
        ),
      ),
    );
  }
}
