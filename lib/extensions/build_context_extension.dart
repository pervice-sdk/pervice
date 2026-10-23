import 'package:flutter/widgets.dart';
import 'package:pervice/components/service_id.dart';
import 'package:pervice/pervice.dart';

/// Provides convenience methods on [BuildContext] to retrieve,
/// manage, and react to application-wide services and state.
extension BuildContextExtension on BuildContext {
  /// Retrieves or lazily creates a service of type [T], and binds
  /// its lifecycle to this [BuildContext]'s widget lifecycle.
  T serviceOf<T extends Service>(
    T Function() create, {
    Key? key,
    ServiceMode mode = .watch,
  }) {
    assert(T != Service, 'Specify a concrete service type.');

    final element = getElementForInheritedWidgetOfExactType<ServiceScope>();
    if (element is! ServiceScopeElement) {
      throw FlutterError(
        'ServiceScope was not found above this BuildContext.\n'
        'Please ensure ServiceScope is placed near the root of your widget tree.',
      );
    }

    final id = ServiceId(key: key, type: T);
    return element.ensureService<T>(this as Element, id, mode, create);
  }

  /// Retrieves or lazily creates a state of type [T], and binds
  /// its [ValueState] lifecycle to this [BuildContext]'s
  /// widget lifecycle.
  ///
  /// [onDispose] is called with the current value when
  /// the state is removed from its scope and disposed.
  ValueState<T> stateOf<T>(
    T Function() create, {
    Key? key,
    StateMode mode = .watch,
    Function(T)? onDispose,
  }) {
    assert(T != dynamic, 'Specify a concrete state type.');

    final element = getElementForInheritedWidgetOfExactType<StateScope>();
    if (element is! StateScopeElement) {
      throw FlutterError(
        'StateScope was not found above this BuildContext.\n'
        'Place StateScope above this context or use ServiceScope.withState.',
      );
    }

    final dependent = this as Element;
    final id = StateId(element: dependent, key: key, type: T);
    return element.ensureState<T>(dependent, id, mode, create, onDispose);
  }

  /// Retrieves or lazily creates state shared by [key]
  /// across elements under the same [StateScope].
  ///
  /// [onDispose] is called with the current value when
  /// the last dependent element is removed and
  /// the shared state is disposed.
  ValueState<T> sharedStateOf<T>(
    T Function() create, {
    required Key key,
    StateMode mode = .watch,
    Function(T)? onDispose,
  }) {
    assert(T != dynamic, 'Specify a concrete shared state type.');

    final element = getElementForInheritedWidgetOfExactType<StateScope>();
    if (element is! StateScopeElement) {
      throw FlutterError(
        'StateScope was not found above this BuildContext.\n'
        'Place StateScope above this context or use ServiceScope.withState.',
      );
    }

    final dependent = this as Element;
    final id = StateId(element: null, key: key, type: T);
    return element.ensureState<T>(dependent, id, mode, create, onDispose);
  }

  /// Retrieves an existing service by type and optional key.
  /// Throws a [StateError] if no matching service is registered.
  T serviceFor<T extends Service>({
    Key? key,
    ServiceMode mode = .watch,
  }) {
    return serviceOf(
      () => throw StateError('No service registered for type $T and key $key.'),
      key: key,
      mode: mode,
    );
  }

  /// Retrieves existing state owned by this element by type and key.
  /// Throws a [StateError] if no matching state is registered.
  ValueState<T> stateFor<T>({
    required Key key,
    StateMode mode = .watch,
  }) {
    return stateOf<T>(
      () => throw StateError('No state registered for type $T and key $key.'),
      key: key,
      mode: mode,
    );
  }

  /// Retrieves existing shared state by type and key within the same [StateScope].
  /// Throws a [StateError] if no matching shared state is registered.
  ValueState<T> sharedStateFor<T>({
    required Key key,
    StateMode mode = .watch,
  }) {
    return sharedStateOf<T>(
      () => throw StateError('No shared state registered for type $T and key $key.'),
      key: key,
      mode: mode,
    );
  }
}
