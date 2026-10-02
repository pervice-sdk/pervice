import 'package:flutter/widgets.dart';
import 'package:pervice/components/service.dart';
import 'package:pervice/components/service_id.dart';
import 'package:pervice/components/service_mode.dart';
import 'package:pervice/components/state_id.dart';
import 'package:pervice/components/state_mode.dart';
import 'package:pervice/widgets/service_scope.dart';
import 'package:pervice/widgets/state_scope.dart';

/// Provides convenience methods on [BuildContext] to retrieve,
/// manage, and react to application-wide services and state.
extension ServiceBuildContext on BuildContext {
  /// Retrieves or lazily creates a service of type [T], and binds
  /// its lifecycle to this [BuildContext]'s widget lifecycle.
  T serviceOf<T extends Service>(
    T Function() create, {
    Key? key,
    ServiceMode mode = ServiceMode.watch,
  }) {
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
  /// its [ValueNotifier] lifecycle to this [BuildContext]'s
  /// widget lifecycle.
  ///
  /// [onDispose] is called with the current value when
  /// the state is removed from its scope and disposed.
  ValueNotifier<T> stateOf<T>(
    T Function() create, {
    Key? key,
    StateMode mode = StateMode.watch,
    Function(T)? onDispose,
  }) {
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
  ValueNotifier<T> sharedStateOf<T>(
    T Function() create, {
    required Key key,
    StateMode mode = StateMode.watch,
    Function(T)? onDispose,
  }) {
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
}
