import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart'; 
import 'financeiro_screen.dart';
import 'login_screen.dart';
import 'config_horarios.dart';
import 'servicos_screen.dart';
import 'historico_agendamentos_screen.dart';
import 'perfil_loja_screen.dart';
import 'minha_assinatura_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void _falarComSuporte(BuildContext context) async {
    final url = Uri.parse("https://wa.me/5521986855874?text=Olá, preciso de suporte no Sistema.");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao abrir WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // COR DINÂMICA
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // 1. FOTO
        Positioned.fill(child: Image.asset(AppConfig.assetBackground, fit: BoxFit.cover)),
        // 2. MÁSCARA 0.60
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.60))),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Menu", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, 
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text("Gestão", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(height: 10),

              _buildMenuItem(context, icon: Icons.monetization_on, color: primaryColor, text: "Financeiro", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceiroScreen()))),
              const SizedBox(height: 12),
              
              _buildMenuItem(context, icon: Icons.history, color: primaryColor, text: "Histórico Completo", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoricoAgendamentosScreen()))),
              const SizedBox(height: 12),
              
              _buildMenuItem(context, icon: Icons.spa, color: primaryColor, text: "Serviços", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicosScreen()))),
              const SizedBox(height: 12),
              
              _buildMenuItem(context, icon: Icons.access_time, color: primaryColor, text: "Horários de Funcionamento", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigHorariosScreen()))),
              const SizedBox(height: 12),

              _buildMenuItem(context, icon: Icons.qr_code, color: primaryColor, text: "Minha Assinatura", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MinhaAssinaturaScreen()))),
              const SizedBox(height: 12),

              _buildMenuItem(context, icon: Icons.storefront, color: primaryColor, text: "Configurar Loja", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilLojaScreen()))),

              const Divider(height: 40, color: Colors.black12),

              _buildMenuItem(context, icon: Icons.exit_to_app, color: primaryColor, text: "Sair do App", onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),

              // --- RODAPÉ ONEIRA TECH ---
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Text("Precisa de ajuda?", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 34, 34, 34), fontSize: 13)),
                    const SizedBox(height: 5),
                    TextButton.icon(
                      onPressed: () => _falarComSuporte(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      icon: const Icon(Icons.support_agent, color: Colors.blue), 
                      label: Text(
                        "Suporte Oneira Tech", 
                        style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.bold)
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Desenvolvido por Oneira Tech © 2026", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 37, 36, 36), fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required Color color, required String text, required VoidCallback onTap}) {
    // cores dinâmicas baseadas no tema para o fundo do item
    final primaryColor = Theme.of(context).primaryColor;
    
    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          text, 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 16)
        ),
        trailing: Icon(Icons.chevron_right, color: primaryColor.withOpacity(0.5)), 
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}