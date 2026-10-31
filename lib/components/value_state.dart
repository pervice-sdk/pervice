import 'package:flutter/material.dart';

/// A [ValueNotifier] that provides shorthand methods for reading and updating its value.
class ValueState<T> extends ValueNotifier<T> {
  ValueState(super.value);

  /// Returns the current value.
  T call() => value;

  /// Updates the current value.
  void set(T newValue) => value = newValue;
}
