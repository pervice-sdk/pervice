import 'package:flutter/foundation.dart';

/// A [ValueNotifier] that supports explicit change notifications.
class ValueState<T> extends ValueNotifier<T> {
  ValueState(this.initialValue) : super(initialValue);

  /// The initial value of the state, stored without copying.
  final T initialValue;

  /// Notifies listeners that the state has changed.
  void notifyChanged() => notifyListeners();

  /// Resets the state to its initial value.
  void reset() => value = initialValue;
}
