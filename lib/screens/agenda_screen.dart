import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/salao_service.dart';
import '../config.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final SalaoService _service = SalaoService();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _agendamentos = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _carregarAgendamentos();
  }

  void _carregarAgendamentos() async {
    setState(() => _isLoading = true);
    final lista = await _service.getHistoricoAgendamentos(); 
    Map<DateTime, List<dynamic>> tempMap = {};
    for (var item in lista) {
      final dataHora = DateTime.parse(item['data_hora_inicio']);
      final dataNormalizada = DateTime(dataHora.year, dataHora.month, dataHora.day);
      if (tempMap[dataNormalizada] == null) {
        tempMap[dataNormalizada] = [];
      }
      tempMap[dataNormalizada]!.add(item);
    }
    setState(() {
      _agendamentos = tempMap;
      _isLoading = false;
    });
  }

  List<dynamic> _getAgendamentosDoDia(DateTime dia) {
    final dataNormalizada = DateTime(dia.year, dia.month, dia.day);
    return _agendamentos[dataNormalizada] ?? [];
  }

  void _alterarStatus(int id, String novoStatus) async {
    setState(() => _isLoading = true);
    bool sucesso = await _service.atualizarStatusAgendamento(id, novoStatus);
    if (sucesso) {
      _carregarAgendamentos(); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Status alterado para $novoStatus"), backgroundColor: novoStatus == 'CONFIRMADO' ? Colors.green : Colors.red));
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao atualizar."), backgroundColor: Colors.red));
    }
  }

  void _abrirWhatsApp(String telefone) async {
    final numLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse("https://wa.me/55$numLimpo");
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao abrir WhatsApp")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // COR DINÂMICA (Azul ou Rosa)
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // 1. FOTO DE FUNDO DINÂMICA
        Positioned.fill(child: Image.asset(AppConfig.assetBackground, fit: BoxFit.cover)),
        
        // 2. MÁSCARA 0.60 (SOLICITADO)
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.60))),

        // 3. CONTEÚDO
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Agendamentos", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, 
          ),
          body: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95), 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: TableCalendar(
                  locale: 'pt_BR',
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                  eventLoader: _getAgendamentosDoDia,
                  headerStyle: HeaderStyle(
                    titleCentered: true, formatButtonVisible: false,
                    titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
                    rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: primaryColor.withOpacity(0.5), shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                    markerDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildListaAgendamentos(primaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListaAgendamentos(Color primaryColor) {
    final eventos = _getAgendamentosDoDia(_selectedDay!);
    if (_isLoading) return Center(child: CircularProgressIndicator(color: primaryColor));
    if (eventos.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.event_note, size: 50, color: Colors.grey[600]), const SizedBox(height: 10), Text("Sem agendamentos.", style: GoogleFonts.poppins(color: Colors.grey[800]))]));

    return ListView.builder(
      itemCount: eventos.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final item = eventos[index];
        final cliente = item['cliente_nome'] ?? 'Cliente';
        final servico = item['servico_nome'] ?? 'Serviço';
        final status = item['status'];
        final telefone = item['cliente_telefone'] ?? ''; 
        final dataHora = DateTime.parse(item['data_hora_inicio']);
        final hora = DateFormat('HH:mm').format(dataHora);
        Color corStatus = Colors.grey;
        if (status == 'PENDENTE') corStatus = Colors.orange;
        if (status == 'CONFIRMADO') corStatus = Colors.green;
        if (status == 'CONCLUIDO') corStatus = Colors.blue;
        if (status == 'CANCELADO') corStatus = Colors.red;

        return Card(
          elevation: 0,
          color: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Row(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
                        decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: Text(hora, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor))
                    ),
                    const SizedBox(width: 15),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cliente, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)), Text(servico, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey))])),
                  ])),
                  PopupMenuButton<String>(
                    onSelected: (valor) { if (valor == 'ZAP') _abrirWhatsApp(telefone); else _alterarStatus(item['id'], valor); },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'CONFIRMADO', child: Row(children: [Icon(Icons.check, color: Colors.green), SizedBox(width: 10), Text("Confirmar")])),
                      const PopupMenuItem(value: 'CONCLUIDO', child: Row(children: [Icon(Icons.monetization_on, color: Colors.blue), SizedBox(width: 10), Text("Concluir (Pago)")])),
                      const PopupMenuItem(value: 'CANCELADO', child: Row(children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 10), Text("Cancelar")])),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'ZAP', child: Row(children: [Icon(Icons.chat, color: Colors.green), SizedBox(width: 10), Text("WhatsApp")])),
                    ],
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: corStatus.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: corStatus, fontWeight: FontWeight.bold, fontSize: 12)))]),
              ],
            ),
          ),
        );
      },
    );
  }
}