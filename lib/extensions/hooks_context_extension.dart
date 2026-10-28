import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pervice/components/hook_ticker_provider.dart';
import 'package:pervice/extensions/build_context_extension.dart';

/// Provides a suite of custom hooks via [BuildContext] to manage the lifecycle
/// of common Flutter controllers and resource-heavy objects automatically.
extension HooksContextExtension on BuildContext {
  /// Creates and automatically disposes a [ScrollController].
  ScrollController useScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    ScrollControllerCallback? onAttach,
    ScrollControllerCallback? onDetach,
  }) {
    final state = stateOf(
      () => ScrollController(
        initialScrollOffset: initialScrollOffset,
        keepScrollOffset: keepScrollOffset,
        debugLabel: debugLabel,
        onAttach: onAttach,
        onDetach: onDetach,
      ),
      onDispose: (e) => e.dispose(),
    );

    return state.value;
  }

  /// Creates and automatically disposes a [PageController].
  PageController usePageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    ScrollControllerCallback? onAttach,
    ScrollControllerCallback? onDetach,
  }) {
    final state = stateOf(
      () => PageController(
        initialPage: initialPage,
        keepPage: keepPage,
        viewportFraction: viewportFraction,
        onAttach: onAttach,
        onDetach: onDetach,
      ),
      onDispose: (e) => e.dispose(),
    );

    return state.value;
  }

  /// Creates and automatically disposes a [TabController].
  TabController useTabController({
    int initialIndex = 0,
    Duration? animationDuration,
    required int length,
    TickerProvider? vsync,
  }) {
    final state = stateOf(
      () => TabController(
        initialIndex: initialIndex,
        animationDuration: animationDuration,
        length: length,
        vsync: vsync ?? useTickerProvider(),
      ),
      onDispose: (e) => e.dispose(),
    );

    return state.value;
  }

  /// Creates and automatically disposes a [TextEditingController].
  TextEditingController useTextEditingController({String? text}) {
    final state = stateOf(
      () => TextEditingController(text: text),
      onDispose: (e) => e.dispose(),
    );

    return state.value;
  }

  /// Creates and automatically disposes a [FocusNode].
  FocusNode useFocusNode({
    String? debugLabel,
    FocusOnKeyEventCallback? onKeyEvent,
    bool skipTraversal = false,
    bool canRequestFocus = true,
    bool descendantsAreFocusable = true,
    bool descendantsAreTraversable = true,
  }) {
    final state = stateOf(
      () => FocusNode(
        debugLabel: debugLabel,
        onKeyEvent: onKeyEvent,
        skipTraversal: skipTraversal,
        canRequestFocus: canRequestFocus,
        descendantsAreFocusable: descendantsAreFocusable,
        descendantsAreTraversable: descendantsAreTraversable,
      ),
      onDispose: (e) => e.dispose(),
    );

    return state.value;
  }

  /// Creates and automatically disposes a [TickerProvider].
  TickerProvider useTickerProvider() {
    final state = stateOf(
      HookTickerProvider.new,
      key: ValueKey(HookTickerProvider),
      onDispose: (e) => e.dispose(),
    );
    return state.value;
  }

  /// This is an alias for [useTickerProvider].
  TickerProvider useVsync() => useTickerProvider();

  /// Creates and automatically disposes an [AnimationController].
  AnimationController useAnimationController({
    double? value,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = .normal,
    TickerProvider? vsync,
  }) {
    final state = stateOf(
      () => AnimationController(
        value: value,
        duration: duration,
        reverseDuration: reverseDuration,
        debugLabel: debugLabel,
        lowerBound: lowerBound,
        upperBound: upperBound,
        animationBehavior: animationBehavior,
        vsync: vsync ?? useTickerProvider(),
      ),
      onDispose: (e) => e.dispose(),
    );

    return state.value;
  }

  /// Creates and automatically disposes an [CurvedAnimation].
  CurvedAnimation useCurvedAnimation({
    required Animation<double> parent,
    required Curve curve,
    Curve? reverseCurve,
  }) {
    final state = stateOf(
      () => CurvedAnimation(
        parent: parent,
        curve: curve,
        reverseCurve: reverseCurve,
      ),
      onDispose: (e) => e.dispose(),
    );

    return state.value;
  }

  /// Creates and automatically disposes a [StreamController].
  StreamController<T> useStreamController<T>({
    void Function()? onListen,
    void Function()? onPause,
    void Function()? onResume,
    FutureOr<void> Function()? onCancel,
    bool sync = false,
  }) {
    final state = stateOf(
      () => StreamController<T>(
        onListen: onListen,
        onPause: onPause,
        onResume: onResume,
        onCancel: onCancel,
        sync: sync,
      ),
      onDispose: (e) => e.close(),
    );

    return state.value;
  }

  /// Creates and automatically disposes a [StreamController.broadcast].
  StreamController<T> useStreamControllerBroadcast<T>({
    void Function()? onListen,
    void Function()? onCancel,
    bool sync = false,
  }) {
    final state = stateOf(
      () => StreamController<T>.broadcast(
        onListen: onListen,
        onCancel: onCancel,
        sync: sync,
      ),
      onDispose: (e) => e.close(),
    );

    return state.value;
  }

  /// Runs [callback] and marks a widget for rebuilding.
  ///
  /// Rebuilds the current widget when [T] is omitted or is [Widget].
  /// Otherwise, rebuilds the nearest ancestor whose widget is of type [T].
  void setState<T extends Widget>([VoidCallback? callback]) {
    callback?.call();

    // Marks the current element for rebuilding.
    if (T == Widget) {
      (this as Element).markNeedsBuild();
      return;
    }

    // Marks the nearest ancestor of type T for rebuilding.
    visitAncestorElements((element) {
      if (element.widget is T) {
        element.markNeedsBuild();
        return false;
      }

      return true;
    });
  }

  /// Runs [callback] once when first registered by this widget.
  void onInitState(VoidCallback callback) {
    stateOf(
      () {
        callback();
        return null;
      },
      key: const ValueKey(#onInitState),
      mode: .read,
    );
  }

  /// Runs the initially registered [callback] when this widget is removed.
  void onDispose(VoidCallback callback) {
    stateOf<VoidCallback>(
      () => callback,
      key: const ValueKey(#onDispose),
      mode: .read,
      onDispose: (callback) => callback(),
    );
  }

  /// Rebuilds this widget whenever [listener] notifies.
  /// Automatically removes the listener when the widget is disposed.
  void watch(Listenable listener) {
    stateOf<VoidCallback>(
      () {
        final VoidCallback callback = setState;
        listener.addListener(callback);
        return () => listener.removeListener(callback);
      },
      key: ObjectKey(listener),
      mode: .read,
      onDispose: (dispose) => dispose(),
    );
  }
}
