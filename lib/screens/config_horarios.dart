import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';

class ConfigHorariosScreen extends StatefulWidget {
  const ConfigHorariosScreen({super.key});

  @override
  State<ConfigHorariosScreen> createState() => _ConfigHorariosScreenState();
}

class _ConfigHorariosScreenState extends State<ConfigHorariosScreen> {
  final ApiClient _client = ApiClient();
  List<dynamic> _horarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHorarios();
  }

  // --- CONFIGURAÇÃO DO TOKEN ---
  Future<void> _configurarAutenticacao() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      _client.dio.options.headers['Authorization'] = 'Token $token';
    } else {
      print("DEBUG: ERRO - Nenhum token encontrado no celular!");
    }
  }

  Future<void> _carregarHorarios() async {
    await _configurarAutenticacao();

    try {
      final response = await _client.dio.get('horarios/inicializar/');

      setState(() {
        _horarios = response.data;
        _horarios.sort((a, b) => a['dia_semana'].compareTo(b['dia_semana']));
        _isLoading = false;
      });
    } catch (e) {
      print("ERRO DETALHADO: $e");
      if (e is DioException && e.response?.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro de permissão. Faça login novamente.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao carregar horários.")),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _atualizarHorario(int index, Map<String, dynamic> dadosNovos) async {
    if (_client.dio.options.headers['Authorization'] == null) {
      await _configurarAutenticacao();
    }

    setState(() {
      _horarios[index] = {..._horarios[index], ...dadosNovos};
    });

    try {
      final id = _horarios[index]['id'];
      await _client.dio.patch('horarios/$id/', data: dadosNovos);
    } catch (e) {
      print("Erro ao salvar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao salvar. Tente novamente.")),
      );
      _carregarHorarios();
    }
  }

  Future<void> _selecionarHora(int index, String campo, String valorAtual) async {
    TimeOfDay horaInicial = const TimeOfDay(hour: 9, minute: 0);
    try {
      final parts = valorAtual.split(':');
      horaInicial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      builder: (context, child) {
        // TEMA DO RELÓGIO AJUSTADO PARA ROSA
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFE91E63), // Rosa
            colorScheme: const ColorScheme.light(primary: Color(0xFFE91E63)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: const Color(0xFFE91E63),
              dialBackgroundColor: Colors.pink[50],
            )
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final horaFormatada = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      _atualizarHorario(index, {campo: horaFormatada});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. ESTRUTURA STACK (Fundo + Máscara + Conteúdo)
    return Stack(
      children: [
        // A. FOTO
        Positioned.fill(
          child: Image.asset('assets/images/login_bg.jpeg', fit: BoxFit.cover),
        ),
        // B. MÁSCARA BRANCA 0.7
        Positioned.fill(
          child: Container(color: Colors.white.withOpacity(0.7)),
        ),

        // C. CONTEÚDO
        Scaffold(
          backgroundColor: Colors.transparent, // Importante para ver o fundo
          appBar: AppBar(
            title: Text(
              "Horários de Funcionamento", 
              style: GoogleFonts.poppins(color: const Color(0xFF880E4F), fontWeight: FontWeight.bold)
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFFE91E63)), // Ícone Rosa
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _horarios.length,
                  itemBuilder: (context, index) {
                    final item = _horarios[index];
                    final diaNome = item['dia_nome'] ?? "Dia $index";
                    final bool ativo = item['ativo'] ?? false;
                    final String abertura = item['abertura']?.toString().substring(0, 5) ?? "09:00";
                    final String fechamento = item['fechamento']?.toString().substring(0, 5) ?? "18:00";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white.withOpacity(0.95), // Card levemente transparente
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                      child: Column(
                        children: [
                          SwitchListTile(
                            activeColor: const Color(0xFFE91E63), // Switch Rosa
                            title: Text(
                              diaNome,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                            value: ativo,
                            onChanged: (val) => _atualizarHorario(index, {'ativo': val}),
                          ),
                          if (ativo)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildTimeButton(
                                    "Abertura",
                                    abertura,
                                    () => _selecionarHora(index, 'abertura', abertura)
                                  ),
                                  const Icon(Icons.arrow_forward, color: Color(0xFFE91E63)), // Seta Rosa
                                  _buildTimeButton(
                                    "Fechamento",
                                    fechamento,
                                    () => _selecionarHora(index, 'fechamento', fechamento)
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTimeButton(String label, String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)), // Borda Rosa Suave
          borderRadius: BorderRadius.circular(10),
          color: Colors.pink[50]?.withOpacity(0.5), // Fundo rosinha bem leve
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
            Text(
              time,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFE91E63))
            ),
          ],
        ),
      ),
    );
  }
}