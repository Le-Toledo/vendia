import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vendeai_mobile/core/data/business_repository.dart';
import 'package:vendeai_mobile/core/network/api_client.dart';
import 'package:vendeai_mobile/core/storage/secure_storage_service.dart';

class FakeStorage extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => null;
}

void main() {
  test('repository unwraps paginated API responses', () async {
    final api = ApiClient(storage: FakeStorage());
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'data': {
                  'items': [
                    {'id': 'client-1', 'name': 'Client'},
                  ],
                  'page': 1,
                  'pageSize': 20,
                  'total': 1,
                },
              },
            ),
          );
        },
      ),
    );
    final result = await BusinessRepository(api).list('/clients');
    expect(result.single['id'], 'client-1');
  });

  test('repository exposes readable server validation errors', () async {
    final api = ApiClient(storage: FakeStorage());
    api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 400,
                data: {
                  'message': ['Nome obrigatório'],
                },
              ),
            ),
          );
        },
      ),
    );
    await expectLater(
      BusinessRepository(api).list('/clients'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('Nome obrigatório'),
        ),
      ),
    );
  });
}
