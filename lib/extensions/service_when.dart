import 'package:flutter/widgets.dart';
import 'package:pervice/components/service.dart';

/// Extension that provides a Flutter widget builder for [Service] states.
extension ServiceWhen<T> on Service<T> {
  /// Returns a widget depending on the current [ServiceStatus].
  Widget when({
    Widget Function()? none,
    Widget Function()? loading,
    Widget Function(T data)? refresh,
    Widget Function(T data)? loaded,
    Widget Function(Object error)? failed,
  }) {
    final widget = switch (status) {
      ServiceStatus.none => (none ?? loading)?.call(),
      ServiceStatus.loading => loading?.call(),
      ServiceStatus.refresh => (refresh ?? loaded)?.call(data),
      ServiceStatus.loaded => loaded?.call(data),
      ServiceStatus.failed => failed?.call(error),
    };

    if (widget == null) {
      throw UnimplementedError(
        "Service.when: Widget for $status is not implemented",
      );
    }

    return KeyedSubtree(key: ValueKey(status), child: widget);
  }
}
