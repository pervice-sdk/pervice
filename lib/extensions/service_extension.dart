import 'package:flutter/widgets.dart';
import 'package:pervice/components/service.dart';

/// Extension that provides a Flutter widget builder for [Service] states.
extension ServiceExtension<T> on Service<T> {
  /// Returns a widget depending on the current [ServiceStatus].
  Widget when({
    Widget Function()? none,
    Widget Function()? loading,
    Widget Function(T data)? refresh,
    Widget Function(T data)? loaded,
    Widget Function(Object error)? failed,
  }) {
    final widget = switch (status) {
      .none => (none ?? loading)?.call(),
      .loading => loading?.call(),
      .refresh => (refresh ?? loaded)?.call(data),
      .loaded => loaded?.call(data),
      .failed => failed?.call(error),
    };

    if (widget == null) {
      throw UnimplementedError(
        "Service.when: Widget for $status is not implemented",
      );
    }

    return KeyedSubtree(key: ValueKey(status), child: widget);
  }

  /// Calls [callback] whenever the service notifies listeners while loaded.
  ///
  /// When used in a widget, prefer registering in `context.onInitState`.
  ///
  /// Listeners are automatically cleared when the service is disposed.
  /// To end the subscription when the widget is disposed,
  /// call the returned callback in `context.onDispose`.
  ///
  /// Returns a callback that removes the listener.
  VoidCallback onData(void Function(T data) callback) {
    void listener() {
      if (status == .loaded) {
        callback(data);
      }
    }

    addListener(listener);
    return () => removeListener(listener);
  }
}
