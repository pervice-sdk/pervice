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
