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

  @override
  Future<String> fetchData() async {
    if (throwError) throw sampleError;

    await Future.delayed(.new(microseconds: 1));
    return sampleData;
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}

class TestService1 extends TestService {}

class TestService2 extends TestService {}
