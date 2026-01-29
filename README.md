# APP Bela Agenda  SaaS - App Admin (Gestão)

Aplicativo desenvolvido em **Flutter** para gestão completa de estabelecimentos de beleza (Salões, Barbearias, Esmalterias e Clínicas de Estética). Este é o painel administrativo utilizado pelos donos das lojas para gerenciar seus negócios dentro do ecossistema SaaS.

## 📱 Funcionalidades Principais

### 📅 Gestão de Agenda Inteligente
* Visualização de agendamentos solicitados pelos clientes.
* **Aprovação/Recusa** de horários.
* **Controle de Conflitos:** Sistema inteligente que impede (ou permite) agendamentos simultâneos dependendo do nicho (ex: Salão vs Bronzeamento), configurável pelo usuário.

### 💰 Controle Financeiro
* **Dashboard em Tempo Real:** Faturamento do dia e agendamentos pendentes.
* **Extrato Detalhado:** Histórico de serviços realizados, valores recebidos e filtro por período (Hoje, Semana, Mês, Ano).
* **Gestão de Assinatura (SaaS):** O lojista visualiza suas faturas mensais do sistema e copia a chave PIX para pagamento diretamente no app.


### 🛠️ Gerenciamento Operacional

* **Horário de Funcionamento:** Definição dos dias e horários de abertura e fechamento da loja.
* **Perfil da Loja:** Edição de dados públicos (Instagram, WhatsApp, Endereço) que aparecem no App do Cliente.
* **Catálogo de Serviços:** Cadastro de serviços com nome, preço, duração (usado para cálculo automático de disponibilidade).

## 📸 Screenshots

<p align="center">
  <img src="screenshots/menu.jpeg" width="200" alt="Menu Principal">
  <img src="screenshots/financeiro.jpeg" width="200" alt="Financeiro e Extrato">
  <img src="screenshots/dashboard.jpeg" width="200" alt="Home Page">
</p>

<p align="center">
  <img src="screenshots/login.jpeg" width="200" alt="Login do app">
  <img src="screenshots/configuracao.jpeg" width="200" alt="Configuração da Loja">
  <img src="screenshots/historico.jpeg" width="200" alt="Historico de agendamentos">
</p>

## 🚀 Tecnologias Utilizadas

* **Flutter** (Framework UI)
* **Dart** (Linguagem)
* **Dio** (Cliente HTTP para conexão com API REST)
* **Shared Preferences** (Armazenamento local de token e sessão)
* **Intl**         (Formatação de datas e moedas BRL)
* **Google Fonts** (Tipografia personalizada)
* **Url Launcher** (Abrir WhatsApp e Mapas externos)

## ⚙️ Instalação e Configuração

### Pré-requisitos
* Flutter SDK.
* Backend Django rodando



📂 Estrutura de Pastas

    lib/components: Widgets reutilizáveis (Cards, Botões).

    lib/screens: Telas do aplicativo (Login, Dashboard, Agenda, Financeiro).

    lib/services: Lógica de conexão com a API (Dio, Repositórios).

    lib/utils: Formatadores e funções auxiliares.

    assets: Imagens e ícones.