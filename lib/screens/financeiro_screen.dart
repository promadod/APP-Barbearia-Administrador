import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/salao_service.dart';
import '../config.dart'; 

class FinanceiroScreen extends StatefulWidget {
  const FinanceiroScreen({super.key});

  @override
  State<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> {
  final SalaoService _service = SalaoService();
  String _periodoSelecionado = 'hoje';
  bool _isLoading = true;
  double _faturamento = 0.0;
  int _qtdServicos = 0;
  List<dynamic> _historico = [];

  @override
  void initState() {
    super.initState();
    _buscarDados();
  }

  void _buscarDados() async {
    setState(() => _isLoading = true);
    final dados = await _service.getRelatorioFinanceiro(_periodoSelecionado);
    
    if (mounted) {
      setState(() {
        _faturamento = double.tryParse(dados['faturamento_total'].toString()) ?? 0.0;
        _qtdServicos = int.tryParse(dados['quantidade_servicos'].toString()) ?? 0;
        _historico = dados['historico'] ?? [];
        _isLoading = false;
      });
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
        // 1. FOTO DE FUNDO DINÂMICA
        Positioned.fill(child: Image.asset(AppConfig.assetBackground, fit: BoxFit.cover)),
        
        // 2. MÁSCARA 0.60
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.60))),

        // 3. CONTEÚDO
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Financeiro", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor), 
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              children: [
                // --- FILTRO DE PERÍODO ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _periodoSelecionado,
                      isExpanded: true,
                      icon: Icon(Icons.calendar_month, color: primaryColor), 
                      items: const [
                        DropdownMenuItem(value: 'hoje', child: Text("Hoje")),
                        DropdownMenuItem(value: 'semana', child: Text("Esta Semana")),
                        DropdownMenuItem(value: 'mes', child: Text("Este Mês")),
                        DropdownMenuItem(value: 'ano', child: Text("Este Ano")),
                      ],
                      onChanged: (val) { if(val!=null) { setState(()=>_periodoSelecionado=val); _buscarDados(); } },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _isLoading 
                ? Expanded(child: Center(child: CircularProgressIndicator(color: primaryColor)))
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- CARD FATURAMENTO (GRANDE) ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor], 
                                begin: Alignment.topLeft, 
                                end: Alignment.bottomRight
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.white, size: 40),
                                const SizedBox(height: 10),
                                Text("Faturamento", style: GoogleFonts.poppins(color: Colors.white70)),
                                Text(
                                  moeda.format(_faturamento),
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // --- TÍTULO DO EXTRATO ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Serviços Realizados ($_qtdServicos)", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                              Icon(Icons.history, color: primaryColor), 
                            ],
                          ),
                          const SizedBox(height: 10),

                          // --- LISTA DETALHADA ---
                          if (_historico.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                children: [
                                  Icon(Icons.sentiment_dissatisfied, color: Colors.grey[400], size: 40),
                                  Text("Nenhum serviço finalizado neste período.", style: GoogleFonts.poppins(color: Colors.grey)),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _historico.length,
                              itemBuilder: (context, index) {
                                final item = _historico[index];
                                final cliente = item['cliente_nome'] ?? 'Cliente';
                                final servico = item['servico_nome'] ?? 'Serviço';
                                final valor = double.tryParse(item['valor_cobrado'].toString()) ?? 0.0;
                                final dataHora = DateTime.parse(item['data_hora_inicio']);
                                final hora = DateFormat('HH:mm').format(dataHora);
                                final dia = DateFormat('dd/MM').format(dataHora);

                                return Card(
                                  color: Colors.white.withOpacity(0.95),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: const Icon(Icons.check_circle, color: Colors.green),
                                    ),
                                    title: Text(servico, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cliente, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800])),
                                        Text("$dia às $hora", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    trailing: Text(
                                      moeda.format(valor),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16), 
                                    ),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 20),
                        ],
                      ),
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