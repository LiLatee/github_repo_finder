import 'package:go_router/go_router.dart';

extension GoRouterExtension on GoRouter {
  RouteMatchList get matchList {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList =
        lastMatch is ImperativeRouteMatch ? lastMatch.matches : routerDelegate.currentConfiguration;
    return matchList;
  }

  String get location => matchList.uri.toString();

  String get fullPath => matchList.fullPath;

  Map<String, String> get pathParameters => matchList.pathParameters;
}
