// Keep compatibility with the declared Flutter 3.22 floor.
// ignore_for_file: deprecated_member_use

/// FFrame-owned application composition primitives.
///
/// These APIs are implemented with Flutter's rendering and accessibility
/// machinery, while keeping application source expressed in FFrame names.
library;

import 'dart:ui' as ui;
import 'dart:developer' as developer;

import 'package:fframe_design/fframe_design.dart' show FTheme;
import 'package:flutter/scheduler.dart' as fscheduler;
import 'package:flutter/services.dart' as fs;
import 'package:flutter/widgets.dart' as fw;

// Public foundation types use F-prefixed names so application code only needs
// the FFrame API. These aliases keep interoperation between FFrame packages
// cheap while the framework owns the supported surface.
typedef FWidget = fw.Widget;
typedef FBuildContext = fw.BuildContext;
typedef FStatelessWidget = fw.StatelessWidget;
typedef FStatefulWidget = fw.StatefulWidget;
typedef FState<T extends fw.StatefulWidget> = fw.State<T>;
typedef FKey = fw.Key;
typedef FVoidCallback = fw.VoidCallback;
typedef FValueChanged<T> = fw.ValueChanged<T>;
typedef FBrightness = fw.Brightness;
typedef FColor = ui.Color;
typedef FOffset = ui.Offset;
typedef FSize = ui.Size;
typedef FTextStyle = fw.TextStyle;
typedef FFontWeight = fw.FontWeight;
typedef FTextAlign = fw.TextAlign;
typedef FTextOverflow = fw.TextOverflow;
typedef FTextDirection = fw.TextDirection;
typedef FAxis = fw.Axis;
typedef FTextEditingController = fw.TextEditingController;
typedef FFocusNode = fw.FocusNode;
typedef FScrollController = fw.ScrollController;
typedef FScrollPhysics = fw.ScrollPhysics;
typedef FTextInputAction = fs.TextInputAction;
typedef FTextInputType = fs.TextInputType;
typedef FBoxConstraints = fw.BoxConstraints;
typedef FEdgeInsetsGeometry = fw.EdgeInsetsGeometry;
typedef FBoxDecoration = fw.BoxDecoration;
typedef FBorder = fw.Border;
typedef FDecoration = fw.Decoration;
typedef FBorderRadius = fw.BorderRadius;
typedef FBorderSide = fw.BorderSide;
typedef FBoxShadow = fw.BoxShadow;
typedef FClip = fw.Clip;
typedef FTableBorder = fw.TableBorder;
typedef FTableColumnWidth = fw.TableColumnWidth;
typedef FWidgetBuilder = fw.WidgetBuilder;
typedef FIndexedWidgetBuilder = fw.IndexedWidgetBuilder;
typedef FTextInputFormatter = fs.TextInputFormatter;
typedef FTextCapitalization = fs.TextCapitalization;

/// Common input formatters exposed with FFrame naming.
abstract final class FInputFormatters {
  static FTextInputFormatter get digitsOnly =>
      fs.FilteringTextInputFormatter.digitsOnly;

  static FTextInputFormatter allow(
    RegExp pattern, {
    String replacementString = '',
  }) =>
      fs.FilteringTextInputFormatter.allow(
        pattern,
        replacementString: replacementString,
      );

  static FTextInputFormatter deny(
    RegExp pattern, {
    String replacementString = '',
  }) =>
      fs.FilteringTextInputFormatter.deny(
        pattern,
        replacementString: replacementString,
      );
}

/// Frame timing values exposed through FFrame's diagnostics API.
class FFrameTiming {
  const FFrameTiming({
    required this.buildDuration,
    required this.rasterDuration,
  });

  final Duration buildDuration;
  final Duration rasterDuration;

  factory FFrameTiming._fromFlutter(fscheduler.FrameTiming timing) =>
      FFrameTiming(
        buildDuration: timing.buildDuration,
        rasterDuration: timing.rasterDuration,
      );
}

/// Callback for batches of completed FFrame timing measurements.
typedef FFrameTimingsCallback = void Function(List<FFrameTiming> timings);

/// Frame timing hooks for FFrame diagnostics and performance tools.
abstract final class FFrameScheduler {
  static void ensureInitialized() =>
      fw.WidgetsFlutterBinding.ensureInitialized();

