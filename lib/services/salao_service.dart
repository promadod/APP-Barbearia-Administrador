import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'api_client.dart';

class SalaoService {
  final ApiClient _client = ApiClient();

  // Helper para configurar o token automaticamente
  Future<void> _configurarToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? prefs.getString('auth_token');
    if (token != null) _client.setToken(token);
  }

  // ==========================================================
  // PARTE 0: PERFIL DA LOJA
  // ==========================================================

  // 1. BUSCAR DADOS DO PRÓPRIO SALÃO
  Future<Map<String, dynamic>> getDadosSalao() async {
    try {
      await _configurarToken();
      final response = await _client.dio.get('salao/perfil/');

      final dados = response.data;

      
      return {
        'id': dados['id'], 
        'nome': dados['nome'],
        'telefone': dados['whatsapp'],
        'instagram': dados['instagram'],
        'endereco': dados['endereco'],
        'bloqueia_conflitos': dados['bloqueia_conflitos'],
      };
    } catch (e) {
      print('Erro ao buscar dados do salão: $e');
      return {};
    }
  }

  // 2. ATUALIZAR DADOS DO SALÃO
  Future<bool> atualizarDadosSalao({
    required String nome,
    required String telefone,
    required String instagram,
    required String endereco,
    required bool bloqueiaConflitos,
  }) async {
    try {
      await _configurarToken();
      await _client.dio.patch('salao/perfil/', data: {
        'nome': nome,
        'whatsapp': telefone,
        'instagram': instagram,
        'endereco': endereco,
        'bloqueia_conflitos': bloqueiaConflitos,
      });
      return true;
    } catch (e) {
      print('Erro ao atualizar salão: $e');
      return false;
    }
  }

  // ==========================================================
  // PARTE 1: DASHBOARD
  // ==========================================================
  Future<Map<String, dynamic>> getResumoHoje() async {
    try {
      await _configurarToken();
      final response = await _client.dio.get('agenda/relatorio_hoje/');
      return response.data;
    } catch (e) {
      print('Erro ao buscar resumo: $e');
      return {
        'faturamento_hoje': 0.0,
        'agendamentos_hoje': 0,
        'pendentes': 0,
        'alerta_estoque': 0
      };
    }
  }

  // ==========================================================
  // PARTE 2: SERVIÇOS
  // ==========================================================
  Future<List<dynamic>> getServicos() async {
    try {
      await _configurarToken();
      final response = await _client.dio.get('servicos/');
      return response.data;
    } catch (e) {
      print('Erro ao listar serviços: $e');
      return [];
    }
  }

  // Cadastrar Novo Serviço
  Future<bool> cadastrarServico(
      String nome, String preco, String duracao) async {
    try {
      await _configurarToken();

      double precoFinal = double.tryParse(preco.replaceAll(',', '.')) ?? 0.0;
      int duracaoFinal = int.tryParse(duracao) ?? 30;

      await _client.dio.post('servicos/', data: {
        'nome': nome,
        'preco': precoFinal,
        'duracao_minutos': duracaoFinal
      });
      return true;
    } catch (e) {
      print('Erro ao cadastrar serviço: $e');
      return false;
    }
  }

  // Editar Serviço
  Future<bool> editarServico(
      int id, String nome, String preco, String duracao) async {
    try {
      await _configurarToken();
      await _client.dio.patch('servicos/$id/', data: {
        "nome": nome,
        "preco": double.tryParse(preco.replaceAll(',', '.')) ?? 0.0,
        "duracao_minutos": int.tryParse(duracao) ?? 30,
      });
      return true;
    } catch (e) {
      print("Erro ao editar serviço: $e");
      return false;
    }
  }

  // Excluir Serviço
  Future<bool> excluirServico(int id) async {
    try {
      await _configurarToken();
      await _client.dio.delete('servicos/$id/');
      return true;
    } catch (e) {
      print("Erro ao excluir serviço: $e");
      return false;
    }
  }

  // ==========================================================
  // PARTE 3: AGENDA
  // ==========================================================
  Future<List<dynamic>> getAgendamentosPorData(DateTime data) async {
    try {
      await _configurarToken();

      String dataFormatada = DateFormat('yyyy-MM-dd').format(data);

      final response = await _client.dio.get('agenda/?data=$dataFormatada');

      return response.data;
    } catch (e) {
      print('Erro ao buscar agenda: $e');
      return [];
    }
  }

  // Atualizar Status (Aprovar/Recusar)
  Future<bool> atualizarStatusAgendamento(int id, String novoStatus) async {
    try {
      await _configurarToken();
      await _client.dio.patch('agenda/$id/', data: {'status': novoStatus});
      return true;
    } catch (e) {
      print('Erro ao atualizar status: $e');
      return false;
    }
  }

  // ==========================================================
  // PARTE 4: FINANCEIRO
  // ==========================================================
  Future<Map<String, dynamic>> getRelatorioFinanceiro(String periodo) async {
    try {
      await _configurarToken();
      final response = await _client.dio
          .get('agenda/relatorio_financeiro/?periodo=$periodo');
      return response.data;
    } catch (e) {
      print('Erro ao buscar financeiro: $e');
      return {
        'faturamento_total': 0.0,
        'quantidade_servicos': 0,
        'detalhe_pagamento': []
      };
    }
  }

  // ==========================================================
  // PARTE 5: BUSCA DE CLIENTES
  // ==========================================================
  Future<List<dynamic>> buscarClientes(String termo) async {
    try {
      await _configurarToken();
      final response = await _client.dio.get('clientes/?search=$termo');
      return response.data;
    } catch (e) {
      print('Erro ao buscar clientes: $e');
      return [];
    }
  }

  // ==========================================================
  // PARTE 6: HISTÓRICO DE AGENDAMENTOS (FILTROS)
  // ==========================================================
  Future<List<dynamic>> getHistoricoAgendamentos(
      {String? status, DateTime? data}) async {
    try {
      await _configurarToken();

      String query = 'agenda/?';

      if (status != null && status != 'TODOS') {
        query += 'status=$status&';
      }
      if (data != null) {
        String dataFormatada = DateFormat('yyyy-MM-dd').format(data);
        query += 'data=$dataFormatada&';
      }

      final response = await _client.dio.get(query);
      return response.data;
    } catch (e) {
      print('Erro ao buscar histórico: $e');
      return [];
    }
  }
}
