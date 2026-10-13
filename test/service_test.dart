import 'package:flutter/material.dart';
import 'package:pervice/pervice.dart';
import 'package:flutter_test/flutter_test.dart';

import 'lib/test_service.dart';

void main() {
  test("Initial state of the service should be none", () {
    final service = TestService();
    expect(service.status, ServiceStatus.none);
    expect(service.maybeData, isNull);
    expect(service.maybeError, isNull);
  });

  test(
    "load() should change status from loading to loaded and set data",
    () async {
      final service = TestService();
      final future = service.load();

      expect(service.status, ServiceStatus.loading);

      await future;

      expect(service.status, ServiceStatus.loaded);
      expect(service.data, TestService.sampleData);
      expect(service.maybeError, isNull);
    },
  );

  test(
    "load() should change status to failed when fetchData throws an error",
    () async {
      final service = TestService(throwError: true);
      final future = service.load();

      expect(service.status, ServiceStatus.loading);

      await future;

      expect(service.status, ServiceStatus.failed);
      expect(service.maybeData, isNull);
      expect(service.maybeError, TestService.sampleError);
    },
  );

  test("refresh() should keep existing data while loading new data", () async {
    final service = TestService();
    await service.load();

    final future = service.refresh();
    expect(service.data, TestService.sampleData);
    expect(service.status, ServiceStatus.refresh);

    await future;

    expect(service.status, ServiceStatus.loaded);
  });

  testWidgets("serviceOf() returns the correct service", (tester) async {
    late TestService1 service1;
    late TestService2 service2;

    await tester.pumpWidget(
      ServiceScope(
        child: Builder(
          builder: (context) {
            service1 = context.serviceOf(TestService1.new);
            service2 = context.serviceOf(TestService2.new);
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(service1, isNot(service2));
  });

  testWidgets("service is disposed when element is unmounted", (tester) async {
    late TestService1 service1;
    late TestService2 service2;

    await tester.pumpWidget(
      ServiceScope(
        child: Builder(
          builder: (context) {
            service1 = context.serviceOf(TestService1.new);
            service2 = context.serviceOf(TestService2.new);
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(service1.isDisposed, isFalse);
    expect(service2.isDisposed, isFalse);

    await tester.pumpWidget(const ServiceScope(child: SizedBox()));
    expect(service1.isDisposed, isTrue);
    expect(service2.isDisposed, isTrue);
  });

  test('service ignores a load result after dispose', () async {
    final service = TestService();
    final loading = service.load();
    service.dispose();

    await expectLater(loading, completes);
    expect(service.maybeData, isNull);
  });

  testWidgets('serviceOf() returns different instances for different keys', (tester) async {
    late TestService service1;
    late TestService service2;

    await tester.pumpWidget(
      ServiceScope(
        child: Builder(
          builder: (context) {
            service1 = context.serviceOf(TestService.new, key: ValueKey(1));
            service2 = context.serviceOf(TestService.new, key: ValueKey(2));
            return SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(service1, isNot(same(service2)));
  });

  testWidgets('serviceOf() rebuilds the widget when the service status changes', (tester) async {
    late TestService service;

    await tester.pumpWidget(
      Directionality(
        textDirection: .ltr,
        child: ServiceScope.withState(
          child: Builder(
            builder: (context) {
              service = context.serviceOf(TestService.new);
              return Text(service.status.name.toString());
            },
          ),
        ),
      ),
    );

    expect(find.text('loading'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('loaded'), findsOneWidget);
  });

  testWidgets('serviceOf() rebuilds the widget when the service data changes', (tester) async {
    late TestService service;

    await tester.pumpWidget(
      Directionality(
        textDirection: .ltr,
        child: ServiceScope.withState(
          child: Builder(
            builder: (context) {
              service = context.serviceOf(TestService.new);
              return Text(service.maybeData.toString());
            },
          ),
        ),
      ),
    );

    expect(find.text('null'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text(TestService.sampleData), findsOneWidget);
    service.data = "Hello, World! 2";

    await tester.pumpAndSettle();
    expect(find.text(service.data), findsOneWidget);
  });

  testWidgets('serviceOf() with read mode does not rebuild when the service changes', (tester) async {
    late TestService service;
    var buildCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: .ltr,
        child: ServiceScope.withState(
          child: Builder(
            builder: (context) {
              buildCount++;
              service = context.serviceOf(TestService.new, mode: .read);
              return SizedBox();
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    service.data = 'updated';

    await tester.pump();
    expect(buildCount, 1);
  });

  testWidgets('service survives reparenting within the same frame', (tester) async {
    late TestService service;

    final child = Builder(
      key: GlobalKey(),
      builder: (context) {
        service = context.serviceOf(TestService.new);
        return const SizedBox();
      },
    );

    // Load the service and change its data before moving the widget.
    await tester.pumpWidget(
      ServiceScope(
        child: Padding(padding: .zero, child: child),
      ),
    );

    await tester.pumpAndSettle();

    final original = service;
    original.data = 'updated';

    // Reparent the same element without removing it permanently.
    await tester.pumpWidget(ServiceScope(child: Align(child: child)));
    await tester.pumpAndSettle();

    // The existing service and its data should remain available.
    expect(original.isDisposed, isFalse);
    expect(service, same(original));
    expect(service.data, 'updated');
  });

  testWidgets('service survives pushing and popping a route', (tester) async {
    late BuildContext homeContext;
    late TestService service;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return ServiceScope(child: child!);
        },
        home: Builder(
          builder: (context) {
            homeContext = context;
            service = context.serviceOf(TestService.new);
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final original = service;
    original.data = 'updated';

    // Cover the home route with a detail route, then return to it.
    Navigator.of(homeContext).push<void>(MaterialPageRoute(builder: (_) => const SizedBox()));
    await tester.pumpAndSettle();

    Navigator.of(homeContext).pop();
    await tester.pumpAndSettle();

    // Returning to the home route should retain the service and its data.
    expect(original.isDisposed, isFalse);
    expect(service, same(original));
    expect(service.data, 'updated');
  });

  test("load() supports void data", () async {
    final service = TestVoidService();
    addTearDown(service.dispose);

    await service.load();

    expect(service.status, ServiceStatus.loaded);
    expect(() => service.data, returnsNormally);
  });

  test("request() completes for void data", () async {
    await expectLater(TestVoidService().request(), completes);
  });
}