  static void addTimingsCallback(FFrameTimingsCallback callback) {
    fscheduler.SchedulerBinding.instance.addTimingsCallback((timings) {
      callback(List<FFrameTiming>.unmodifiable(
        timings.map(FFrameTiming._fromFlutter),
      ));
    });
  }
}

/// Writes diagnostic messages through Dart's platform logging facility.
abstract final class FFrameLog {
  static void info(String message, {String name = 'fframe'}) =>
      developer.log(message, name: name);
}

/// Intrinsic content sizing for an FFrame table column.
class FIntrinsicColumnWidth extends fw.IntrinsicColumnWidth {
  const FIntrinsicColumnWidth({super.flex});
}

/// Fixed sizing for an FFrame table column.
class FFixedColumnWidth extends fw.FixedColumnWidth {
  const FFixedColumnWidth(super.value);
}

/// Main-axis sizing for [FRow] and [FColumn].
enum FMainAxisSize { min, max }

/// Main-axis positioning for [FRow] and [FColumn].
enum FMainAxisAlignment {
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly
}

/// Cross-axis positioning for [FRow] and [FColumn].
enum FCrossAxisAlignment { start, end, center, stretch, baseline }

/// Text direction-aware alignment values.
enum FTextAlignment { start, end, left, right, center, justify }

/// How overflowing text is handled.
enum FTextOverflowMode { clip, fade, ellipsis, visible }

/// Vertical ordering for children in FFrame linear layouts.
enum FVerticalDirection { down, up }

/// Child sizing for [FStack].
enum FStackFit { loose, expand, passthrough }

/// Alignment of FFrame wrapping layouts.
enum FWrapAlignment {
  start,
  end,
  center,
  spaceBetween,
  spaceAround,
  spaceEvenly
}

/// Cross-axis alignment of FFrame wrapping layouts.
enum FWrapCrossAlignment { start, end, center }

/// FFrame edge insets accepted by FFrame layout primitives.
class FEdgeInsets extends fw.EdgeInsets {
  const FEdgeInsets.all(super.value) : super.all();

  const FEdgeInsets.symmetric({super.vertical = 0, super.horizontal = 0})
      : super.symmetric();

  const FEdgeInsets.only({
    super.left = 0,
    super.top = 0,
    super.right = 0,
    super.bottom = 0,
  }) : super.only();

  const FEdgeInsets.fromLTRB(super.left, super.top, super.right, super.bottom)
      : super.fromLTRB();

  static const FEdgeInsets zero = FEdgeInsets.all(0);
}

/// FFrame alignment values used by [FContainer] and [FAlign].
class FAlignment extends fw.Alignment {
  const FAlignment(super.x, super.y);

  static const FAlignment center = FAlignment(0, 0);
  static const FAlignment topCenter = FAlignment(0, -1);
  static const FAlignment topLeft = FAlignment(-1, -1);
  static const FAlignment centerLeft = FAlignment(-1, 0);
  static const FAlignment centerRight = FAlignment(1, 0);
  static const FAlignment bottomCenter = FAlignment(0, 1);
}

/// Horizontal and vertical flow directions for FFrame primitives.
enum FLayoutAxis { horizontal, vertical }

/// Creates the root Flutter view from an FFrame application widget.
void runFFrameApp(FWidget application) => fw.runApp(application);

/// FFrame text rendered with the current FFrame text defaults.
class FText extends fw.StatelessWidget {
  const FText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  });

  final String data;
  final FTextStyle? style;
  final FTextAlignment? textAlign;
  final FTextOverflowMode? overflow;
  final int? maxLines;
  final bool? softWrap;

  @override
  FWidget build(FBuildContext context) => fw.Text(
        data,
        style: style,
        textAlign: switch (textAlign) {
          FTextAlignment.start => fw.TextAlign.start,
          FTextAlignment.end => fw.TextAlign.end,
          FTextAlignment.left => fw.TextAlign.left,
          FTextAlignment.right => fw.TextAlign.right,
          FTextAlignment.center => fw.TextAlign.center,
          FTextAlignment.justify => fw.TextAlign.justify,
          null => null,
        },
        overflow: switch (overflow) {
          FTextOverflowMode.clip => fw.TextOverflow.clip,
          FTextOverflowMode.fade => fw.TextOverflow.fade,
          FTextOverflowMode.ellipsis => fw.TextOverflow.ellipsis,
          FTextOverflowMode.visible => fw.TextOverflow.visible,
          null => null,
        },
        maxLines: maxLines,
        softWrap: softWrap,
      );
}

