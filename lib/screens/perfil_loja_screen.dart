import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../services/salao_service.dart';
import '../config.dart'; 

class PerfilLojaScreen extends StatefulWidget {
  const PerfilLojaScreen({super.key});

  @override
  State<PerfilLojaScreen> createState() => _PerfilLojaScreenState();
}

class _PerfilLojaScreenState extends State<PerfilLojaScreen> {
  final SalaoService _service = SalaoService();
  bool _isLoading = true;

  // Dados para edição
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _instagramController = TextEditingController();
  final _enderecoController = TextEditingController();

  // Variável para o Switch
  bool _bloqueiaConflitos = true;

  // Variável para armazenar o ID (para o Link)
  int? _salaoId;

  // Variável de Diagnóstico (Para vermos o que o servidor mandou)
  String _debugDadosRecebidos = "Carregando...";

  // URL Base do App Cliente (Seu link do Vercel)
  final String _baseUrlAppCliente = "https://barber-agendamento.vercel.app/#/";

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    setState(() => _isLoading = true);

    // Busca os dados brutos do Service
    final dados = await _service.getDadosSalao();

    setState(() {
      _isLoading = false;
      // Salva o JSON bruto para exibir no quadro de diagnóstico se precisar
      _debugDadosRecebidos = dados.toString();

      if (dados.isNotEmpty) {
        // --- PROTEÇÃO DE ID ---
        // Tenta converter para Inteiro, mesmo se vier como String "1"
        if (dados['id'] != null) {
          _salaoId = int.tryParse(dados['id'].toString());
        }

        _nomeController.text = dados['nome'] ?? '';
        _telefoneController.text = dados['telefone'] ?? '';
        _instagramController.text = dados['instagram'] ?? '';
        _enderecoController.text = dados['endereco'] ?? '';

        if (dados['bloqueia_conflitos'] != null) {
          _bloqueiaConflitos = dados['bloqueia_conflitos'];
        }
      }
    });
  }

  void _salvar() async {
    if (_nomeController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("O nome é obrigatório.")));
      return;
    }

    setState(() => _isLoading = true);

    bool sucesso = await _service.atualizarDadosSalao(
      nome: _nomeController.text,
      telefone: _telefoneController.text,
      instagram: _instagramController.text,
      endereco: _enderecoController.text,
      bloqueiaConflitos: _bloqueiaConflitos,
    );

    setState(() => _isLoading = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Perfil atualizado com sucesso!"),
          backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Erro ao salvar."), backgroundColor: Colors.red));
    }
  }

  // Função para Copiar Link
  void _copiarLink() {
    if (_salaoId == null) return;

    final link = "$_baseUrlAppCliente$_salaoId";

    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Link copiado: $link"),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // COR DINÂMICA
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // 1. FOTO DINÂMICA
        Positioned.fill(
            child: Image.asset(AppConfig.assetBackground, fit: BoxFit.cover)),
        
        // 2. MÁSCARA 0.60
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.60))),
        
        // 3. CONTEÚDO
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Configurar Loja",
                style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor), 
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- QUADRO DE DIAGNÓSTICO (Só aparece se der erro) ---
                      if (_salaoId == null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              const Text("⚠️ MODO DIAGNÓSTICO ⚠️",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              const SizedBox(height: 5),
                              const Text(
                                  "O ID da loja não foi encontrado. Veja abaixo o que o App recebeu do sistema:",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12)),
                              const Divider(),
                              Text(_debugDadosRecebidos,
                                  style: const TextStyle(
                                      fontFamily: "Courier", fontSize: 10)),
                            ],
                          ),
                        ),

                      // --- CARD DO LINK DE AGENDAMENTO ---
                      if (_salaoId != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: primaryColor.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.share,
                                  size: 40, color: primaryColor),
                              const SizedBox(height: 10),
                              Text("Seu Link de Agendamento",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87)),
                              const SizedBox(height: 5),
                              Text(
                                "Envie este link para seus clientes agendarem:",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "$_baseUrlAppCliente$_salaoId",
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor), 
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(Icons.copy,
                                          color: primaryColor), 
                                      onPressed: _copiarLink,
                                      tooltip: "Copiar Link",
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // --- FORMULÁRIO ---
                      _buildCardInput(
                          icon: Icons.store,
                          label: "Nome do Salão",
                          controller: _nomeController,
                          primaryColor: primaryColor),
                      const SizedBox(height: 15),
                      _buildCardInput(
                          icon: Icons.phone_iphone,
                          label: "WhatsApp de Suporte",
                          controller: _telefoneController,
                          hint: "Ex: 21999999999",
                          keyboard: TextInputType.phone,
                          primaryColor: primaryColor),
                      const SizedBox(height: 15),
                      _buildCardInput(
                          icon: Icons.camera_alt,
                          label: "Instagram (Usuário)",
                          controller: _instagramController,
                          hint: "Ex: @salaodamaria",
                          primaryColor: primaryColor),
                      const SizedBox(height: 15),
                      _buildCardInput(
                          icon: Icons.location_on,
                          label: "Endereço Completo",
                          controller: _enderecoController,
                          maxLines: 2,
                          primaryColor: primaryColor),

                      const SizedBox(height: 25),

                      // SWITCH DE BLOQUEIO
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: _bloqueiaConflitos
                                  ? primaryColor
                                  : Colors.grey.shade300,
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: SwitchListTile(
                          activeColor: primaryColor, 
                          title: Text("Bloquear Horários Ocupados?",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(
                              _bloqueiaConflitos
                                  ? "Ativado: Um cliente por vez (Ex: Manicure, Cabeleireiro)."
                                  : "Desativado: Vários clientes no mesmo horário (Ex: Bronzeamento).",
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.grey[600])),
                          value: _bloqueiaConflitos,
                          onChanged: (val) =>
                              setState(() => _bloqueiaConflitos = val),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _salvar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor, 
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          child: Text("SALVAR ALTERAÇÕES",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCardInput(
      {required IconData icon,
      required String label,
      required TextEditingController controller,
      required Color primaryColor, 
      String? hint,
      TextInputType? keyboard,
      int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3))
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryColor), 
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}