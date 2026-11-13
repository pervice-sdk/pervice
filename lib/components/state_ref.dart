import 'package:flutter/material.dart';
import 'package:pervice/pervice.dart';

/// A typed reference to shared state identified by a key.
class StateRef<T extends Object?> extends LocalKey {
  const StateRef()
    : assert(
        T != dynamic,
        'Specify a concrete shared state type for StateRef<T>.',
      );

  /// Retrieves the shared state associated with this reference from [context].
  ValueState<T> of(BuildContext context) {
    return context.stateFor<T>(key: this);
  }

  @override
  String toString() => '[#$hashCode]';
}
