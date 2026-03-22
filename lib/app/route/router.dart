import 'package:flutter/material.dart';
import 'route_constants.dart';
import 'package:launcher/pages/pages.dart';
import 'package:launcher/features/config/config_feature.dart';

/// Generates routes for every named route in the app.
class AppRouter {
  AppRouter._();

  /// Returns the route matching [settings.name], defaulting to [HomePageWidget]
  /// for any unrecognised path.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.home:
        return _buildRoute((_) => const HomePageWidget());
      case RouteConstants.app:
        return _buildRoute((_) => const AppPageWidget());
      case RouteConstants.up:
        return _buildRoute((_) => const UpPageWidget());
      case RouteConstants.down:
        return _buildRoute((_) => const DownPageWidget());
      case RouteConstants.right:
        return _buildRoute((_) => const RightPageWidget());
      case RouteConstants.left:
        return _buildRoute((_) => const LeftPageWidget());
      case RouteConstants.config:
        return _buildRoute((_) => const ConfigPage());
      default:
        return _buildRoute((_) => const HomePageWidget());
    }
  }

  /// Builds an instant, flash-free page route with no transition animation.
  static PageRouteBuilder<dynamic> _buildRoute(WidgetBuilder builder) {
    return PageRouteBuilder(
      pageBuilder: (context, _, __) => builder(context),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
