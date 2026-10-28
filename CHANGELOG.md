## 1.0.0

- Initial release of Pervice.
- Successor to `mvvm_service`.
- Redesigned around Flutter widget lifecycle and providerless services.

## 1.1.0

- Added `Service.request()` for one-time data requests that require a result.
- Added `Service.requestOrNull()` for one-time data requests with an optional result.

## 1.2.0

- **Breaking:** Changed `Service.canRethrow` to `true` by default, so loading errors are rethrown unless explicitly disabled.
- **Breaking:** Renamed `Service.notifyUpdated()` to `Service.notifyChanged()`.
- **Breaking:** Removed `Service.canDebugPrint` and automatic error logging.
- Made `vsync` optional in `useTabController()` and `useAnimationController()`, using `useTickerProvider()` when omitted.

## 1.2.0+1

- **Breaking:** Renamed `Service.isError` to `Service.hasError`.
- Updated the README and example to use the current service API.
- Corrected the README's error handling documentation to reflect rethrowing errors by default and the removal of automatic error logging.
- Changed `Service.requestOrNull()` to return `null` instead of rethrowing loading errors.
- Updated `useTickerProvider()` to reuse a single ticker provider within the same widget, including animation hooks that omit `vsync`.

## 1.3.0

- Added `BuildContext.setState()` to request a rebuild of the current widget or the nearest ancestor of a specified widget type, with an optional callback.
- Added `BuildContext.onInitState()` and `BuildContext.onDispose()` for one-time initialization and cleanup callbacks tied to the calling widget lifecycle.

## 1.3.1

- Restored `Service.canRethrow` to `false` by default.

## 1.3.2

- Changed `Service.request()` to call `fetchData()` directly instead of `load()` and propagate errors regardless of `canRethrow`.
- Added an assertion that `Service.request()` starts with `ServiceStatus.none` for one-time use.
- Changed `Service.requestOrNull()` to delegate to `request()` and return `null` on failure instead of returning existing data.

## 1.3.3

- Fixed `Service.data` to support `void` and nullable data types without throwing on successful loads or requests.

## 1.3.4

- Fixed services and states being disposed during widget reparenting by deferring cleanup until the end of the frame and checking for remaining dependents.

## 1.3.5

- Added `BuildContext.watch(Listenable)` to rebuild the calling widget on notifications and automatically remove the listener when the widget is disposed.

## 1.3.6

- Added `ValueNotifierListExtension` with `add()`, `addAll()`, `remove()`, `removeAt()`, and `clear()` to simplify list state management and notify listeners on changes.

## 1.3.7

- Fixed `BuildContext.watch()` to subscribe to multiple listenables within the same widget and remove all listeners when the widget is disposed.
- Updated the `equatable` dependency constraint to `^3.0.0`.

## 1.3.8

- Added `Service.onData()` to receive data when the service notifies listeners while loaded, returning a callback to remove the listener.
- Added `ValueState<T>` as an alias for `ValueNotifier<T>` to clarify the return type of `stateOf`.

## 1.4.0

- **Breaking:** Changed `Service.fail()` to require an `Object` error and a `StackTrace`. Update overrides and calls to `fail(error, stackTrace)`.
- **Breaking:** Changed the `Service.when()` failure callback to receive `(error, stackTrace)`.
- Added `Service.stackTrace` and `Service.maybeStackTrace`, preserving the original stack trace when `load()` or `request()` fails.

## 1.5.0

- Added `BuildContext.serviceFor()`, `stateFor()`, and `sharedStateFor()` to retrieve existing services and state by type and key, with watch/read modes and a `StateError` when no matching instance exists.
- Added `ValueNotifierExtension` with `getter()` and `setter()`, and `ValueNotifierBoolExtension` with `toggle()` to simplify state management.

## 1.5.1

- Added `ValueNotifier<bool>.run()` to set the value to `true` while an async callback runs and reset it to `false` even if the callback throws.
- Added a package screenshot for pub.dev.

## 1.5.2

- Added `BuildContext.useCurvedAnimation()` to create a `CurvedAnimation` and automatically dispose it when the widget is removed.
- Added `BuildContext.useStreamSubscription()` to create a `StreamSubscription` and automatically cancel it when the widget is removed.
