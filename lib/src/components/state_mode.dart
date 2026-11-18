/// Controls whether `stateOf` only reads a state or also watches it for changes.
enum StateMode {
  /// Retrieves the state instance without subscribing to its updates.
  /// The dependent widget will not rebuild when the state changes.
  read,

  /// Retrieves the state and subscribes to its updates.
  /// The dependent widget will automatically rebuild
  /// whenever the state notifies listeners.
  watch,
}
