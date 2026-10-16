import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Current size and visibility state for one split pane.
@immutable
class FPaneState {
  /// Creates a pane state.
  const FPaneState({
    required this.size,
    this.collapsed = false,
    this.userSized = false,
  }) : assert(size >= 0 && size < double.infinity);

  /// Current size in logical pixels.
  final double size;

  /// Whether the pane is collapsed.
  final bool collapsed;

  /// Whether the size was explicitly set by the application or a drag.
  final bool userSized;

  FPaneState copyWith({double? size, bool? collapsed, bool? userSized}) =>
      FPaneState(
        size: size ?? this.size,
        collapsed: collapsed ?? this.collapsed,
        userSized: userSized ?? this.userSized,
      );

  @override
  bool operator ==(Object other) =>
      other is FPaneState &&
      other.size == size &&
      other.collapsed == collapsed &&
      other.userSized == userSized;

  @override
  int get hashCode => Object.hash(size, collapsed, userSized);
}

/// Serializable value snapshot of split pane state.
@immutable
class FPaneSnapshot {
  /// Creates an immutable snapshot.
  FPaneSnapshot(Map<String, FPaneState> panes)
      : panes = UnmodifiableMapView(Map<String, FPaneState>.of(panes));

  /// Pane states keyed by pane id.
  final Map<String, FPaneState> panes;
}

/// Owns resizable and collapsible pane state for an [FSplitView].
class FPaneController extends ChangeNotifier {
  final Map<String, FPaneState> _states = <String, FPaneState>{};
  final Map<String, FPaneState> _pendingStates = <String, FPaneState>{};
  final Map<String, double> _preferredSizes = <String, double>{};
  final Map<String, double> _minimumSizes = <String, double>{};
  final Map<String, double> _maximumSizes = <String, double>{};
  final Set<String> _collapsible = <String>{};

  /// Read-only view of all known pane states.
  Map<String, FPaneState> get states => UnmodifiableMapView(
        <String, FPaneState>{..._pendingStates, ..._states},
      );

  /// Returns a pane's current state, if it has been registered.
  FPaneState? stateFor(String id) => _states[id] ?? _pendingStates[id];

  /// Registers a pane without overwriting state previously restored by the app.
  void configurePane({
    required String id,
    required double initialSize,
    required double minSize,
    required double maxSize,
    required bool collapsible,
  }) {
    _preferredSizes[id] = initialSize;
    _minimumSizes[id] = minSize;
    _maximumSizes[id] = maxSize;
    if (collapsible) {
      _collapsible.add(id);
    } else {
      _collapsible.remove(id);
    }
    final existing = _states[id] ?? _pendingStates.remove(id);
    if (existing == null) {
      _states[id] = FPaneState(size: initialSize);
    } else {
      _states[id] = existing.copyWith(
        size: existing.size.clamp(minSize, maxSize).toDouble(),
        collapsed: collapsible && existing.collapsed,
      );
    }
  }

  /// Sets a pane size, clamping it to the configured min/max range.
  void setSize(String id, double size) {
    final current = _states[id];
    if (current == null) return;
    if (!size.isFinite || size < 0) {
      throw ArgumentError.value(
          size, 'size', 'Must be a finite non-negative extent.');
    }
    final clamped = size
        .clamp(_minimumSizes[id] ?? 0, _maximumSizes[id] ?? double.infinity)
        .toDouble();
    if ((current.size - clamped).abs() < 0.01 && current.userSized) return;
    _states[id] = current.copyWith(size: clamped, userSized: true);
    notifyListeners();
  }

  /// Collapses [id] when its pane is configured as collapsible.
  void collapse(String id) {
    final state = _states[id];
    if (state == null || !_collapsible.contains(id) || state.collapsed) return;
    _states[id] = state.copyWith(collapsed: true);
    notifyListeners();
  }

  /// Expands [id] and restores its previous size.
  void expand(String id) {
    final state = _states[id];
    if (state == null || !state.collapsed) return;
    _states[id] = state.copyWith(collapsed: false);
    notifyListeners();
  }

  /// Toggles a pane's collapsed state.
  void toggle(String id) {
    if (_states[id]?.collapsed ?? false) {
      expand(id);
    } else {
      collapse(id);
    }
  }

  /// Restores the configured preferred size and expanded state.
  void reset(String id) {
    final state = _states[id];
    final preferred = _preferredSizes[id];
    if (state == null || preferred == null) return;
    _states[id] = FPaneState(size: preferred);
    notifyListeners();
  }

  /// Captures current state for app-owned persistence.
  FPaneSnapshot snapshot() => FPaneSnapshot(states);

  /// Restores a previously captured snapshot for panes known to this controller.
  void restore(FPaneSnapshot snapshot) {
    var changed = false;
    for (final entry in snapshot.panes.entries) {
      if (!_states.containsKey(entry.key)) {
        _pendingStates[entry.key] = entry.value;
        changed = true;
        continue;
      }
      final minimum = _minimumSizes[entry.key] ?? 0;
      final maximum = _maximumSizes[entry.key] ?? double.infinity;
      final next = entry.value.copyWith(
        size: entry.value.size.clamp(minimum, maximum).toDouble(),
        collapsed: _collapsible.contains(entry.key) && entry.value.collapsed,
      );
      if (_states[entry.key] != next) {
        _states[entry.key] = next;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }
}
