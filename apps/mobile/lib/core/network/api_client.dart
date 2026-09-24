import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'network_diagnostics.dart';
import '../storage/secure_storage_service.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    SecureStorageService? storage,
    Dio? refreshClient,
    NetworkDiagnostics? diagnostics,
  }) : _storage = storage ?? SecureStorageService(),
       _diagnostics = diagnostics ?? NetworkDiagnostics() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
    _refreshDio =
        refreshClient ??
        Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            sendTimeout: const Duration(seconds: 20),
          ),
        );
    _refreshDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _diagnostics.record('refresh_or_logout_send', options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _diagnostics.record(
            'refresh_or_logout_response',
            response.requestOptions,
            status: response.statusCode,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _diagnostics.record(
            'refresh_or_logout_error',
            error.requestOptions,
            error: error,
            status: error.response?.statusCode,
          );
          handler.next(error);
        },
      ),
    );
  }
  late final Dio dio;
  late final Dio _refreshDio;
  final SecureStorageService _storage;
  final NetworkDiagnostics _diagnostics;
  static const generationKey = 'sessionGeneration';
  int _generation = 0;
  bool _blocked = false;
  Future<void> _storageQueue = Future<void>.value();
  ({int generation, Future<String?> result})? _refresh;
  void Function()? onSessionExpired;

  int get sessionGeneration => _generation;
  bool isCurrentSession(int generation) => generation == _generation;

  // Every storage operation shares this queue. Checking only before an async
  // write is insufficient: a logout/login can occur while Keychain is writing.
  Future<T> _withStorage<T>(Future<T> Function() action) {
    final result = _storageQueue.then((_) => action());
    _storageQueue = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return result;
  }

  void _checkGeneration(int generation) {
    if (!isCurrentSession(generation)) {
      throw const ApiException('A sessão foi alterada.');
    }
  }

  Future<int> beginSessionChange({int? expectedGeneration}) async {
    if (expectedGeneration != null) _checkGeneration(expectedGeneration);
    final generation = ++_generation;
    _blocked = true;
    _refresh = null;
    await _withStorage(() async {
      _checkGeneration(generation);
      await _storage.clearAll();
      _checkGeneration(generation);
    });
    return generation;
  }

  Future<void> acceptSession(int generation, String access, String refresh) =>
      _withStorage(() async {
        _checkGeneration(generation);
        if (access.isEmpty || refresh.isEmpty) {
          throw const ApiException('Resposta de sessão inválida');
        }
        await _storage.saveTokens(accessToken: access, refreshToken: refresh);
        _checkGeneration(generation);
        _blocked = false;
      });

  Future<bool> hasStoredSession(int generation) => _withStorage(() async {
    _checkGeneration(generation);
    if (_blocked) return false;
    final token = await _storage.getRefreshToken();
    _checkGeneration(generation);
    return token?.isNotEmpty == true;
  });

  Future<void> logout() async {
    final generation = ++_generation;
    _blocked = true;
    _refresh = null;
    final access = await _withStorage(() async {
      _checkGeneration(generation);
      String? oldAccess;
      try {
        oldAccess = await _storage.getAccessToken();
      } finally {
        await _storage.clearAll();
      }
      return oldAccess;
    });
    // This request must never acquire a new user's token or refresh a session.
    // There is deliberately no cleanup callback after its network response.
    if (access?.isNotEmpty == true) {
      await _refreshDio.post(
        '/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $access'}),
      );
    }
  }

  DioException _obsolete(RequestOptions options) => DioException(
    requestOptions: options,
    type: DioExceptionType.cancel,
    error: const ApiException('Resposta de uma sessão anterior descartada.'),
  );

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _diagnostics.record('prepare', options, blocked: _blocked);
    final generation =
        options.extra.putIfAbsent(generationKey, () => _generation) as int;
    try {
      _checkGeneration(generation);
      // Login/register/social authentication must not inherit the old bearer.
      options.headers.removeWhere(
        (key, _) => key.toLowerCase() == 'authorization',
      );
      if (!options.path.startsWith('/auth/')) {
        final token = await _withStorage(() async {
          _checkGeneration(generation);
          if (_blocked) return null;
          final token = await _storage.getAccessToken();
          _checkGeneration(generation);
          return token;
        });
        if (token?.isNotEmpty == true) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      _checkGeneration(generation);
      _diagnostics.record('send', options, blocked: _blocked);
      handler.next(options);
    } catch (error) {
      _diagnostics.record(
        'prepare_error',
        options,
        error: error,
        blocked: _blocked,
      );
      handler.reject(_obsolete(options));
    }
  }

  void _onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _diagnostics.record(
      'response',
      response.requestOptions,
      status: response.statusCode,
    );
    if (response.requestOptions.extra[generationKey] != _generation) {
      handler.reject(_obsolete(response.requestOptions));
    } else {
      handler.next(response);
    }
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    _diagnostics.record(
      'error',
      options,
      error: error,
      status: error.response?.statusCode,
      blocked: _blocked,
    );
    final generation = options.extra[generationKey] as int?;
    if (generation != _generation) {
      return handler.next(_obsolete(options));
    }
    if (error.response?.statusCode == 401 &&
        !options.path.startsWith('/auth/') &&
        options.extra['retried'] != true &&
        !_blocked) {
      final token = await _refreshAccessToken(
        generation!,
        options.headers['Authorization'] as String?,
      );
      if (!isCurrentSession(generation)) {
        return handler.next(_obsolete(options));
      }
      if (token != null) {
        options.extra['retried'] = true;
        try {
          return handler.resolve(await dio.fetch(options));
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      }
    }
    handler.next(error);
  }

  Future<String?> _refreshAccessToken(
    int generation,
    String? sentAuthorization,
  ) async {
    if (!isCurrentSession(generation) || _blocked) return null;
    final active = _refresh;
    if (active != null && active.generation == generation) return active.result;
    final result = _performRefresh(generation, sentAuthorization);
    final flight = (generation: generation, result: result);
    _refresh = flight;
    try {
      return await result;
    } finally {
      if (identical(_refresh?.result, result)) _refresh = null;
    }
  }

  Future<String?> _performRefresh(
    int generation,
    String? sentAuthorization,
  ) async {
    try {
      final tokens = await _withStorage(() async {
        _checkGeneration(generation);
        final access = await _storage.getAccessToken();
        final refresh = await _storage.getRefreshToken();
        _checkGeneration(generation);
        return (access: access, refresh: refresh);
      });
      // A delayed 401 from the same session may arrive after a completed refresh.
      if (tokens.access?.isNotEmpty == true &&
          sentAuthorization != 'Bearer ${tokens.access}') {
        return tokens.access;
      }
      if (tokens.refresh == null || tokens.refresh!.isEmpty) {
        throw const ApiException('Sessão expirada');
      }
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': tokens.refresh},
      );
      _checkGeneration(generation);
      final data = response.data?['data'] as Map<String, dynamic>?;
      final access = data?['accessToken'] as String?;
      final refresh = data?['refreshToken'] as String?;
      if (access == null || refresh == null) {
        throw const ApiException('Resposta de sessão inválida');
      }
      await acceptSession(generation, access, refresh);
      return access;
    } catch (_) {
      if (isCurrentSession(generation)) {
        // Invalidate immediately, even if Keychain deletion fails.
        final expiredGeneration = _generation + 1;
        try {
          await beginSessionChange(expectedGeneration: generation);
        } catch (_) {
          // Storage/network failures cannot resurrect the in-memory session.
        }
        if (isCurrentSession(expiredGeneration)) onSessionExpired?.call();
      }
      return null;
    }
  }

  T unwrap<T>(Response<dynamic> response) {
    final envelope = response.data;
    if (envelope is Map<String, dynamic> && envelope['data'] is T) {
      return envelope['data'] as T;
    }
    throw const ApiException('Resposta inválida do servidor');
  }

  ApiException readableError(Object error) {
    if (error is ApiException) return error;
    if (error is DioException) {
      final payload = error.response?.data;
      final message = payload is Map ? payload['message'] : null;
      return ApiException(
        message is List
            ? message.join('\n')
            : message?.toString() ?? 'Não foi possível conectar ao servidor.',
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(error.toString());
  }
}
