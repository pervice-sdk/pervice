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
