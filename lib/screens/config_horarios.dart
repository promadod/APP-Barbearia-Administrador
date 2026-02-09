import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../config.dart'; 

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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro de permissão. Faça login novamente.")),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao carregar horários.")),
          );
        }
      }
      if (mounted) setState(() => _isLoading = false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar. Tente novamente.")),
        );
      }
      _carregarHorarios();
    }
  }

  Future<void> _selecionarHora(int index, String campo, String valorAtual) async {
    
    final primaryColor = Theme.of(context).primaryColor;

    TimeOfDay horaInicial = const TimeOfDay(hour: 9, minute: 0);
    try {
      final parts = valorAtual.split(':');
      horaInicial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      builder: (context, child) {
        // TEMA DO RELÓGIO DINÂMICO
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: primaryColor,
              dialBackgroundColor: primaryColor.withOpacity(0.1),
              hourMinuteColor: primaryColor.withOpacity(0.1),
              hourMinuteTextColor: primaryColor,
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
    final primaryColor = Theme.of(context).primaryColor;

    // 1. ESTRUTURA STACK (Fundo + Máscara + Conteúdo)
    return Stack(
      children: [
        // A. FOTO
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
            title: Text(
              "Horários de Funcionamento", 
              style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor), 
          ),
          body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
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
                    color: Colors.white.withOpacity(0.95), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Column(
                      children: [
                        SwitchListTile(
                          activeColor: primaryColor, 
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
                                _buildTimeButton(primaryColor, "Abertura", abertura, () => _selecionarHora(index, 'abertura', abertura)),
                                Icon(Icons.arrow_forward, color: primaryColor), 
                                _buildTimeButton(primaryColor, "Fechamento", fechamento, () => _selecionarHora(index, 'fechamento', fechamento)),
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

  Widget _buildTimeButton(Color primaryColor, String label, String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor.withOpacity(0.3)), 
          borderRadius: BorderRadius.circular(10),
          color: primaryColor.withOpacity(0.05), 
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
            Text(
              time,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor) 
            ),
          ],
        ),
      ),
    );
  }
}