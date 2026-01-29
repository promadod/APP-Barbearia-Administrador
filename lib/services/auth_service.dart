import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  Future<bool> login(String username, String password) async {
    try {
      // 1. Tenta logar no Django (Usando a rota customizada que criamos)
      final response = await _client.dio.post('token-auth/', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];

        // 2. Salva o token na gaveta certa (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Salva também o ID e o Tipo para usarmos depois
        if (data['user_id'] != null) {
          await prefs.setInt('user_id', data['user_id']);
        }
        if (data['tipo_negocio'] != null) {
          await prefs.setString('tipo_negocio', data['tipo_negocio']);
        }

        // 3. Configura o cliente API para usar esse token imediatamente
        _client.setToken(token);

        return true; // Sucesso
      }
      return false;
    } on DioException catch (e) {
      print('Erro Login: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Erro inesperado: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpa tudo ao sair
  }
}
