import 'package:equatable/equatable.dart';

class ConnectionConfigInputState extends Equatable {
  final String input;
  final String? error;
  final bool isDisabled;
  final bool isLoading;

  const ConnectionConfigInputState({
    this.input = '',
    this.error,
    this.isDisabled = false,
    this.isLoading = false,
  });

  ConnectionConfigInputState copyWith({
    String? input,
    String? error,
    bool? isDisabled,
    bool? isLoading,
  }) {
    return ConnectionConfigInputState(
      input: input ?? this.input,
      error: error,
      isDisabled: isDisabled ?? this.isDisabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [input, error, isDisabled, isLoading];
}
