/// Controls whether `serviceOf` only reads a service or also watches it for changes.
enum ServiceMode {
  /// Retrieves the service instance without subscribing to its updates.
  /// The dependent widget will not rebuild when the service changes.
  read,

  /// Retrieves the service and subscribes to its updates.
  /// The dependent widget will automatically rebuild
  /// whenever the service notifies listeners.
  watch,
}
