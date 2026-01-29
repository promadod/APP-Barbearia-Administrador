import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Importante
import '../services/api_client.dart';
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
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha usuário e senha.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.dio.post('token-auth/', data: {
        'username': _userController.text,
        'password': _passController.text,
      });

      final token = response.data['token'];
      final userName = response.data['nome'] ?? _userController.text;
      final userEmail = response.data['email'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user_name', userName);
        if (userEmail != null) await prefs.setString('user_email', userEmail);

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BaseScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login falhou. Verifique seus dados.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _falarComSuporte() async {
    final url = Uri.parse("https://wa.me/5521986855874?text=Olá, preciso de ajuda para entrar no Bela Agenda.");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao abrir WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login_bg.jpeg'), 
                fit: BoxFit.cover, 
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2), 
                  const Color(0xFFE91E63).withOpacity(0.8), 
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
                    'Bela Agenda App',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      shadows: [const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2))]
                    ),
                  ),
                  Text(
                    'Beleza e Organização',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 50),

                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _userController,
                          decoration: const InputDecoration(
                            labelText: 'Usuário',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _fazerLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text('ENTRAR', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {},
                    child: Text("Esqueci minha senha", style: GoogleFonts.poppins(color: Colors.white)),
                  ),

                  // --- RODAPÉ DE SUPORTE NO LOGIN ---
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _falarComSuporte,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.support_agent, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Suporte Oneira Tech",
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                        ),
                      ],
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