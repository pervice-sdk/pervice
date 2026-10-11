import 'package:flutter/widgets.dart';

/// Signature for the data loading state of a standard [Service].
enum ServiceStatus {
  /// When no action has been performed yet
  none,

  /// When waiting for a response from the server
  loading,

  /// When data request succeeded and deserialization completed
  loaded,

  /// When data request failed
  failed,

  /// When refreshing while keeping existing data
  refresh,
}

/// An abstract class that represents the ViewModel in the `MVVM` architecture pattern.
/// Primarily responsible for data loading and state management.
abstract class Service<T> extends ChangeNotifier {
  Service({ServiceStatus initialStatus = .none}) : _rawStatus = initialStatus;

  /// Stores the current service status.
  late ServiceStatus _rawStatus;

  /// Internally updates the current state with the given value.
  set _status(ServiceStatus newStatus) {
    _rawStatus = newStatus;
    notifyChanged();
  }

  /// Returns the current status of the [Service].
  ServiceStatus get status => _rawStatus;

  /// Returns true if the data is currently being loaded or not ready for display.
  /// Typically used to show loading indicators or placeholders.
  bool get isLoading => status == .none || status == .loading;

  /// Returns true if the service is currently refreshing its data.
  /// Useful for pull-to-refresh indicators or temporarily disabling
  /// UI interactions.
  bool get isRefreshing => status == .refresh;

  /// Returns true if the service encountered an error while fetching data.
  bool get hasError => status == .failed;

  /// Determines whether this service should rethrow errors from [load].
  /// Can be overridden by subclasses to customize behavior.
  bool get canRethrow => false;

  T? _data;
  dynamic _error;

  /// Whether this service has been disposed, preventing updates from pending requests.
  bool _isDisposed = false;

  /// Returns the currently deserialized and loaded data.
  ///
  /// Throws an assertion error if the data is not yet loaded.
  T get data {
    assert(
      status == .loaded || status == .refresh,
      "Data should only be accessed when ServiceStatus.loaded or refreshing.",
    );

    return _data as T;
  }

  /// Updates the currently loaded data with the given value.
  set data(T newData) {
    if (_data != newData) {
      _data = newData;
      notifyChanged();
    }
  }

  /// Returns the current error. Throws if no error is present.
  dynamic get error {
    assert(
      _error != null || status == .failed,
      "Error must exist before access.",
    );
    assert(
      status == .failed,
      "Error should only be accessed when ServiceStatus.failed.",
    );

    return _error!;
  }

  /// Returns the current data regardless of its existence.
  T? get maybeData => _data;

  /// Returns the current error regardless of its existence.
  dynamic get maybeError => _error;

  /// Called when a data load fails.
  ///
  /// By default, this sets the state to [ServiceStatus.failed].
  void fail(dynamic error) {
    if (_isDisposed) return;
    _error = error;
    _status = .failed;
  }

  /// Called when data has been successfully loaded.
  ///
  /// Internally sets the state to [ServiceStatus.loaded] and updates the data.
  void done(T newData) {
    if (_isDisposed) return;
    _data = newData;
    _status = .loaded;
  }

  /// Starts loading or refreshing the data managed by this service.
  ///
  /// Sets the service status to [ServiceStatus.loading] or [ServiceStatus.refresh]
  /// depending on the [isRefresh] flag. The actual data fetching is performed
  /// by [fetchData].
  ///
  /// This method must call either [done] on success or [fail]
  /// on failure to properly update the service state and notify listeners.
  @mustCallSuper
  Future<void> load({bool isRefresh = false}) async {
    _status = isRefresh ? .refresh : .loading;

    try {
      done(await fetchData());
    } catch (error) {
      fail(error);

      // Rethrows the error if [canRethrow] is enabled.
      if (canRethrow) rethrow;
    }
  }

  /// Fetches the data for this service.
  ///
  /// Implementations should return the requested data or throw an error
  /// if the data cannot be retrieved. This method is called internally
  /// by [load] to perform the actual data retrieval.
  Future<T> fetchData();

  /// Requests a refresh while keeping existing data until new data is loaded.
  Future<void> refresh() async => await load(isRefresh: true);

  /// Loads and returns [data] for a one-time request.
  ///
  /// Unlike calling [fetchData] directly, manages loading, success,
  /// and failure states and automatically disposes the service
  /// when the request completes.
  ///
  /// Errors are propagated regardless of [canRethrow].
  /// Use with a fresh service in [ServiceStatus.none].
  /// do not reuse it afterward.
  Future<T> request() async {
    assert(
      status == .none,
      'Service.request() requires an unused service with ServiceStatus.none.',
    );

    try {
      _status = .loading;
      done(await fetchData());
      return data;
    } catch (error) {
      fail(error);
      rethrow;
    } finally {
      dispose();
    }
  }

  /// Returns the result of [request], or `null` if it throws.
  ///
  /// Disposal is handled by [request], whether it succeeds or fails.
  Future<T?> requestOrNull() async {
    try {
      return await request();
    } catch (_) {
      return null;
    }
  }

  /// Notifies listeners that the service state has changed.
  void notifyChanged() => notifyListeners();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  String toString() {
    return "$runtimeType(status: $status, data: $_data, error: $_error)";
  }
}