/// Rich text whose spans use FFrame-owned names.
class FRichText extends fw.StatelessWidget {
  const FRichText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = FTextAlignment.start,
    this.maxLines,
    this.softWrap = true,
    this.overflow = FTextOverflowMode.clip,
  });

  final FInlineSpan text;
  final FTextStyle? style;
  final FTextAlignment textAlign;
  final int? maxLines;
  final bool softWrap;
  final FTextOverflowMode overflow;

  @override
  FWidget build(FBuildContext context) => fw.RichText(
        text: FInlineSpan(
          style: style ?? fw.DefaultTextStyle.of(context).style,
          children: <FInlineSpan>[text],
        ),
        textAlign: switch (textAlign) {
          FTextAlignment.start => fw.TextAlign.start,
          FTextAlignment.end => fw.TextAlign.end,
          FTextAlignment.left => fw.TextAlign.left,
          FTextAlignment.right => fw.TextAlign.right,
          FTextAlignment.center => fw.TextAlign.center,
          FTextAlignment.justify => fw.TextAlign.justify,
        },
        textDirection: fw.Directionality.of(context),
        maxLines: maxLines,
        softWrap: softWrap,
        overflow: switch (overflow) {
          FTextOverflowMode.clip => fw.TextOverflow.clip,
          FTextOverflowMode.fade => fw.TextOverflow.fade,
          FTextOverflowMode.ellipsis => fw.TextOverflow.ellipsis,
          FTextOverflowMode.visible => fw.TextOverflow.visible,
        },
      );
}

/// A rich-text span with FFrame naming and Flutter's stable span behavior.
class FInlineSpan extends fw.TextSpan {
  const FInlineSpan(
      {super.text, super.style, super.children, super.recognizer});
}

/// An inline widget embedded in [FRichText].
class FWidgetSpan extends fw.WidgetSpan {
  const FWidgetSpan({
    required super.child,
    super.alignment = fw.PlaceholderAlignment.bottom,
    super.baseline,
  });
}

/// A framework-owned icon symbol identifier.
class FIconData {
  const FIconData._(this._codePoint);

  final int _codePoint;
}

/// FFrame's shared icon vocabulary.
///
/// Glyph rendering is an implementation detail of FIcon; app code refers to
/// these stable FFrame names instead of importing a platform icon catalog.
abstract final class FIcons {
  static const add = FIconData._(0xe145);
  static const arrowBack = FIconData._(0xe5c4);
  static const arrowDownward = FIconData._(0xe5db);
  static const arrowForward = FIconData._(0xe5c8);
  static const arrowUpward = FIconData._(0xe5d8);
  static const attachFile = FIconData._(0xe24d);
  static const accountTree = FIconData._(0xee36);
  static const administration = FIconData._(0xee53);
  static const autoFormat = FIconData._(0xeeab);
  static const calendar = FIconData._(0xe935);
  static const chat = FIconData._(0xef44);
  static const check = FIconData._(0xe5ca);
  static const checkCircle = FIconData._(0xe159);
  static const chevronDown = FIconData._(0xe5cf);
  static const chevronLeft = FIconData._(0xe5cb);
  static const chevronRight = FIconData._(0xe15f);
  static const chevronUp = FIconData._(0xe5ce);
  static const circle = FIconData._(0xe163);
  static const close = FIconData._(0xe16a);
  static const delete = FIconData._(0xe872);
  static const darkMode = FIconData._(0xef9f);
  static const description = FIconData._(0xefae);
  static const database = FIconData._(0xefd4);
  static const download = FIconData._(0xeff2);
  static const edit = FIconData._(0xe3c9);
  static const error = FIconData._(0xe000);
  static const expandMore = FIconData._(0xe246);
  static const extension = FIconData._(0xf03f);
  static const filterList = FIconData._(0xe152);
  static const folderOpen = FIconData._(0xf090);
  static const folder = FIconData._(0xf091);
  static const help = FIconData._(0xe887);
  static const home = FIconData._(0xe88a);
  static const info = FIconData._(0xe88e);
  static const lock = FIconData._(0xe897);
  static const lineSpacing = FIconData._(0xe2b7);
  static const lightMode = FIconData._(0xf162);
  static const menu = FIconData._(0xe3dc);
  static const moreHorizontal = FIconData._(0xe402);
  static const moreVertical = FIconData._(0xe5d4);
  static const openInFull = FIconData._(0xe45b);
  static const radioButtonChecked = FIconData._(0xe837);
  static const radioButtonUnchecked = FIconData._(0xe836);
  static const refresh = FIconData._(0xe5d5);
  static const remove = FIconData._(0xe15b);
  static const search = FIconData._(0xe8b6);
  static const send = FIconData._(0xe163);
  static const settings = FIconData._(0xe8b8);
  static const people = FIconData._(0xe488);
  static const addPerson = FIconData._(0xe494);
  static const play = FIconData._(0xf00a0);
  static const save = FIconData._(0xf334);
  static const security = FIconData._(0xf379);
  static const storage = FIconData._(0xf01de);
  static const sort = FIconData._(0xe164);
  static const visibility = FIconData._(0xe8f4);
  static const visibilityOff = FIconData._(0xe8f5);
  static const warning = FIconData._(0xe002);
  static const table = FIconData._(0xf41d);
  static const tune = FIconData._(0xe683);
  static const upload = FIconData._(0xe2c6);
  static const launch = FIconData._(0xe89e);
  static const webhook = FIconData._(0xf0697);
}

