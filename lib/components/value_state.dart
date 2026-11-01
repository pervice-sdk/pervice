import 'package:flutter/material.dart';

/// A [ValueNotifier] that provides shorthand methods for reading and updating its value.
class ValueState<T> extends ValueNotifier<T> {
  ValueState(super.value);

  /// Returns the current value.
  T get it => value;

  /// Updates the current value.
  set it(T newValue) => value = newValue;

  /// Notifies listeners that the state has changed.
  void notifyChanged() => notifyListeners();
}
