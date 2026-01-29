import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/salao_service.dart';

class PerfilLojaScreen extends StatefulWidget {
  const PerfilLojaScreen({super.key});

  @override
  State<PerfilLojaScreen> createState() => _PerfilLojaScreenState();
}

class _PerfilLojaScreenState extends State<PerfilLojaScreen> {
  final SalaoService _service = SalaoService();
  bool _isLoading = true;

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController(); 
  final _instagramController = TextEditingController();
  final _enderecoController = TextEditingController();
  
  // Variável para o Switch (Padrão true = Manicure/Salao)
  bool _bloqueiaConflitos = true; 

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    setState(() => _isLoading = true);
    final dados = await _service.getDadosSalao();
    
    if (dados.isNotEmpty) {
      _nomeController.text = dados['nome'] ?? '';
      _telefoneController.text = dados['telefone'] ?? '';
      _instagramController.text = dados['instagram'] ?? '';
      _enderecoController.text = dados['endereco'] ?? '';
      
      // Carrega a configuração do banco
      if (dados['bloqueia_conflitos'] != null) {
        setState(() {
          _bloqueiaConflitos = dados['bloqueia_conflitos'];
        });
      }
    }
    
    setState(() => _isLoading = false);
  }

  void _salvar() async {
    if (_nomeController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O nome é obrigatório.")));
       return;
    }

    setState(() => _isLoading = true);
    
    bool sucesso = await _service.atualizarDadosSalao(
      nome: _nomeController.text,
      telefone: _telefoneController.text,
      instagram: _instagramController.text,
      endereco: _enderecoController.text,
      bloqueiaConflitos: _bloqueiaConflitos, // Envia a escolha
    );

    setState(() => _isLoading = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil atualizado com sucesso!"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar."), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset('assets/images/login_bg.jpeg', fit: BoxFit.cover)),
        Positioned.fill(child: Container(color: Colors.white.withOpacity(0.7))),

        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Configurar Loja", style: GoogleFonts.poppins(color: const Color(0xFF880E4F), fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFFE91E63)),
          ),
          body: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCardInput(
                      icon: Icons.store, 
                      label: "Nome do Salão", 
                      controller: _nomeController
                    ),
                    const SizedBox(height: 15),
                    _buildCardInput(
                      icon: Icons.phone_iphone, 
                      label: "WhatsApp de Suporte", 
                      controller: _telefoneController,
                      hint: "Ex: 21999999999",
                      keyboard: TextInputType.phone
                    ),
                    const SizedBox(height: 15),
                    _buildCardInput(
                      icon: Icons.camera_alt, 
                      label: "Instagram (Usuário)", 
                      controller: _instagramController,
                      hint: "Ex: @salaodamaria"
                    ),
                    const SizedBox(height: 15),
                    _buildCardInput(
                      icon: Icons.location_on, 
                      label: "Endereço Completo", 
                      controller: _enderecoController,
                      maxLines: 2
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // --- O GRANDE DIFERENCIAL (SWITCH DE BLOQUEIO) ---
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _bloqueiaConflitos ? const Color(0xFFE91E63) : Colors.grey.shade300,
                          width: 1.5
                        ),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
                      ),
                      child: SwitchListTile(
                        activeColor: const Color(0xFFE91E63),
                        title: Text(
                          "Bloquear Horários Ocupados?", 
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                        subtitle: Text(
                          _bloqueiaConflitos 
                            ? "Ativado: Um cliente por vez (Ex: Manicure, Cabeleireiro)."
                            : "Desativado: Vários clientes no mesmo horário (Ex: Bronzeamento).",
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])
                        ),
                        value: _bloqueiaConflitos,
                        onChanged: (val) => setState(() => _bloqueiaConflitos = val),
                      ),
                    ),

                    const SizedBox(height: 30),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text("SALVAR ALTERAÇÕES", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildCardInput({
    required IconData icon, 
    required String label, 
    required TextEditingController controller, 
    String? hint,
    TextInputType? keyboard,
    int maxLines = 1
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFFE91E63)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}