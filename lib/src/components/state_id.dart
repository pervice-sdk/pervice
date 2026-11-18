import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Identifies state by its optional owning [element], [type], and optional [key].
///
/// A null [element] identifies state shared across a `StateScope`.
class StateId extends Equatable {
  const StateId({
    required this.element,
    required this.key,
    required this.type,
  });

  final Element? element;
  final Key? key;
  final Type type;

  @override
  List<Object?> get props => [element, key, type];
}
