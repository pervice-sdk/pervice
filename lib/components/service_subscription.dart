import 'package:flutter/widgets.dart';
import 'package:pervice/components/service.dart';

/// Manages the connection between a [Service] and the elements depending on it.
///
/// This class acts as a bridge that registers event listeners, tracks active
/// [watchers] and [readers], and disposes of the service once it has no dependents.
class ServiceSubscription {
  ServiceSubscription({
    required this.service,
    required this.listener,
  });

  /// The active service instance being managed.
  final Service service;

  /// The callback listener that triggers whenever the [service] notifies changes.
  final VoidCallback listener;

  /// Elements actively watching this service.
  final Set<Element> watchers = {};

  /// Elements only reading this service.
  final Set<Element> readers = {};

  /// The total number of dependent elements
  /// (both readers and watchers) relying on this service.
  int get referenceCount => watchers.length + readers.length;

  /// Unbinds the listener from the service, stopping any future update notifications.
  void cancel() => service.removeListener(listener);

  /// Cancels the subscription and releases all resources associated with the service.
  void dispose() {
    cancel();
    service.dispose();
  }
}
