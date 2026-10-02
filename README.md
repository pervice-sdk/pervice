<div align="center">
  <img width="200px" src="https://github.com/pervice-sdk/pervice/raw/refs/heads/main/image/logo.png">
  <h1>Pervice</h1>
  <p>
    A Flutter-native MVVM service layer that creates, loads, watches,<br>
    shares, and disposes services according to the widget lifecycle.
  </p>
</div>

## Why Pervice?

| Feature | Description |
| ------- | ----------- |
| 🍃 **Minimal setup** | Create services where they are first used—no registration or generated code. |
| ⏳ **Async state** | Built-in loading, refresh, loaded, and error states. |
| 🔔 **Reactive lifecycle** | Rebuilds watchers and disposes unused services automatically. |
| 🔑 **Keyed sharing** | Share or separate services by type and optional key. |
| 💡 **Reactive state** | Create element-scoped or shared state with `context.stateOf()`. |

## Quick Start

### 1. Define a service

Extend `Service<T>` and implement `fetchData()`:

```dart
class CounterService extends Service<int> {
  int count = 0;

  @override
  Future<int> fetchData() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return ++count;
  }
}
```

When the service is first created, `load()` is called automatically. The value returned by `fetchData()` becomes `data` and the status changes to `ServiceStatus.loaded`.

### 2. Add one ServiceScope

Place a single `ServiceScope` near the root of the widget tree:

```dart
void main() {
  runApp(
    const ServiceScope(
      child: MainApp(),
    ),
  );
}
```

Only one `ServiceScope` may exist in a widget tree. It owns all active service instances and manages their subscriptions and lifecycles.

### 3. Use the service

Call `context.serviceOf()` from a widget:

```dart
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.serviceOf(CounterService.new);

    if (service.isLoading) {
      return const CircularProgressIndicator();
    }

    if (service.isError) {
      return Text('Failed: ${service.error}');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: service.isRefreshing ? 0.5 : 1,
          child: Text('${service.data}'),
        ),
        TextButton(
          onPressed: service.refresh,
          child: const Text('Refresh'),
        ),
      ],
    );
  }
}
```

`serviceOf()` lazily creates `CounterService`, starts its initial load, and rebuilds `CounterView` whenever the service changes.

## Watch and Read Modes

`ServiceMode.watch` is the default. It subscribes the calling element to service updates:

```dart
final service = context.serviceOf(CounterService.new);
```

This is equivalent to:

```dart
final service = context.serviceOf(CounterService.new, mode: .watch);
```

Use `ServiceMode.read` when the widget needs the instance without rebuilding when it changes:

```dart
final service = context.serviceOf(CounterService.new, mode: .read);
```

Read mode still associates the service with the calling element for lifecycle management. It only disables reactive rebuilds.

Each service is independently created, shared, watched, and disposed.

## Reactive State

Use `context.stateOf()` for simple reactive values that do not need a full `Service`. Enable state support with `ServiceScope.withState`:

```dart
void main() {
  runApp(
    ServiceScope.withState(
      child: const MainApp(),
    ),
  );
}
```

You can also place a standalone `StateScope` around only the subtree that needs state.

`stateOf()` returns a `ValueNotifier<T>` and rebuilds the calling widget when its value changes:

```dart
class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = context.stateOf(() => 0);

    return TextButton(
      onPressed: () => counter.value++,
      child: Text('${counter.value}'),
    );
  }
}
```

Each state belongs to the element that calls `stateOf()`. Unkeyed calls within that element are identified by their type and invocation order. Keep calls in a stable order, or provide a key when calls may be conditional or reordered:

```dart
final counter = context.stateOf(() => 0, key: const ValueKey('counter'));
```

By default, different elements receive separate state instances. Use `sharedStateOf()` with an explicit key to share state across elements under the same `StateScope`:

```dart
final counter = context.sharedStateOf(
  () => 0,
  key: const ValueKey('shared-counter'),
);
```

Calls to `sharedStateOf()` using the same type and key return the same notifier. The first creation callback supplies its initial value.

Use `StateMode.read` to access the notifier without rebuilding the widget when its value changes:

```dart
final counter = context.stateOf(() => 0, mode: .read);
```

Use `onDispose` to clean up resources held by the state. The callback receives the state's last value when it is removed from the scope:

