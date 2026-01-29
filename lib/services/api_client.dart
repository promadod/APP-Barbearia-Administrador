import 'package:dio/dio.dart';

class ApiClient {
  // CONFIGURAÇÃO DE IP:
  // Para Windows ou iOS Simulator: use 'http://127.0.0.1:8000/api/'
  // Para Emulador Android: use 'http://10.0.2.2:8000/api/'

  static const String baseUrl = 'http://192.168.11.144:8000/api/';

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