/// FFrame icon with color and size inherited from the active FFrame theme.
class FIcon extends fw.StatelessWidget {
  const FIcon(this.data, {super.key, this.size, this.color});

  final FIconData data;
  final double? size;
  final FColor? color;

  @override
  FWidget build(FBuildContext context) => fw.Text(
        String.fromCharCode(data._codePoint),
        style: fw.TextStyle(
          fontFamily: 'FFrameSymbols',
          package: 'fframe',
          fontSize: size,
          color: color ?? FTheme.maybeOf(context)?.tokens.colors.textSecondary,
        ),
      );
}

/// Horizontal FFrame layout.
class FRow extends fw.StatelessWidget {
  const FRow({
    super.key,
    this.children = const <FWidget>[],
    this.mainAxisAlignment = FMainAxisAlignment.start,
    this.mainAxisSize = FMainAxisSize.max,
    this.crossAxisAlignment = FCrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = FVerticalDirection.down,
  });

  final List<FWidget> children;
  final FMainAxisAlignment mainAxisAlignment;
  final FMainAxisSize mainAxisSize;
  final FCrossAxisAlignment crossAxisAlignment;
  final FTextDirection? textDirection;
  final FVerticalDirection verticalDirection;

  @override
  FWidget build(FBuildContext context) => fw.Row(
        mainAxisAlignment: _mainAlignment(mainAxisAlignment),
        mainAxisSize: mainAxisSize == FMainAxisSize.min
            ? fw.MainAxisSize.min
            : fw.MainAxisSize.max,
        crossAxisAlignment: _crossAlignment(crossAxisAlignment),
        textDirection: textDirection,
        verticalDirection: verticalDirection == FVerticalDirection.up
            ? fw.VerticalDirection.up
            : fw.VerticalDirection.down,
        children: children,
      );
}

/// Vertical FFrame layout.
class FColumn extends fw.StatelessWidget {
  const FColumn({
    super.key,
    this.children = const <FWidget>[],
    this.mainAxisAlignment = FMainAxisAlignment.start,
    this.mainAxisSize = FMainAxisSize.max,
    this.crossAxisAlignment = FCrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = FVerticalDirection.down,
  });

  final List<FWidget> children;
  final FMainAxisAlignment mainAxisAlignment;
  final FMainAxisSize mainAxisSize;
  final FCrossAxisAlignment crossAxisAlignment;
  final FTextDirection? textDirection;
  final FVerticalDirection verticalDirection;

  @override
  FWidget build(FBuildContext context) => fw.Column(
        mainAxisAlignment: _mainAlignment(mainAxisAlignment),
        mainAxisSize: mainAxisSize == FMainAxisSize.min
            ? fw.MainAxisSize.min
            : fw.MainAxisSize.max,
        crossAxisAlignment: _crossAlignment(crossAxisAlignment),
        textDirection: textDirection,
        verticalDirection: verticalDirection == FVerticalDirection.up
            ? fw.VerticalDirection.up
            : fw.VerticalDirection.down,
        children: children,
      );
}

