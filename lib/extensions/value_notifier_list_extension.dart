import 'package:flutter/widgets.dart';

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
