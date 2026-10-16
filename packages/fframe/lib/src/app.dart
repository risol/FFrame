import 'package:flutter/widgets.dart' as fw;
import 'package:fframe_design/fframe_design.dart';

import 'primitives.dart';

/// FFrame application host with an inherited FFrame design-system scope.
class FFrameApp extends fw.StatelessWidget {
  const FFrameApp({
    super.key,
    required this.designSystem,
    required this.home,
    this.brightness = FBrightness.light,
    this.density,
    this.title = 'FFrame application',
    this.color,
    this.initialRoute,
    this.routes = const <String, FWidgetBuilder>{},
    this.onGenerateRoute,
    this.navigationController,
  });

  final FDesignSystem designSystem;
  final FWidget home;
  final FBrightness brightness;
  final FDensityTokens? density;
  final String title;
  final FColor? color;
  final String? initialRoute;
  final Map<String, FWidgetBuilder> routes;
  final FRouteBuilder? onGenerateRoute;
  final FNavigationController? navigationController;

  @override
  FWidget build(FBuildContext context) => fw.WidgetsApp(
        title: title,
        color: color ?? designSystem.tokens.colors.accent,
        home: home,
        initialRoute: initialRoute,
        routes: routes,
        pageRouteBuilder: <T>(settings, builder) => fw.PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        ),
        onGenerateRoute: onGenerateRoute == null
            ? null
            : (settings) {
                final page = onGenerateRoute!(FRouteSettings(
                  name: settings.name ?? '/',
                  arguments: settings.arguments,
                ));
                if (page == null) return null;
                return fw.PageRouteBuilder<void>(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) => page,
                );
              },
        navigatorKey: navigationController?._navigatorKey,
        builder: (context, child) => FTheme(
          data: FThemeData(
            designSystem: designSystem,
            brightness: brightness,
            density: density,
          ),
          child: FDefaultTextStyle(
            style: designSystem.tokens.typography.body.copyWith(
              color: designSystem.tokens.colors.textPrimary,
            ),
            child: child ?? const FSizedBox.shrink(),
          ),
        ),
      );
}

/// FFrame-owned route settings passed to [FFrameApp.onGenerateRoute].
class FRouteSettings {
  const FRouteSettings({required this.name, this.arguments});

  final String name;
  final Object? arguments;
}

/// FFrame-owned callback that builds the page for a named route.
typedef FRouteBuilder = FWidget? Function(FRouteSettings settings);

/// FFrame navigation controller for named routes and back navigation.
class FNavigationController {
  final fw.GlobalKey<fw.NavigatorState> _navigatorKey =
      fw.GlobalKey<fw.NavigatorState>();

  Future<T?> pushNamed<T>(String name, {Object? arguments}) =>
      _navigatorKey.currentState!.pushNamed<T>(name, arguments: arguments);

  void pop<T>([T? result]) => _navigatorKey.currentState?.pop<T>(result);

  bool get canPop => _navigatorKey.currentState?.canPop() ?? false;
}

/// FFrame navigation operations relative to an application context.
abstract final class FNavigator {
  static Future<T?> pushNamed<T>(
    FBuildContext context,
    String name, {
    Object? arguments,
  }) =>
      fw.Navigator.of(context).pushNamed<T>(name, arguments: arguments);

  static void pop<T>(FBuildContext context, [T? result]) =>
      fw.Navigator.of(context).pop<T>(result);

  static Future<bool> maybePop<T>(FBuildContext context, [T? result]) =>
      fw.Navigator.of(context).maybePop<T>(result);
}