fw.MainAxisAlignment _mainAlignment(FMainAxisAlignment value) =>
    switch (value) {
      FMainAxisAlignment.start => fw.MainAxisAlignment.start,
      FMainAxisAlignment.end => fw.MainAxisAlignment.end,
      FMainAxisAlignment.center => fw.MainAxisAlignment.center,
      FMainAxisAlignment.spaceBetween => fw.MainAxisAlignment.spaceBetween,
      FMainAxisAlignment.spaceAround => fw.MainAxisAlignment.spaceAround,
      FMainAxisAlignment.spaceEvenly => fw.MainAxisAlignment.spaceEvenly,
    };

fw.CrossAxisAlignment _crossAlignment(FCrossAxisAlignment value) =>
    switch (value) {
      FCrossAxisAlignment.start => fw.CrossAxisAlignment.start,
      FCrossAxisAlignment.end => fw.CrossAxisAlignment.end,
      FCrossAxisAlignment.center => fw.CrossAxisAlignment.center,
      FCrossAxisAlignment.stretch => fw.CrossAxisAlignment.stretch,
      FCrossAxisAlignment.baseline => fw.CrossAxisAlignment.baseline,
    };

/// FFrame sizing constraint with optional width and height.
class FSizedBox extends fw.StatelessWidget {
  const FSizedBox({super.key, this.width, this.height, this.child});
  // `double.infinity` is not a compile-time constant in Dart.
  // ignore: prefer_const_constructors_in_immutables
  FSizedBox.expand({super.key, this.child})
      : width = double.infinity,
        height = double.infinity;
  const FSizedBox.shrink({super.key})
      : width = 0,
        height = 0,
        child = null;
  FSizedBox.fromSize({super.key, required FSize size, this.child})
      : width = size.width,
        height = size.height;

  final double? width;
  final double? height;
  final FWidget? child;

  @override
  FWidget build(FBuildContext context) =>
      fw.SizedBox(width: width, height: height, child: child);
}

/// FFrame padding around one child.
class FPadding extends fw.StatelessWidget {
  const FPadding({super.key, required this.padding, required this.child});
  final FEdgeInsets padding;
  final FWidget child;

  @override
  FWidget build(FBuildContext context) =>
      fw.Padding(padding: padding, child: child);
}

/// Flexible child of an [FRow] or [FColumn].
class FExpanded extends fw.StatelessWidget {
  const FExpanded({super.key, this.flex = 1, required this.child});
  final int flex;
  final FWidget child;

  @override
  FWidget build(FBuildContext context) => fw.Expanded(flex: flex, child: child);
}

/// Empty flexible space inside an [FRow] or [FColumn].
class FSpacer extends fw.StatelessWidget {
  const FSpacer({super.key, this.flex = 1});
  final int flex;

  @override
  FWidget build(FBuildContext context) => fw.Spacer(flex: flex);
}

/// Centers a child in the available space.
class FCenter extends fw.StatelessWidget {
  const FCenter({super.key, this.child});
  final FWidget? child;

  @override
  FWidget build(FBuildContext context) => fw.Center(child: child);
}

/// Aligns a child to an FFrame alignment value.
class FAlign extends fw.StatelessWidget {
  const FAlign({super.key, required this.alignment, this.child});
  final FAlignment alignment;
  final FWidget? child;

  @override
  FWidget build(FBuildContext context) =>
      fw.Align(alignment: alignment, child: child);
}

/// Applies a maximum or minimum size constraint to a child.
class FConstrainedBox extends fw.StatelessWidget {
  const FConstrainedBox({
    super.key,
    required this.constraints,
    required this.child,
  });
  final FBoxConstraints constraints;
  final FWidget child;

  @override
  FWidget build(FBuildContext context) =>
      fw.ConstrainedBox(constraints: constraints, child: child);
}

/// FFrame surface with common layout and decoration properties.
class FContainer extends fw.StatelessWidget {
  const FContainer({
    super.key,
    this.alignment,
    this.padding,
    this.color,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.decoration,
    this.foregroundDecoration,
    this.clipBehavior = fw.Clip.none,
    this.child,
  });

