import 'package:flutter/widgets.dart';

/// A notifier that exposes listener registration state for tests.
class TestNotifier extends ValueNotifier<int> {
  TestNotifier() : super(0);

  /// Whether any listeners are currently registered.
  bool get isListening => hasListeners;
}
