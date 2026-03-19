import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/router/app_router.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc({AuthRepository? repository})
      : _repo = repository ?? AuthRepository(),
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await _repo.tryRestoreSession();
    if (user != null) {
      authStateNotifier.value = true;
      emit(AuthAuthenticated(user));
    } else {
      authStateNotifier.value = false;
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _repo.login(event.email, event.password);
      final user = await _repo.getMe();
      authStateNotifier.value = true;
      emit(AuthAuthenticated(user));
    } catch (e) {
      authStateNotifier.value = false;
      emit(AuthError(dioErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _repo.register(event.email, event.password);
      // Auto-login after registration
      await _repo.login(event.email, event.password);
      final user = await _repo.getMe();
      authStateNotifier.value = true;
      emit(AuthAuthenticated(user));
    } catch (e) {
      authStateNotifier.value = false;
      emit(AuthError(dioErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.clearTokens();
    authStateNotifier.value = false;
    emit(AuthUnauthenticated());
  }
}
