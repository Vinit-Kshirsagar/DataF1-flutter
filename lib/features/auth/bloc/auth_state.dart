part of 'auth_bloc.dart';

abstract class AuthState {}

/// Initial state before app start check
class AuthInitial extends AuthState {}

/// Checking session / loading login or register
class AuthLoading extends AuthState {}

/// Valid session confirmed — user is logged in
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

/// No valid session — guest mode
class AuthUnauthenticated extends AuthState {}

/// Auth operation failed — show message inline
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
