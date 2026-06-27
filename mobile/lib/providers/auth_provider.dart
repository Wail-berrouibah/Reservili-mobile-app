import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/device/device_id_helper.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final bool loading;
  final String? errorKey;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.loading = false,
    this.errorKey,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? loading,
    String? errorKey,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        loading: loading ?? this.loading,
        errorKey: clearError ? null : (errorKey ?? this.errorKey),
      );
}

final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  // Set the client's real code at build time:
  // flutter build apk --release --dart-define=ACCESS_CODE=7391
  static const _validCode =
      String.fromEnvironment('ACCESS_CODE', defaultValue: '1234');
  static const _tokenKey = 'auth_token';
  static const _deviceKey = 'bound_device_id';

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  AuthState build() => const AuthState();

  Future<void> checkAuth() async {
    final token = await _storage.read(key: _tokenKey);
    state = state.copyWith(
      status: (token != null && token.isNotEmpty)
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
    );
  }

  Future<bool> verifyCode(String code) async {
    state = state.copyWith(loading: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 300));

    if (code.trim() != _validCode) {
      state = state.copyWith(loading: false, errorKey: 'INVALID_CODE');
      return false;
    }

    // Bind to this device locally (one install = one bound device).
    final deviceId = await DeviceIdHelper.getDeviceId();
    await _storage.write(key: _deviceKey, value: deviceId);
    await _storage.write(key: _tokenKey, value: 'local-$deviceId');

    state = state.copyWith(status: AuthStatus.authenticated, loading: false);
    return true;
  }

  Future<void> signOut() async {
    await _storage.delete(key: _tokenKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
