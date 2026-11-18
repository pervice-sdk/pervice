import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Uniquely identifies a service by its [type] and optional [key].
class ServiceId extends Equatable {
  const ServiceId({
    required this.key,
    required this.type,
  });

  final Key? key;
  final Type type;

  @override
  List<Object?> get props => [key, type];
}
