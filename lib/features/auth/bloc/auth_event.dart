part of 'auth_bloc.dart';

abstract class AuthEvent {}

/// Fired on app start — checks for existing valid session
class AppStarted extends AuthEvent {}

/// User submits login form
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}

/// User submits register form
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  RegisterRequested({required this.email, required this.password});
}

/// User taps logout
class LogoutRequested extends AuthEvent {}
