import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart'; 

class MinhaAssinaturaScreen extends StatefulWidget {
  const MinhaAssinaturaScreen({super.key});

  @override
  State<MinhaAssinaturaScreen> createState() => _MinhaAssinaturaScreenState();
}

class _MinhaAssinaturaScreenState extends State<MinhaAssinaturaScreen> {
  final ApiClient _client = ApiClient();
  List<dynamic> _faturas = [];
  Map<String, dynamic> _dadosPix = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) _client.setToken(token);

    try {
      final faturasResp = await _client.dio.get('minhas-faturas/');
      final pixResp = await _client.dio.get('minhas-faturas/dados_pagamento/');

      setState(() {
        _faturas = faturasResp.data;
        _dadosPix = pixResp.data;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar assinatura: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // VARIÁVEIS DE COR DINÂMICAS
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Stack(
      children: [
        Positioned.fill(child: Image.asset(AppConfig.assetBackground, fit: BoxFit.cover)),
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.60))),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Minha Assinatura", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor),
          ),
          body: _isLoading 
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // CARD DO PIX (GRADIENTE DINÂMICO)
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, secondaryColor], 
                          begin: Alignment.topLeft, 
                          end: Alignment.bottomRight
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.pix, color: Colors.white, size: 40),
                          const SizedBox(height: 10),
                          Text("Chave PIX para Pagamento", style: GoogleFonts.poppins(color: Colors.white70)),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2), 
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.3))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _dadosPix['chave_pix'] ?? "Carregando...", 
                                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, color: Colors.white),
                                  onPressed: () {
                                    if (_dadosPix['chave_pix'] != null) {
                                      Clipboard.setData(ClipboardData(text: _dadosPix['chave_pix']));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chave PIX copiada!"), backgroundColor: Colors.green));
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Beneficiário: ${_dadosPix['beneficiario'] ?? ''}", 
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Histórico de Faturas", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 15),

                    if (_faturas.isEmpty)
                      const Text("Nenhuma fatura encontrada.")
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _faturas.length,
                        itemBuilder: (context, index) {
                          final item = _faturas[index];
                          final pago = item['pago'] == true;
                          final vencimento = DateTime.parse(item['vencimento']);
                          final valor = double.tryParse(item['valor'].toString()) ?? 0.0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: Colors.white.withOpacity(0.95),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: Icon(
                                pago ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: pago ? Colors.green : Colors.orange,
                                size: 30,
                              ),
                              title: Text(item['descricao'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                              subtitle: Text("Vencimento: ${DateFormat('dd/MM/yyyy').format(vencimento)}", style: GoogleFonts.poppins()),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(moeda.format(valor), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(pago ? "PAGO" : "ABERTO", style: TextStyle(color: pago ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                  ],
                ),
              ),
        ),
      ],
    );
  }
}