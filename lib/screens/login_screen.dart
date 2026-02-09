import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_client.dart';
import '../config.dart'; 
import 'base_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _apiClient = ApiClient();
  bool _isLoading = false;

  void _fazerLogin() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.dio.post('token-auth/', data: {
        'username': _userController.text,
        'password': _passController.text,
      });

      final token = response.data['token'];
      final userName = response.data['nome'] ?? _userController.text;

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', userName);
        
        _apiClient.dio.options.headers['Authorization'] = 'Token $token';

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BaseScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login falhou.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _falarComSuporte() async {
    // Você pode até ter números diferentes para suporte aqui se quiser
    final zap = "5521986855874"; 
    final url = Uri.parse("https://wa.me/$zap?text=Ajuda no login.");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
  }

  @override
  Widget build(BuildContext context) {
    // Pega as cores fixas do tema (que já foram definidas no main.dart via Config)
    final primaryColor = Theme.of(context).primaryColor;
    
    // Cores do gradiente baseadas na versão
    final gradientEnd = AppConfig.isBarberVersion 
        ? const Color(0xFF0D47A1).withOpacity(0.9) 
        : const Color(0xFFE91E63).withOpacity(0.8);

    return Scaffold(
      body: Stack(
        children: [
          // Fundo Fixo (Barbearia ou Salão)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConfig.assetBackground), 
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  gradientEnd,
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConfig.appName, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [const Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 50),

                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            prefixIcon: Icon(Icons.person, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _fazerLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text('ENTRAR', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _falarComSuporte,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.support_agent, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Suporte Oneira Tech",
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}