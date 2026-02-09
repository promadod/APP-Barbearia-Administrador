import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/salao_service.dart';
import '../config.dart'; 

class BuscaClienteScreen extends StatefulWidget {
  const BuscaClienteScreen({super.key});

  @override
  State<BuscaClienteScreen> createState() => _BuscaClienteScreenState();
}

class _BuscaClienteScreenState extends State<BuscaClienteScreen> {
  final SalaoService _service = SalaoService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _clientes = [];
  bool _isLoading = false;
  Timer? _debounce; 

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _realizarBusca(String termo) async {
    if (termo.isEmpty) {
      setState(() {
        _clientes = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final resultados = await _service.buscarClientes(termo);
    if (mounted) {
      setState(() {
        _clientes = resultados;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _realizarBusca(query);
    });
  }

  void _abrirWhatsApp(String? telefone) async {
    if (telefone == null || telefone.isEmpty) return;
    final numLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse("https://wa.me/55$numLimpo");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao abrir WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // 1. FOTO DE FUNDO
        Positioned.fill(
          child: Image.asset(AppConfig.assetBackground, fit: BoxFit.cover),
        ),
        
        // 2. MÁSCARA 0.60
        Positioned.fill(
          child: Container(color: Colors.white.withOpacity(0.60)),
        ),

        // 3. CONTEÚDO
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Buscar Clientes", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, 
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Digite o nome ou telefone...",
                    prefixIcon: Icon(Icons.search, color: primaryColor), 
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 20),

                
                Expanded(
                  child: _isLoading 
                    ? Center(child: CircularProgressIndicator(color: primaryColor))
                    : _clientes.isEmpty 
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search, size: 60, color: Colors.grey[600]),
                              const SizedBox(height: 10),
                              Text(
                                _searchController.text.isEmpty ? "Digite para buscar" : "Nenhum cliente encontrado",
                                style: GoogleFonts.poppins(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _clientes.length,
                          itemBuilder: (context, index) {
                            final cliente = _clientes[index];
                            final nome = cliente['nome'] ?? 'Sem nome';
                            final telefone = cliente['telefone'] ?? '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              color: Colors.white.withOpacity(0.95),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: primaryColor.withOpacity(0.1), 
                                  child: Text(nome[0].toUpperCase(), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(nome, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                subtitle: Text(telefone, style: GoogleFonts.poppins(fontSize: 12)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.chat, color: Colors.green),
                                  onPressed: () => _abrirWhatsApp(telefone),
                                  tooltip: "Conversar no WhatsApp",
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}