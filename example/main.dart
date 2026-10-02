import 'package:flutter/material.dart';
import 'package:pervice/pervice.dart';

/// A simple example service that extends [Service] with integer data.
/// It increments a static counter each time [fetchData] is called.
class ExampleService extends Service<int> {
  int count = 0;

  // Simulates fetching data asynchronously with a 1-second delay.
  @override
  Future<int> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    return count += 1;
  }
}

void main() {
  runApp(const MainApp());
}

/// The main application widget.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ServiceScope(
        child: Scaffold(
          body: SafeArea(child: Center(child: ExampleWidget())),
        ),
      ),
    );
  }
}

/// A widget that creates and watches [ExampleService] via [serviceOf].
/// Displays a loading indicator while data is being fetched,
/// and the fetched integer once available.
class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.serviceOf(ExampleService.new);

    // Alternatively, you can use the `when` extension on the service
    // to declaratively build widgets based on its current state.
    // This keeps the UI code concise and clearly maps each state
    // (loading, failed, loaded, refresh) to a corresponding widget.
    //
    // Example:
    //
    // service.when(
    //   none: () => Text("Service is none"),
    //   loading: () => CircularProgressIndicator(), // Shown while data is loading
    //   refresh: () => CircularProgressIndicator(), // Optional: Shown during a refresh
    //   failed: (error) => Text("Service failed: $error"), // Shown if an error occurs
    //   loaded: (data) => Text("Data: $data"), // Shown when data is successfully loaded
    // );

    if (service.isLoading) {
      return CircularProgressIndicator();
    }

    if (service.isError) {
      return Text("Service is failed: ${service.error}");
    }

    return ExampleSubtreeWidget();
  }
}

/// A subtree widget that watches the existing [ExampleService].
/// Displays the loaded integer data with a refresh mechanism.
class ExampleSubtreeWidget extends StatelessWidget {
  const ExampleSubtreeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.serviceOf(ExampleService.new);

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 15,
      children: [
        Opacity(
          opacity: service.isRefreshing ? 0.5 : 1,
          child: Text(service.data.toString()),
        ),
        // Simple refresh implementation.
        IgnorePointer(
          ignoring: service.isRefreshing,
          child: TextButton(onPressed: service.refresh, child: Text("Refesh")),
        ),
      ],
    );
  }
}
