import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService _storage = SecureStorageService();

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Attempt Refresh Token Flow
            final refreshToken = await _storage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshResponse = await Dio().post(
                  '${AppConstants.apiBaseUrl}/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );

                if (refreshResponse.statusCode == 200 &&
                    refreshResponse.data['data'] != null) {
                  final newAccessToken =
                      refreshResponse.data['data']['accessToken'];
                  final newRefreshToken =
                      refreshResponse.data['data']['refreshToken'];

                  await _storage.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                  );

                  // Retry original request
                  error.requestOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';
                  final clonedRequest = await dio.fetch(error.requestOptions);
                  return handler.resolve(clonedRequest);
                }
              } catch (_) {
                await _storage.clearAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
