import 'package:dio/dio.dart';

class ApiClient {
  

  static const String baseUrl = 'https://oneiratech01.pythonanywhere.com/api/';

  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Função chamada pelo Login para salvar o token na memória
  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Token $token';
  }
}
