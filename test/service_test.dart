import 'package:flutter/widgets.dart';
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
      final service = TestService(isThrowError: true);
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

  test('ignores a load result after dispose', () async {
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
        textDirection: TextDirection.ltr,
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
        textDirection: TextDirection.ltr,
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
}
