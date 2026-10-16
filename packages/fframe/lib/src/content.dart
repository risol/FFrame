import 'package:flutter/widgets.dart';
import 'package:fframe_design/fframe_design.dart';

import 'primitives.dart';

/// Theme-derived text roles passed to a Markdown renderer adapter.
@immutable
class FMarkdownStyle {
  const FMarkdownStyle({
    required this.body,
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.code,
    required this.link,
    required this.quote,
    required this.codeBackground,
    required this.blockSpacing,
  });

  final FTextStyle body;
  final FTextStyle heading1;
  final FTextStyle heading2;
  final FTextStyle heading3;
  final FTextStyle code;
  final FTextStyle link;
  final FTextStyle quote;
  final FColor codeBackground;
  final double blockSpacing;

  factory FMarkdownStyle.fromTheme(FThemeData data) {
    final tokens = data.designSystem.tokens;
    return FMarkdownStyle(
      body: tokens.typography.body.copyWith(color: tokens.colors.textPrimary),
      heading1:
          tokens.typography.title.copyWith(color: tokens.colors.textPrimary),
      heading2: tokens.typography.sectionTitle
          .copyWith(color: tokens.colors.textPrimary),
      heading3: tokens.typography.bodyStrong
          .copyWith(color: tokens.colors.textPrimary),
      code: tokens.typography.monospace
          .copyWith(color: tokens.colors.textPrimary),
      link: tokens.typography.body.copyWith(color: tokens.colors.accent),
      quote: tokens.typography.body.copyWith(
        color: tokens.colors.textSecondary,
        fontStyle: FontStyle.italic,
      ),
      codeBackground: tokens.colors.surfaceSubtle,
      blockSpacing: tokens.spacing.md,
    );
  }
}

/// Adapter implemented by an optional Markdown package or application bridge.
///
/// The adapter owns parsing, block layout, links, and Markdown extensions. Its
/// output remains an [FWidget], so FFrame does not depend on a parser package.
abstract interface class FMarkdownRenderer {
  FWidget build(
    FBuildContext context, {
    required String source,
    required FMarkdownStyle style,
    required bool selectable,
  });
}

/// Stable FFrame host for a separately supplied Markdown renderer.
class FMarkdown extends StatelessWidget {
  const FMarkdown({
    super.key,
    required this.source,
    required this.renderer,
    this.selectable = false,
    this.padding = EdgeInsets.zero,
  });

  final String source;
  final FMarkdownRenderer renderer;
  final bool selectable;
  final FEdgeInsetsGeometry padding;

  @override
  FWidget build(FBuildContext context) {
    final theme = FTheme.maybeOf(context);
    if (theme == null) {
      throw FlutterError('FMarkdown must be placed under an FTheme scope.');
    }
    return Padding(
      padding: padding,
      child: renderer.build(
        context,
        source: source,
        style: FMarkdownStyle.fromTheme(theme),
        selectable: selectable,
      ),
    );
  }
}