  final FAlignment? alignment;
  final FEdgeInsets? padding;
  final FColor? color;
  final double? width;
  final double? height;
  final FBoxConstraints? constraints;
  final FEdgeInsets? margin;
  final FDecoration? decoration;
  final FDecoration? foregroundDecoration;
  final FClip clipBehavior;
  final FWidget? child;

  @override
  FWidget build(FBuildContext context) => fw.Container(
        alignment: alignment,
        padding: padding,
        color: color,
        width: width,
        height: height,
        constraints: constraints,
        margin: margin,
        decoration: decoration,
        foregroundDecoration: foregroundDecoration,
        clipBehavior: clipBehavior,
        child: child,
      );
}

/// A non-interactive FFrame color surface.
class FColoredBox extends fw.StatelessWidget {
  const FColoredBox({super.key, required this.color, required this.child});
  final FColor color;
  final FWidget child;

  @override
  FWidget build(FBuildContext context) =>
      fw.ColoredBox(color: color, child: child);
}

/// A wrapping FFrame flow layout.
class FWrap extends fw.StatelessWidget {
  const FWrap({
    super.key,
    this.children = const <FWidget>[],
    this.spacing = 0,
    this.runSpacing = 0,
    this.alignment = FWrapAlignment.start,
    this.runAlignment = FWrapAlignment.start,
    this.crossAxisAlignment = FWrapCrossAlignment.start,
  });
  final List<FWidget> children;
  final double spacing;
  final double runSpacing;
  final FWrapAlignment alignment;
  final FWrapAlignment runAlignment;
  final FWrapCrossAlignment crossAxisAlignment;

  @override
  FWidget build(FBuildContext context) => fw.Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: _wrapAlignment(alignment),
        runAlignment: _wrapAlignment(runAlignment),
        crossAxisAlignment: switch (crossAxisAlignment) {
          FWrapCrossAlignment.start => fw.WrapCrossAlignment.start,
          FWrapCrossAlignment.end => fw.WrapCrossAlignment.end,
          FWrapCrossAlignment.center => fw.WrapCrossAlignment.center,
        },
        children: children,
      );
}

fw.WrapAlignment _wrapAlignment(FWrapAlignment value) => switch (value) {
      FWrapAlignment.start => fw.WrapAlignment.start,
      FWrapAlignment.end => fw.WrapAlignment.end,
      FWrapAlignment.center => fw.WrapAlignment.center,
      FWrapAlignment.spaceBetween => fw.WrapAlignment.spaceBetween,
      FWrapAlignment.spaceAround => fw.WrapAlignment.spaceAround,
      FWrapAlignment.spaceEvenly => fw.WrapAlignment.spaceEvenly,
    };

/// A layered FFrame layout.
class FStack extends fw.StatelessWidget {
  const FStack({
    super.key,
    this.children = const <FWidget>[],
    this.alignment = FAlignment.topLeft,
    this.fit = FStackFit.loose,
    this.clipBehavior = fw.Clip.hardEdge,
  });
  final List<FWidget> children;
  final FAlignment alignment;
  final FStackFit fit;
  final FClip clipBehavior;

  @override
  FWidget build(FBuildContext context) => fw.Stack(
        alignment: alignment,
        fit: switch (fit) {
          FStackFit.loose => fw.StackFit.loose,
          FStackFit.expand => fw.StackFit.expand,
          FStackFit.passthrough => fw.StackFit.passthrough,
        },
        clipBehavior: clipBehavior,
        children: children,
      );
}

/// Positions a child inside an [FStack].
class FPositioned extends fw.StatelessWidget {
  const FPositioned({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    required this.child,
  });
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final FWidget child;

  @override
  FWidget build(FBuildContext context) => fw.Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        width: width,
        height: height,
        child: child,
      );
}

/// A horizontal or vertical FFrame scroll area.
class FSingleChildScrollView extends fw.StatelessWidget {
  const FSingleChildScrollView({
    super.key,
    this.scrollDirection = FLayoutAxis.vertical,
    this.padding,
    this.child,
  });
  final FLayoutAxis scrollDirection;
  final FEdgeInsets? padding;
  final FWidget? child;

  @override
  FWidget build(FBuildContext context) => fw.SingleChildScrollView(
        scrollDirection: scrollDirection == FLayoutAxis.horizontal
            ? fw.Axis.horizontal
            : fw.Axis.vertical,
        padding: padding,
        child: child,
      );
}

