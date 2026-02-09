import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/salao_service.dart';
import '../config.dart'; 
import 'login_screen.dart';
import 'servicos_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) irParaAba; 
  const DashboardScreen({super.key, required this.irParaAba});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SalaoService _service = SalaoService();
  bool _isLoading = true;
  String _nomeUsuario = "Administrador";
  double _faturamento = 0.0;
  int _agendamentosHoje = 0;
  int _pendentes = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
    _carregarDados();
  }

  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nomeUsuario = prefs.getString('user_name') ?? "Administrador";
    });
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final dados = await _service.getResumoHoje();
      if (mounted) {
        setState(() {
          _faturamento = double.tryParse(dados['faturamento_hoje'].toString()) ?? 0.0;
          _agendamentosHoje = int.tryParse(dados['agendamentos_hoje'].toString()) ?? 0;
          _pendentes = int.tryParse(dados['pendentes'].toString()) ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dia = DateFormat("d 'de' MMMM", 'pt_BR').format(DateTime.now());

    // --- VARIÁVEIS DE COR DINÂMICAS ---
    
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Stack(
      children: [
        // 1. A FOTO DE FUNDO DINÂMICA
        Positioned.fill(
          child: Image.asset(
            AppConfig.assetBackground, 
            fit: BoxFit.cover,
          ),
        ),

        // 2. MÁSCARA BRANCA
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.55), 
          ),
        ),

        // 3. O CONTEÚDO DO DASHBOARD
        Scaffold(
          backgroundColor: Colors.transparent, 
          appBar: AppBar(
            title: Text('Visão Geral', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor), 
            actions: [
              IconButton(icon: Icon(Icons.exit_to_app, color: primaryColor), onPressed: _logout)
            ],
          ),
          
          body: RefreshIndicator(
            onRefresh: _carregarDados,
            color: primaryColor, 
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hoje, $dia", style: GoogleFonts.poppins(color: Colors.grey[800])),
                  
                  
                  Text(
                    "Olá, $_nomeUsuario!", 
                    style: GoogleFonts.poppins(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: primaryColor 
                    )
                  ),

                  const SizedBox(height: 25),

                  // CARD FATURAMENTO (GRADIENTE DINÂMICO)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        
                        colors: [primaryColor, secondaryColor], 
                        begin: Alignment.topLeft, 
                        end: Alignment.bottomRight
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.white, size: 32),
                        const SizedBox(height: 20),
                        Text("Faturamento Hoje", style: GoogleFonts.poppins(color: Colors.white70)),
                        _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                            : Text(
                                moeda.format(_faturamento),
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // GRID DE CARDS
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildClickableStatsCard(
                        context: context, 
                        icon: Icons.calendar_month,
                        value: _isLoading ? "..." : "$_agendamentosHoje",
                        title: "Agendamentos",
                        onTap: () => widget.irParaAba(2),
                        useGradient: true,
                      ),
                      
                      _buildClickableStatsCard(
                        context: context,
                        icon: Icons.pending_actions,
                        value: _isLoading ? "..." : "$_pendentes",
                        title: "Pendentes",
                        onTap: () => widget.irParaAba(2),
                        useGradient: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicosScreen()));
            },
            label: const Text("Serviços"),
            icon: const Icon(Icons.add),
            backgroundColor: primaryColor, 
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildClickableStatsCard({
    required BuildContext context, 
    required IconData icon, 
    required String value, 
    required String title, 
    VoidCallback? onTap,
    bool useGradient = false,
  }) {
    // VARIÁVEIS DE COR LOCAIS BASEADAS NO TEMA
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final Color textColor = useGradient ? Colors.white : Colors.black87;
    final Color subTextColor = useGradient ? Colors.white70 : Colors.grey;
    final Color iconColor = useGradient ? Colors.white : primaryColor; 
    final Color iconBgColor = useGradient ? Colors.white.withOpacity(0.2) : primaryColor.withOpacity(0.1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: useGradient ? null : Colors.white.withOpacity(0.75), 
          gradient: useGradient 
            ? LinearGradient(
                colors: [primaryColor, secondaryColor], 
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              
              color: useGradient ? primaryColor.withOpacity(0.4) : Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor, 
                borderRadius: BorderRadius.circular(12)
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value, 
                  style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)
                ),
                Text(
                  title, 
                  style: GoogleFonts.poppins(fontSize: 13, color: subTextColor)
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}