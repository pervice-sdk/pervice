import 'package:flutter/widgets.dart';

/// Manages the connection between a state and the elements depending on it.
///
/// This class acts as a bridge that registers event listeners, tracks active
/// [watchers] and [readers], and disposes of the state once it has no dependents.
class StateSubscription<T> {
  StateSubscription({
    required this.notifier,
    required this.listener,
    this.onDispose,
  });

  /// The active state notifier instance being managed.
  final ValueNotifier<T> notifier;

  /// The callback listener that triggers whenever the state notifies changes.
  final VoidCallback listener;

  /// The callback invoked with the current state value when this subscription is disposed.
  final Function(T)? onDispose;

  /// Elements actively watching this state.
  final Set<Element> watchers = {};

  /// Elements only reading this state.
  final Set<Element> readers = {};

  /// The total number of dependent elements
  /// (both readers and watchers) relying on this state.
  int get referenceCount => watchers.length + readers.length;

  /// Unbinds the listener from the notifier, stopping future update notifications.
  void cancel() => notifier.removeListener(listener);

  /// Cancels the subscription and releases all resources associated with the state.
  void dispose() {
    cancel();
    notifier.dispose();
    onDispose?.call(notifier.value);
  }
}
