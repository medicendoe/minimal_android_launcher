part of 'config_cubit.dart';

/// Immutable state for [ConfigCubit].
class ConfigState extends Equatable {
  /// The current app configuration.
  final AppConfig config;

  /// `true` while the config is being loaded from storage.
  final bool isLoading;

  /// `true` while the config is being persisted to storage.
  final bool isSaving;

  /// Non-null when an error has occurred during load or save.
  final String? error;

  /// Non-null after a successful save operation.
  final String? successMessage;

  const ConfigState({
    required this.config,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  /// Creates the initial state with an empty [AppConfig].
  factory ConfigState.initial() {
    return ConfigState(
      config: AppConfig.initial(),
      isLoading: false,
      isSaving: false,
    );
  }

  /// Returns a copy with the specified fields replaced.
  ConfigState copyWith({
    AppConfig? config,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return ConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [config, isLoading, isSaving, error, successMessage];
}