```dart
final controller = context.stateOf(
  TextEditingController.new,
  onDispose: (controller) => controller.dispose(),
);
```

Local state is retained across rebuilds and disposed when its owning element is removed. Shared state remains active until its last dependent element is removed.

## BuildContext Hooks

Common Flutter controllers can be created directly from `BuildContext` without converting a widget to `StatefulWidget`. Hooks use `stateOf()` internally, so the widget tree must include `StateScope` or `ServiceScope.withState`.

```dart
class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.useScrollController();

    return ListView.builder(
      controller: controller,
      itemCount: 100,
      itemBuilder: (context, index) => ListTile(
        title: Text('Item $index'),
      ),
    );
  }
}
```

The controller is reused across rebuilds of the calling element, isolated from controllers created by other elements, and disposed automatically when its element is removed.

Available hooks:

| Hook | Creates |
| --- | --- |
| `useScrollController()` | `ScrollController` |
| `usePageController()` | `PageController` |
| `useTabController()` | `TabController` |
| `useTextEditingController()` | `TextEditingController` |
| `useFocusNode()` | `FocusNode` |
| `useTickerProvider()` / `useVsync()` | `TickerProvider` |
| `useAnimationController()` | `AnimationController` |
| `useStreamController<T>()` | `StreamController<T>` |
| `useStreamControllerBroadcast<T>()` | `StreamController<T>.broadcast` |

Hooks that animate require a ticker provider:

```dart
final vsync = context.useVsync();
final animation = context.useAnimationController(
  vsync: vsync,
  duration: const Duration(milliseconds: 300),
);
```

Call hooks during `build` and keep calls in a stable, unconditional order so they retain the correct instances across rebuilds.

## Declarative State Handling

The `when` extension maps every `ServiceStatus` to a widget:

```dart
@override
Widget build(BuildContext context) {
  final service = context.serviceOf(CounterService.new);

  return service.when(
    none: () => const Text('Idle'),
    loading: () => const CircularProgressIndicator(),
    refresh: (data) => Text('Refreshing: $data'),
    loaded: (data) => Text('Count: $data'),
    failed: (error) => Text('Failed: $error'),
  );
}
```

`none` falls back to `loading` when omitted, and `refresh` falls back to `loaded` when omitted.

## Service State

Every service exposes:

| API | Description |
| --- | --- |
| `status` | Current `ServiceStatus` |
| `isLoading` | `true` while idle or loading |
| `isRefreshing` | `true` during a refresh |
| `isError` | `true` after a failed load |
| `data` | Loaded data; intended for loaded or refreshing states |
| `maybeData` | Current data, or `null` when unavailable |
| `error` | Current error in the failed state |
| `maybeError` | Current error, or `null` when unavailable |
| `load()` | Loads data and replaces the current state |
| `refresh()` | Reloads while retaining existing data |
| `notifyUpdated()` | Notifies watching widgets after a custom state change |

You can also assign `data` directly. A changed value automatically notifies watching widgets:

```dart
service.data = 42;
```

## Lifecycle

Services are cached by their requested generic type and optional key inside `ServiceScope`. Without a key, requests for the same type reuse the first active instance, even when they use different factories or constructor arguments:

```dart
final first = context.serviceOf(() => UserService(userId: 1));
final second = context.serviceOf(() => UserService(userId: 2));

identical(first, second); // true
```

Use keys when independently configured instances of the same service type are required:

```dart
final first = context.serviceOf(() => UserService(userId: 1), key: const ValueKey(1));
final second = context.serviceOf(() => UserService(userId: 2), key: const ValueKey(2));

identical(first, second); // false
```

Requests with equal keys share the same instance. Use stable keys such as `ValueKey`; creating a new `UniqueKey` during every build creates a new service each time.

A service accessed by an element remains associated with that element until it is removed from the widget tree, even if a later build no longer requests that service or uses a different key.

## Error Handling

Errors thrown by `fetchData()` are captured automatically:

```dart
class UserService extends Service<User> {
  @override
  Future<User> fetchData() => api.fetchUser();
}
```

On failure:

- `status` becomes `ServiceStatus.failed`.
- `isError` becomes `true`.
- The exception is available through `error` and `maybeError`.
- The error is printed with `debugPrint` by default.

Override these properties to customize error behavior:

```dart
@override
bool get canRethrow => true;

@override
bool get canDebugPrint => false;
```
