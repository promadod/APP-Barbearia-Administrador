import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/salao_service.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({super.key});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final SalaoService _service = SalaoService();
  List<dynamic> _servicos = [];
  bool _isLoading = true;

  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  
  // Controladores separados para Horas e Minutos
  final _horasController = TextEditingController();
  final _minutosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  void _carregarServicos() async {
    setState(() => _isLoading = true);
    final lista = await _service.getServicos();
    setState(() {
      _servicos = lista;
      _isLoading = false;
    });
  }

  // Função para formatar o texto bonito na lista
  String _formatarDuracaoTexto(int minutosTotais) {
    if (minutosTotais < 60) {
      return "$minutosTotais min";
    } else {
      int horas = minutosTotais ~/ 60;
      int minutos = minutosTotais % 60;
      
      if (minutos == 0) {
        return "${horas}h"; 
      } else {
        String minFormatado = minutos.toString().padLeft(2, '0');
        return "${horas}h ${minFormatado}min"; 
      }
    }
  }

  // --- MODAL DE CADASTRO/EDIÇÃO ---
  void _abrirModalFormulario({Map<String, dynamic>? servicoParaEditar}) {
    final bool isEditando = servicoParaEditar != null;

    if (isEditando) {
      _nomeController.text = servicoParaEditar['nome'];
      _precoController.text = servicoParaEditar['preco'].toString();
      
      // Converte o total de minutos de volta para Horas/Minutos no form
      int totalMinutos = servicoParaEditar['duracao_minutos'] ?? 30;
      int h = totalMinutos ~/ 60;
      int m = totalMinutos % 60;
      
      _horasController.text = h > 0 ? h.toString() : "";
      _minutosController.text = m.toString();
    } else {
      _nomeController.clear();
      _precoController.clear();
      _horasController.clear();
      _minutosController.text = "30"; // Padrão
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          isEditando ? "Editar Serviço" : "Novo Serviço", 
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: "Nome do Serviço", prefixIcon: Icon(Icons.label_important)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precoController,
              decoration: const InputDecoration(labelText: "Preço (R\$)", prefixIcon: Icon(Icons.attach_money)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            
            Text("Duração do Serviço:", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
            const SizedBox(height: 5),
            
            // Row com dois campos (Horas e Minutos)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _horasController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Horas",
                      prefixIcon: Icon(Icons.access_time),
                      suffixText: "h",
                      hintText: "0"
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _minutosController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Minutos",
                      prefixIcon: Icon(Icons.timer),
                      suffixText: "min",
                      hintText: "30"
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63), foregroundColor: Colors.white),
            onPressed: () async {
              if (_nomeController.text.isEmpty || _precoController.text.isEmpty) return;

              // Calcula o total antes de salvar
              int h = int.tryParse(_horasController.text) ?? 0;
              int m = int.tryParse(_minutosController.text) ?? 0;
              int totalMinutosCalculado = (h * 60) + m;

              if (totalMinutosCalculado == 0) totalMinutosCalculado = 30; // Evita duração zero

              Navigator.pop(context); 
              setState(() => _isLoading = true);

              bool sucesso;
              if (isEditando) {
                sucesso = await _service.editarServico(
                  servicoParaEditar['id'],
                  _nomeController.text, 
                  _precoController.text, 
                  totalMinutosCalculado.toString()
                );
              } else {
                sucesso = await _service.cadastrarServico(
                  _nomeController.text, 
                  _precoController.text,
                  totalMinutosCalculado.toString()
                );
              }

              if (sucesso) {
                _carregarServicos();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(isEditando ? "Atualizado com sucesso!" : "Criado com sucesso!"), 
                  backgroundColor: Colors.green
                ));
              } else {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar."), backgroundColor: Colors.red));
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  // --- MENU DE OPÇÕES (EDITAR/EXCLUIR) ---
  void _mostrarOpcoes(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(item['nome'], style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: Text("Editar Serviço", style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _abrirModalFormulario(servicoParaEditar: item);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text("Excluir Serviço", style: GoogleFonts.poppins(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarExclusao(item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmarExclusao(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tem certeza?"),
        content: Text("Deseja apagar '${item['nome']}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              bool ok = await _service.excluirServico(item['id']);
              if (ok) _carregarServicos();
            }, 
            child: const Text("Excluir", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // 1. APLICANDO O STACK PARA O FUNDO (Igual ao Financeiro)
    return Stack(
      children: [
        // FOTO
        Positioned.fill(
          child: Image.asset('assets/images/login_bg.jpeg', fit: BoxFit.cover),
        ),
        // MÁSCARA BRANCA (0.7)
        Positioned.fill(
          child: Container(color: Colors.white.withOpacity(0.7)),
        ),

        // 2. SCAFFOLD TRANSPARENTE
        Scaffold(
          backgroundColor: Colors.transparent, // Transparente para ver a foto
          appBar: AppBar(
            title: Text("Meus Serviços", style: GoogleFonts.poppins(color: const Color(0xFF880E4F), fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color(0xFFE91E63)), // Ícone Rosa
          ),
          body: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _servicos.length,
                itemBuilder: (context, index) {
                  final item = _servicos[index];
                  final preco = double.tryParse(item['preco'].toString()) ?? 0.0;
                  final duracaoMinutos = item['duracao_minutos'] ?? 30;
                  
                  // Usa a função formatadora na visualização
                  final duracaoTexto = _formatarDuracaoTexto(duracaoMinutos);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white.withOpacity(0.95), // Card levemente transparente
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: InkWell( 
                      onTap: () => _mostrarOpcoes(item), 
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFE91E63).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.spa, color: Color(0xFFE91E63)),
                          ),
                          title: Text(item['nome'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          
                          // Mostra "2h 30min" ao invés de "150 min"
                          subtitle: Text("Duração: $duracaoTexto", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          
                          trailing: Text(
                            moeda.format(preco), 
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFFE91E63), fontSize: 16)
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _abrirModalFormulario(),
            backgroundColor: const Color(0xFFE91E63),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}