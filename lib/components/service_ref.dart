import 'package:flutter/material.dart';
import 'package:pervice/pervice.dart';

/// A typed reference used to look up a service by its key.
class ServiceRef<T extends Service> extends LocalKey {
  const ServiceRef()
    : assert(
        T != Service,
        'Specify a concrete service type for ServiceRef<T>.',
      );

  /// Retrieves the service associated with this reference from [context].
  T of(BuildContext context) {
    return context.serviceFor<T>(key: this);
  }

  @override
  String toString() => '[#$hashCode]';
}
