import 'package:flutter/scheduler.dart';

/// A custom [TickerProvider] implementation designed for hook-based life cycle management.
class HookTickerProvider implements TickerProvider {
  final List<Ticker> _tickers = [];

  @override
  Ticker createTicker(TickerCallback onTick) {
    final ticker = Ticker(onTick);
    _tickers.add(ticker);
    return ticker;
  }

  /// Disposes all [Ticker] instances created and clears the internal tracking list.
  void dispose() {
    for (final ticker in _tickers) {
      ticker.dispose();
    }
    _tickers.clear();
  }
}
