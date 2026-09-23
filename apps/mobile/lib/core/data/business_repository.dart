import '../network/api_client.dart';

class BusinessRepository {
  BusinessRepository(this.api);
  final ApiClient api;

  Future<List<Map<String, dynamic>>> list(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await api.dio.get(path, queryParameters: query);
      final data = api.unwrap<dynamic>(response);
      final raw = data is Map<String, dynamic> ? data['items'] : data;
      return (raw as List).cast<Map<String, dynamic>>();
    } catch (error) {
      throw api.readableError(error);
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      return api.unwrap<Map<String, dynamic>>(await api.dio.get(path));
    } catch (error) {
      throw api.readableError(error);
    }
  }

  Future<Map<String, dynamic>> save(
    String path,
    Map<String, dynamic> data, {
    String? id,
    bool put = false,
  }) async {
    try {
      final response = id != null
          ? await api.dio.put('$path/$id', data: data)
          : put
          ? await api.dio.put(path, data: data)
          : await api.dio.post(path, data: data);
      return api.unwrap<Map<String, dynamic>>(response);
    } catch (error) {
      throw api.readableError(error);
    }
  }

  Future<void> delete(String path) async {
    try {
      await api.dio.delete(path);
    } catch (error) {
      throw api.readableError(error);
    }
  }
}
