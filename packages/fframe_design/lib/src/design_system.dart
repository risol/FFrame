import 'tokens.dart';
import 'styles.dart';

/// A pluggable visual language for FFrame controls.
abstract interface class FDesignSystem {
  String get id;
  String get name;
  FDesignTokens get tokens;
  FComponentStyles get components;
}
