import 'package:flutter/foundation.dart';

/// Provides convenience methods to simplify state management.
extension ValueNotifierExtension<T> on ValueNotifier<T> {
  /// Returns true if the current value is not null.
  bool get hasValue => value != null;

  /// Returns true if the current value is null.
  bool get hasNoValue => value == null;

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
  /// Returns true if the list is empty.
  bool get isEmpty => value.isEmpty;

  /// Returns true if the list is not empty.
  bool get isNotEmpty => value.isNotEmpty;

  /// Returns the number of elements in the list.
  int get length => value.length;

  /// Returns the first element of the list.
  T get first => value.first;

  /// Returns the first element of the list or null if the list is empty.
  T? get firstOrNull => value.firstOrNull;

  /// Returns the last element of the list.
  T get last => value.last;

  /// Returns the last element of the list or null if the list is empty.
  T? get lastOrNull => value.lastOrNull;

  /// Returns the single element of the list.
  T get single => value.single;

  /// Returns the single element of the list or null if the list is empty.
  T? get singleOrNull => value.singleOrNull;

  /// Returns the element at the given index.
  T operator [](int index) => value[index];

  /// Replaces the element at the given index and notifies listeners.
  void operator []=(int index, T element) {
    value = value.toList()..[index] = element;
  }

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
