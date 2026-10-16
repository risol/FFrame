import 'package:flutter/widgets.dart' as fw;

import 'primitives.dart';

/// A narrow wrapper for a Widget produced by Riverpod, FFlow, or another
/// Flutter package while keeping the surrounding application API F-prefixed.
///
/// Prefer a dedicated bridge widget when an integration needs lifecycle or
/// provider behavior. This adapter is intended for leaf widgets and renderers.
class FWidgetAdapter extends fw.StatelessWidget {
  const FWidgetAdapter({super.key, required this.builder});

  final FWidgetBuilder builder;

  @override
  FWidget build(FBuildContext context) => builder(context);
}
