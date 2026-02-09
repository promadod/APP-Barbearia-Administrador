import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/salao_service.dart';
import '../config.dart'; 

class HistoricoAgendamentosScreen extends StatefulWidget {
  const HistoricoAgendamentosScreen({super.key});

  @override
  State<HistoricoAgendamentosScreen> createState() => _HistoricoAgendamentosScreenState();
}

class _HistoricoAgendamentosScreenState extends State<HistoricoAgendamentosScreen> {
  final SalaoService _service = SalaoService();
  
  // Filtros
  String _statusSelecionado = 'TODOS';
  DateTime? _dataSelecionada;
  
  List<dynamic> _agendamentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarHistorico();
  }

  void _buscarHistorico() async {
    setState(() => _isLoading = true);
    final lista = await _service.getHistoricoAgendamentos(
      status: _statusSelecionado,
      data: _dataSelecionada
    );
    // Ordena do mais recente para o mais antigo
    lista.sort((a, b) => b['data_hora_inicio'].compareTo(a['data_hora_inicio']));
    setState(() {
      _agendamentos = lista;
      _isLoading = false;
    });
  }

  void _limparData() {
    setState(() {
      _dataSelecionada = null;
      _buscarHistorico();
    });
  }

  Future<void> _selecionarData() async {
    // Cor Dinâmica para o Calendário
    final primaryColor = Theme.of(context).primaryColor;

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        // Personaliza o calendário com a cor do tema (Azul ou Rosa)
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor, 
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dataSelecionada = picked);
      _buscarHistorico();
    }
  }

  @override
  Widget build(BuildContext context) {
    // COR DINÂMICA
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // A. FOTO DE FUNDO DINÂMICA
        Positioned.fill(
          child: Image.asset(AppConfig.assetBackground, fit: BoxFit.cover),
        ),
        
        // B. MÁSCARA BRANCA 0.60
        Positioned.fill(
          child: Container(color: Colors.white.withOpacity(0.60)),
        ),

        // C. CONTEÚDO
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Histórico Completo", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor), 
          ),
          body: Column(
            children: [
              // --- BARRA DE FILTROS ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Dropdown de Status
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _statusSelecionado,
                                isExpanded: true,
                                icon: Icon(Icons.filter_list, color: primaryColor), 
                                items: const [
                                  DropdownMenuItem(value: 'TODOS', child: Text("Todos Status")),
                                  DropdownMenuItem(value: 'PENDENTE', child: Text("Pendentes")),
                                  DropdownMenuItem(value: 'CONFIRMADO', child: Text("Confirmados")),
                                  DropdownMenuItem(value: 'CONCLUIDO', child: Text("Concluídos")),
                                  DropdownMenuItem(value: 'CANCELADO', child: Text("Cancelados")),
                                ],
                                onChanged: (val) {
                                  setState(() => _statusSelecionado = val!);
                                  _buscarHistorico();
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Botão de Data
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: _selecionarData,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1), 
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: primaryColor.withOpacity(0.3))
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: primaryColor), 
                                  const SizedBox(width: 5),
                                  Text(
                                    _dataSelecionada == null 
                                      ? "Data" 
                                      : DateFormat('dd/MM').format(_dataSelecionada!),
                                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold), 
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_dataSelecionada != null)
                          IconButton(onPressed: _limparData, icon: const Icon(Icons.close, color: Colors.red))
                      ],
                    ),
                  ],
                ),
              ),
              
              // --- LISTA DE RESULTADOS ---
              Expanded(
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator(color: primaryColor))
                  : _agendamentos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text("Nenhum histórico encontrado.", style: GoogleFonts.poppins(color: Colors.grey[600])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _agendamentos.length,
                        itemBuilder: (context, index) {
                          final item = _agendamentos[index];
                          final status = item['status'];
                          final cliente = item['cliente_nome'] ?? 'Cliente';
                          final servico = item['servico_nome'] ?? 'Serviço';
                          final dataHora = DateTime.parse(item['data_hora_inicio']);
                          
                          Color corStatus = Colors.grey;
                          IconData icone = Icons.info;
                          
                          if (status == 'PENDENTE') { corStatus = Colors.orange; icone = Icons.access_time; }
                          if (status == 'CONFIRMADO') { corStatus = Colors.blue; icone = Icons.check_circle_outline; }
                          if (status == 'CONCLUIDO') { corStatus = Colors.green; icone = Icons.monetization_on; }
                          if (status == 'CANCELADO') { corStatus = Colors.red; icone = Icons.cancel_outlined; }

                          return Card(
                            elevation: 2,
                            color: Colors.white.withOpacity(0.95),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Coluna da Data/Hora
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Column(
                                      children: [
                                        Text(DateFormat('dd/MM').format(dataHora), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(DateFormat('HH:mm').format(dataHora), style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  // Dados
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cliente, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(servico, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
                                        const SizedBox(height: 5),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: corStatus.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4)
                                          ),
                                          child: Text(status, style: TextStyle(color: corStatus, fontSize: 10, fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Icon(icone, color: corStatus),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}