/// A lazily built FFrame list.
///
/// Prefer [FListView.builder] for large or unbounded collections. It creates
/// children only as they enter the visible/cache region and preserves normal
/// Flutter scroll-controller and semantics behavior.
class FListView extends fw.StatelessWidget {
  const FListView({
    super.key,
    required this.children,
    this.scrollDirection = FLayoutAxis.vertical,
    this.padding,
    this.controller,
    this.physics,
    this.reverse = false,
    this.primary,
    this.cacheExtent,
  })  : itemBuilder = null,
        separatorBuilder = null,
        itemCount = children.length;

  const FListView.builder({
    super.key,
    required this.itemBuilder,
    this.itemCount,
    this.scrollDirection = FLayoutAxis.vertical,
    this.padding,
    this.controller,
    this.physics,
    this.reverse = false,
    this.primary,
    this.cacheExtent,
  })  : children = const <FWidget>[],
        separatorBuilder = null;

  const FListView.separated({
    super.key,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.itemCount,
    this.scrollDirection = FLayoutAxis.vertical,
    this.padding,
    this.controller,
    this.physics,
    this.reverse = false,
    this.primary,
    this.cacheExtent,
  }) : children = const <FWidget>[];

  final List<FWidget> children;
  final FIndexedWidgetBuilder? itemBuilder;
  final FIndexedWidgetBuilder? separatorBuilder;
  final int? itemCount;
  final FLayoutAxis scrollDirection;
  final FEdgeInsetsGeometry? padding;
  final FScrollController? controller;
  final FScrollPhysics? physics;
  final bool reverse;
  final bool? primary;
  final double? cacheExtent;

  @override
  FWidget build(FBuildContext context) {
    final axis = scrollDirection == FLayoutAxis.horizontal
        ? fw.Axis.horizontal
        : fw.Axis.vertical;
    final separator = separatorBuilder;
    if (separator != null) {
      return fw.ListView.separated(
        key: key,
        itemBuilder: itemBuilder!,
        separatorBuilder: separator,
        itemCount: itemCount!,
        scrollDirection: axis,
        padding: padding,
        controller: controller,
        physics: physics,
        reverse: reverse,
        primary: primary,
        cacheExtent: cacheExtent,
      );
    }
    final builder = itemBuilder;
    if (builder != null) {
      return fw.ListView.builder(
        key: key,
        itemBuilder: builder,
        itemCount: itemCount,
        scrollDirection: axis,
        padding: padding,
        controller: controller,
        physics: physics,
        reverse: reverse,
        primary: primary,
        cacheExtent: cacheExtent,
      );
    }
    return fw.ListView(
      key: key,
      scrollDirection: axis,
      padding: padding,
      controller: controller,
      physics: physics,
      reverse: reverse,
      primary: primary,
      cacheExtent: cacheExtent,
      children: children,
    );
  }
}

/// FFrame table row description.
class FTableRow {
  const FTableRow({required this.children, this.decoration});
  final List<FWidget> children;
  final FDecoration? decoration;
}

/// FFrame tabular data layout.
class FTable extends fw.StatelessWidget {
  const FTable({
    super.key,
    required this.children,
    this.border,
    this.defaultColumnWidth,
  });
  final List<FTableRow> children;
  final FTableBorder? border;
  final FTableColumnWidth? defaultColumnWidth;

  @override
  FWidget build(FBuildContext context) => fw.Table(
        border: border,
        defaultColumnWidth: defaultColumnWidth ?? const fw.FlexColumnWidth(),
        children: <fw.TableRow>[
          for (final row in children)
            fw.TableRow(decoration: row.decoration, children: row.children),
        ],
      );
}

/// Applies a text style to a subtree.
class FDefaultTextStyle extends fw.StatelessWidget {
  const FDefaultTextStyle({
    super.key,
    required this.style,
    required this.child,
    this.merge = false,
  });
  const FDefaultTextStyle.merge({
    super.key,
    required this.style,
    required this.child,
  }) : merge = true;
  final FTextStyle style;
  final FWidget child;
  final bool merge;

  @override
  FWidget build(FBuildContext context) => merge
      ? fw.DefaultTextStyle.merge(style: style, child: child)
      : fw.DefaultTextStyle(style: style, child: child);
}
