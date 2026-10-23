import 'package:flutter/material.dart';
import 'package:pervice/pervice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('stateFor() retrieves matching state or throws', (tester) async {
    final firstKey = const ValueKey('first');
    final secondKey = const ValueKey('second');

    await tester.pumpWidget(
      StateScope(
        child: Builder(
          builder: (context) {
            final state = context.stateOf(() => 1, key: firstKey);

            // Retrieve the same instance using its type and key.
            expect(context.stateFor<int>(key: firstKey), same(state));

            // Reject a key that has not been registered.
            expect(() => context.stateFor<int>(key: secondKey), throwsStateError);

            // Reject a different type even when the key matches.
            expect(() => context.stateFor<String>(key: firstKey), throwsStateError);

            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('sharedStateFor() retrieves matching state or throws', (tester) async {
    final firstKey = const ValueKey('first');
    final secondKey = const ValueKey('second');
    late ValueState<int> sharedState;

    await tester.pumpWidget(
      StateScope(
        child: Column(
          children: [
            Builder(
              builder: (context) {
                // Register shared state in the first element.
                sharedState = context.sharedStateOf(() => 1, key: firstKey);

                return const SizedBox();
              },
            ),
            Builder(
              builder: (context) {
                // Retrieve the same instance from another element.
                expect(context.sharedStateFor<int>(key: firstKey), same(sharedState));

                // Reject a key that has not been registered.
                expect(() => context.sharedStateFor<int>(key: secondKey), throwsStateError);

                // Reject a different type even when the key matches.
                expect(() => context.sharedStateFor<String>(key: firstKey), throwsStateError);

                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('stateOf() returns different instances for no keys', (tester) async {
    late ValueState<int> state1;
    late ValueState<int> state2;

    await tester.pumpWidget(
      ServiceScope.withState(
        child: Builder(
          builder: (context) {
            state1 = context.stateOf(() => 1);
            state2 = context.stateOf(() => 2);
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(state1, isNot(same(state2)));
  });

  testWidgets('stateOf() returns different instances for different keys', (tester) async {
    late ValueState<int> state1;
    late ValueState<int> state2;

    await tester.pumpWidget(
      ServiceScope.withState(
        child: Builder(
          builder: (context) {
            state1 = context.stateOf(() => 1, key: ValueKey(1));
            state2 = context.stateOf(() => 2, key: ValueKey(2));
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(state1, isNot(same(state2)));
  });

  testWidgets('stateOf() rebuilds the widget when the value changes', (tester) async {
    late ValueState<int> state;

    await tester.pumpWidget(
      Directionality(
        textDirection: .ltr,
        child: ServiceScope.withState(
          child: Builder(
            builder: (context) {
              state = context.stateOf(() => 1, key: ValueKey(1));
              return Text(state.value.toString());
            },
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    state.value = 0;

    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('stateOf() creates separate states for different elements', (tester) async {
    late ValueState<int> state1;
    late ValueState<int> state2;

    final Key key = ValueKey(1);

    await tester.pumpWidget(
      Directionality(
        textDirection: .ltr,
        child: ServiceScope.withState(
          child: Column(
            mainAxisSize: .min,
            children: [
              Builder(
                builder: (context) {
                  state1 = context.stateOf(() => 1, key: key);
                  return SizedBox();
                },
              ),
              Builder(
                builder: (context) {
                  state2 = context.stateOf(() => 2, key: key);
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );

    expect(state1, isNot(state2));
  });

  testWidgets('sharedStateOf() shares state across elements with the same key', (tester) async {
    late ValueState<int> state1;
    late ValueState<int> state2;

    final Key key = ValueKey(1);

    await tester.pumpWidget(
      Directionality(
        textDirection: .ltr,
        child: ServiceScope.withState(
          child: Column(
            mainAxisSize: .min,
            children: [
              Builder(
                builder: (context) {
                  state1 = context.sharedStateOf(() => 1, key: key);
                  return SizedBox();
                },
              ),
              Builder(
                builder: (context) {
                  state2 = context.sharedStateOf(() => 2, key: key);
                  return SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );

    expect(state1, same(state2));
  });

  testWidgets('state is disposed when element is unmounted', (tester) async {
    var isDisposed = false;

    await tester.pumpWidget(
      ServiceScope.withState(
        child: Builder(
          builder: (context) {
            context.stateOf(() => 1, onDispose: (_) => isDisposed = true);
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpWidget(ServiceScope.withState(child: const SizedBox()));
    expect(isDisposed, true);
  });

  testWidgets('shared state is disposed when element is unmounted', (tester) async {
    const sharedKey = ValueKey('test');
    var isDisposed = false;

    Widget build({required bool first, required bool second}) {
      return ServiceScope.withState(
        child: Column(
          mainAxisSize: .min,
          children: [
            if (first) ...[
              Builder(
                key: const ValueKey('first'),
                builder: (context) {
                  context.sharedStateOf(
                    () => 1,
                    key: sharedKey,
                    onDispose: (_) => isDisposed = true,
                  );

                  return const SizedBox();
                },
              ),
            ],

            if (second) ...[
              Builder(
                key: const ValueKey('second'),
                builder: (context) {
                  context.sharedStateOf(() => 2, key: sharedKey);
                  return const SizedBox();
                },
              ),
            ],
          ],
        ),
      );
    }

    await tester.pumpWidget(build(first: true, second: true));
    expect(isDisposed, false);

    await tester.pumpWidget(build(first: false, second: true));
    expect(isDisposed, false);

    await tester.pumpWidget(build(first: false, second: false));
    expect(isDisposed, true);
  });

  testWidgets('stateOf() survives reparenting within the same frame', (tester) async {
    late ValueState<int> state;
    var disposeCount = 0;

    final child = Builder(
      key: GlobalKey(),
      builder: (context) {
        state = context.stateOf(() => 1, onDispose: (_) => disposeCount++);
        return const SizedBox();
      },
    );

    // Change the state before moving the widget.
    await tester.pumpWidget(
      StateScope(
        child: Padding(padding: .zero, child: child),
      ),
    );

    final original = state;
    original.value = 2;

    // Reparent the same element and retain its state.
    await tester.pumpWidget(StateScope(child: Align(child: child)));
    expect(disposeCount, 0);
    expect(state, same(original));
    expect(state.value, 2);

    // Dispose exactly once when the widget is permanently removed.
    await tester.pumpWidget(const StateScope(child: SizedBox()));
    expect(disposeCount, 1);

    await tester.pumpWidget(const SizedBox());
    expect(disposeCount, 1);
  });

  testWidgets('sharedStateOf() survives reparenting within the same frame', (tester) async {
    late ValueState<int> state;
    var disposeCount = 0;

    final child = Builder(
      key: GlobalKey(),
      builder: (context) {
        state = context.sharedStateOf(
          () => 1,
          key: const ValueKey('shared'),
          onDispose: (_) => disposeCount++,
        );
        return const SizedBox();
      },
    );

    // Change the shared state before moving the widget.
    await tester.pumpWidget(
      StateScope(
        child: Padding(padding: .zero, child: child),
      ),
    );

    final original = state;
    original.value = 2;

    // Reparent the same element and retain its shared state.
    await tester.pumpWidget(StateScope(child: Align(child: child)));
    expect(disposeCount, 0);
    expect(state, same(original));
    expect(state.value, 2);

    // Dispose exactly once when the last dependent is permanently removed.
    await tester.pumpWidget(const StateScope(child: SizedBox()));
    expect(disposeCount, 1);

    await tester.pumpWidget(const SizedBox());
    expect(disposeCount, 1);
  });

  testWidgets('stateOf() survives pushing and popping a route', (tester) async {
    late BuildContext homeContext;
    late ValueState<int> state;
    var disposeCount = 0;

    // Create the home state and change its value.
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => StateScope(child: child!),
        home: Builder(
          builder: (context) {
            homeContext = context;
            state = context.stateOf(
              () => 1,
              key: const ValueKey('state'),
              onDispose: (_) => disposeCount++,
            );

            return const SizedBox();
          },
        ),
      ),
    );

    final original = state;
    original.value = 2;

    // Cover the home route with a detail route, then return to it.
    Navigator.of(homeContext).push<void>(MaterialPageRoute(builder: (_) => const SizedBox()));
    await tester.pumpAndSettle();

    Navigator.of(homeContext).pop();
    await tester.pumpAndSettle();

    // The home state should retain its instance and value without disposal.
    expect(disposeCount, 0);
    expect(state, same(original));
    expect(state.value, 2);
  });

  testWidgets('sharedStateOf() survives pushing and popping a route', (tester) async {
    late BuildContext homeContext;
    late ValueState<int> state;
    var disposeCount = 0;

    // Create the shared home state and change its value.
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => StateScope(child: child!),
        home: Builder(
          builder: (context) {
            homeContext = context;
            state = context.sharedStateOf(
              () => 1,
              key: const ValueKey('shared'),
              onDispose: (_) => disposeCount++,
            );

            return const SizedBox();
          },
        ),
      ),
    );

    final original = state;
    original.value = 2;

    // Cover the home route with a detail route, then return to it.
    Navigator.of(homeContext).push<void>(MaterialPageRoute(builder: (_) => const SizedBox()));
    await tester.pumpAndSettle();

    Navigator.of(homeContext).pop();
    await tester.pumpAndSettle();

    // The shared state should retain its instance and value without disposal.
    expect(disposeCount, 0);
    expect(state, same(original));
    expect(state.value, 2);
  });

  testWidgets('stateOf() with read mode does not rebuild when the value changes', (tester) async {
    late ValueState<int> state;
    var buildCount = 0;

    await tester.pumpWidget(
      ServiceScope.withState(
        child: Builder(
          builder: (context) {
            buildCount++;
            state = context.stateOf(() => 1, mode: .read);
            return SizedBox();
          },
        ),
      ),
    );

    state.value = 2;

    await tester.pump();
    expect(buildCount, 1);
  });
}
