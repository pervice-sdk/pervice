import 'package:flutter/material.dart';

/// A [ValueNotifier] that provides shorthand methods for reading and updating its value.
class ValueState<T> extends ValueNotifier<T> {
  ValueState(super.value);

  /// Notifies listeners that the state has changed.
  void notifyChanged() => notifyListeners();
}
