import 'package:pervice/pervice.dart';

/// A test implementation of [Service] for String data.
///
/// Can simulate success or failure based on [isThrowError].
class TestService extends Service<String> {
  TestService({this.throwError = false});

  final bool throwError;
  bool isDisposed = false;

  static const duration = Duration(microseconds: 1);
  static const sampleData = "Hello, World!";
  static final sampleError = Error();
  static final sampleStackTrace = StackTrace.fromString('TestService.fetchData');

  @override
  Future<String> fetchData() async {
    if (throwError) Error.throwWithStackTrace(sampleError, sampleStackTrace);

    await Future.delayed(.new(microseconds: 1));
    return sampleData;
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

/// A distinct [TestService] type for testing service lookup and lifecycle.
class TestService1 extends TestService {}

/// Another [TestService] type for testing services independently of [TestService1].
class TestService2 extends TestService {}

/// A test implementation of [Service] that completes without returning data.
class TestVoidService extends Service<void> {
  @override
  Future<void> fetchData() async {}
}
