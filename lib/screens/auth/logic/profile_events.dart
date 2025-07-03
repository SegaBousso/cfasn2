/// Typed events for the complete profile screen
abstract class ProfileEvent {}

/// Event when form data changes
class ProfileFormChangedEvent extends ProfileEvent {
  final String field;
  final dynamic value;

  ProfileFormChangedEvent(this.field, this.value);
}

/// Event when civility selection changes
class ProfileCivilityChangedEvent extends ProfileEvent {
  final String? civility;

  ProfileCivilityChangedEvent(this.civility);
}

/// Event when role selection changes
class ProfileRoleChangedEvent extends ProfileEvent {
  final String role;

  ProfileRoleChangedEvent(this.role);
}

/// Event when profile save starts
class ProfileSaveStartedEvent extends ProfileEvent {}

/// Event when profile save succeeds
class ProfileSaveSuccessEvent extends ProfileEvent {
  final String role;

  ProfileSaveSuccessEvent(this.role);
}

/// Event when profile save fails
class ProfileSaveFailedEvent extends ProfileEvent {
  final String error;

  ProfileSaveFailedEvent(this.error);
}

/// Event to show snackbar message
class ProfileShowSnackbarEvent extends ProfileEvent {
  final String message;
  final bool isError;

  ProfileShowSnackbarEvent(this.message, {this.isError = false});
}

/// Event to navigate based on role
class ProfileNavigateEvent extends ProfileEvent {
  final String role;

  ProfileNavigateEvent(this.role);
}
