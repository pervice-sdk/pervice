import 'package:flutter/foundation.dart';

/// Provides convenience methods to simplify state management.
extension ValueNotifierExtension<T> on ValueNotifier<T> {
  /// Updates the notifier with the given value.
  void setter(T newValue) {
    value = newValue;
  }

  /// Returns the current value.
  T getter() => value;
}

/// Provides convenience methods to simplify boolean state management.
extension ValueNotifierBoolExtension on ValueNotifier<bool> {
  /// Reverses the current boolean value.
  void toggle() {
    value = !value;
  }

  /// Sets the value to true while the callback
  /// runs and resets it to false afterward.
  Future<void> run(AsyncCallback callback) async {
    try {
      value = true;
      await callback();
    } finally {
      value = false;
    }
  }
}

/// Provides convenience methods to simplify list state management.
extension ValueNotifierListExtension<T> on ValueNotifier<List<T>> {
  /// Appends [element] to the list and notifies listeners.
  void add(T element) {
    value = [...value, element];
  }

  /// Appends all [elements] and notifies listeners.
  void addAll(Iterable<T> elements) {
    value = [...value, ...elements];
  }

  /// Removes the first occurrence of [element] and notifies listeners.
  void remove(T element) {
    value = List.of(value)..remove(element);
  }

  /// Removes the element at [index] and notifies listeners.
  /// Throws a [RangeError] if [index] is out of range.
  void removeAt(int index) {
    value = List.of(value)..removeAt(index);
  }

  /// Removes all elements and notifies listeners.
  void clear() => value = [];
}
