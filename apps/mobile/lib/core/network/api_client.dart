import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({SecureStorageService? storage, Dio? refreshClient})
    : _storage = storage ?? SecureStorageService() {
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
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
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
  }
  late final Dio dio;
  late final Dio _refreshDio;
  final SecureStorageService _storage;
  Completer<String?>? _refreshCompleter;
  void Function()? onSessionExpired;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = error.requestOptions.path.contains('/auth/');
    final alreadyRetried = error.requestOptions.extra['retried'] == true;
    if (error.response?.statusCode == 401 &&
        !isAuthEndpoint &&
        !alreadyRetried) {
      final token = await _refreshAccessToken();
      if (token != null) {
        error.requestOptions.extra['retried'] = true;
        error.requestOptions.headers['Authorization'] = 'Bearer $token';
        try {
          return handler.resolve(await dio.fetch(error.requestOptions));
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      }
    }
    handler.next(error);
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshCompleter != null) return _refreshCompleter!.future;
    final completer = Completer<String?>();
    _refreshCompleter = completer;
    String? newAccessToken;
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const ApiException('Sessão expirada');
      }
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      final access = data?['accessToken'] as String?;
      final refresh = data?['refreshToken'] as String?;
      if (access == null ||
          access.isEmpty ||
          refresh == null ||
          refresh.isEmpty) {
        throw const ApiException('Resposta de sessão inválida');
      }
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      newAccessToken = access;
    } catch (_) {
      try {
        await _storage.clearAll();
      } catch (_) {
        // A storage failure must not leave concurrent requests waiting forever.
      } finally {
        onSessionExpired?.call();
      }
    } finally {
      completer.complete(newAccessToken);
      _refreshCompleter = null;
    }
    return newAccessToken;
  }

  T unwrap<T>(Response<dynamic> response) {
    final envelope = response.data;
    if (envelope is Map<String, dynamic> && envelope['data'] is T) {
      return envelope['data'] as T;
    }
    throw const ApiException('Resposta inválida do servidor');
  }

  ApiException readableError(Object error) {
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
