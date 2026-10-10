import 'package:flutter/widgets.dart';
import 'package:pervice/pervice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("setState() rebuilds only the current widget", (tester) async {
    late BuildContext testContext;
    var parentBuildCount = 0;
    var targetBuildCount = 0;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          parentBuildCount++;

          return Builder(
            builder: (context) {
              testContext = context;
              targetBuildCount++;
              return const SizedBox();
            },
          );
        },
      ),
    );

    expect(parentBuildCount, 1);
    expect(targetBuildCount, 1);

    testContext.setState();
    await tester.pump();

    expect(parentBuildCount, 1);
    expect(targetBuildCount, 2);
  });

  testWidgets("setState<T>() rebuilds only the matching ancestor", (tester) async {
    late BuildContext testContext;
    var parentBuildCount = 0;
    var targetBuildCount = 0;
    var childBuildCount = 0;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          parentBuildCount++;

          return ListenableBuilder(
            listenable: .merge([]),
            builder: (context, child) {
              targetBuildCount++;

              return Builder(
                builder: (context) {
                  testContext = context;
                  childBuildCount++;
                  return const SizedBox();
                },
              );
            },
          );
        },
      ),
    );

    expect(parentBuildCount, 1);
    expect(targetBuildCount, 1);
    expect(childBuildCount, 1);

    testContext.setState<ListenableBuilder>();
    await tester.pump();

    expect(parentBuildCount, 1);
    expect(targetBuildCount, 2);
    expect(childBuildCount, 2);
  });

  testWidgets("onInitState() runs once across rebuilds", (tester) async {
    late BuildContext testContext;
    var callCount = 0;

    await tester.pumpWidget(
      StateScope(
        child: Builder(
          builder: (context) {
            testContext = context;
            context.onInitState(() => callCount++);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(callCount, 1);
    testContext.setState();

    await tester.pump();
    expect(callCount, 1);
  });

  testWidgets("onDispose() runs once when the widget is removed", (tester) async {
    late BuildContext testContext;
    var callCount = 0;

    await tester.pumpWidget(
      StateScope(
        child: Builder(
          builder: (context) {
            testContext = context;
            context.onDispose(() => callCount++);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(callCount, 0);
    testContext.setState();

    await tester.pump();
    expect(callCount, 0);

    await tester.pumpWidget(const StateScope(child: SizedBox()));
    expect(callCount, 1);
  });
}
