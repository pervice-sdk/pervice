import 'package:flutter/widgets.dart';
import 'package:pervice/components/state_id.dart';
import 'package:pervice/components/state_mode.dart';
import 'package:pervice/components/state_subscription.dart';

/// A widget that hosts the [StateScopeElement] to manage and
/// provide application-wide state down the widget subtree.
///
/// Only one [StateScope] should exist near the root of the widget tree.
class StateScope extends InheritedWidget {
  const StateScope({
    super.key,
    required super.child,
  });

  @override
  InheritedElement createElement() => StateScopeElement(this);

  @override
  bool updateShouldNotify(StateScope oldWidget) => false;

  /// Looks up the widget tree to find the active [StateScopeElement].
  static StateScopeElement? maybeElementOf(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<StateScope>();
    return element is StateScopeElement ? element : null;
  }
}

/// A stateful counter that tracks state invocation counts within a specific frame.
class _BuildCounter {
  /// The local index (sequence) of the requested state in the current build frame.
  int count = 0;

  /// The unique frame number when this counter was last accessed,
  /// used to detect when a new rebuild frame has started.
  int lastFrameNumber = -1;
}

class StateScopeElement extends InheritedElement {
  StateScopeElement(StateScope super.widget);

  /// Active state subscriptions mapped by their state [StateId].
  ///
  /// This serves as the single source of truth for both managing state instances
  /// (and their lifecycles) and tracking which elements are listening to them.
  final Map<StateId, StateSubscription> _subscriptions = {};

  /// Tracks the state id used by each dependent element.
  final Map<Element, Set<StateId>> _stateDependents = {};

  /// Generates automatic fallback keys when [StateId.key] is omitted.
  ///
  /// Tracks the invocation sequence per [Type] within the same build frame,
  /// enabling a safe, order-based automatic key assignment for each [Element].
  final Map<Element, Map<Type, _BuildCounter>> _elementKeyCounters = {};

  @override
  void mount(Element? parent, Object? newSlot) {
    if (parent?.getElementForInheritedWidgetOfExactType<StateScope>() != null) {
      throw FlutterError('Only one StateScope can exist in a widget tree.');
    }

    super.mount(parent, newSlot);
  }

  /// Ensures a state of type [T] is available, lazily creating
  /// it if necessary, and registers the [dependent] element.
  ValueNotifier<T> ensureState<T>(
    Element dependent,
    StateId id,
    StateMode mode,
    T Function() create,
    Function(T)? onDispose,
  ) {
    if (id.key == null) {
      assert(id.element != null, 'Shared state requires an explicit key.');

      final currentFrame = WidgetsBinding.instance.platformDispatcher.frameData.frameNumber;
      final counters = _elementKeyCounters.putIfAbsent(dependent, () => {});
      final counter = counters.putIfAbsent(T, () => _BuildCounter());

      if (counter.lastFrameNumber != currentFrame) {
        counter.count = 0;
        counter.lastFrameNumber = currentFrame;
      } else {
        counter.count += 1;
      }

      id = StateId(element: id.element, key: ValueKey(counter.count), type: T);
    }

    // Retrieve the existing state or lazily create a new one.
    final subscription = _subscriptions.putIfAbsent(id, () {
      final notifier = ValueNotifier(create());

      late final StateSubscription<T> sub;

      void listener() {
        for (final element in sub.watchers) {
          if (element.mounted) {
            element.markNeedsBuild();
          }
        }
      }

      notifier.addListener(listener);
      sub = StateSubscription(notifier: notifier, listener: listener, onDispose: onDispose);
      return sub;
    });

    // Register the dependency with Flutter's framework using the stateId as the aspect.
    dependent.dependOnInheritedWidgetOfExactType<StateScope>(aspect: id);

    // Track the element in either watchers or readers based on the requested [mode].
    if (mode == StateMode.watch) {
      subscription.watchers.add(dependent);
    } else {
      subscription.readers.add(dependent);
    }

    return subscription.notifier as ValueNotifier<T>;
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    super.updateDependencies(dependent, aspect);

    if (aspect is StateId) {
      _stateDependents.putIfAbsent(dependent, () => {}).add(aspect);
    }
  }

  @override
  void removeDependent(Element dependent) {
    final ids = _stateDependents.remove(dependent);

    if (ids is Set<StateId>) {
      for (final id in ids) {
        final subscription = _subscriptions[id];

        if (subscription != null) {
          subscription.watchers.remove(dependent);
          subscription.readers.remove(dependent);

          // Dispose of the state if it is no longer referenced by any widget.
          if (subscription.referenceCount == 0) {
            _subscriptions.remove(id)?.dispose();
          }
        }
      }
    }

    super.removeDependent(dependent);
  }

  @override
  void unmount() {
    for (var sub in _subscriptions.values) {
      sub.dispose();
    }

    _subscriptions.clear();
    _stateDependents.clear();
    super.unmount();
  }

  @override
  Widget build() {
    _elementKeyCounters.clear();
    return super.build();
  }
}
