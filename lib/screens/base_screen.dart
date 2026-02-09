import 'package:flutter/material.dart';
import '../config.dart'; 
import 'dashboard_screen.dart';
import 'agenda_screen.dart';
import 'menu_screen.dart';
import 'busca_cliente_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _currentIndex = 0;

  void _mudarAba(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final primaryColor = Theme.of(context).primaryColor;
    
    
    final List<Widget> telas = [
      DashboardScreen(irParaAba: _mudarAba),
      const BuscaClienteScreen(),
      const AgendaScreen(),
      const MenuScreen(),
    ];

    return Stack(
      children: [
        // 1. IMAGEM DE FUNDO GLOBAL 
        Positioned.fill(
          child: Image.asset(
            AppConfig.assetBackground, 
            fit: BoxFit.cover,
          ),
        ),
        
        // 2. CAMADA BRANCA SEMI-TRANSPARENTE
        
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.92), 
          ),
        ),

        // 3. O CONTEÚDO DO APP
        Scaffold(
          backgroundColor: Colors.transparent, 
          body: telas[_currentIndex],
          
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ]
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _mudarAba,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              
              
              
              selectedItemColor: primaryColor, 
              
              unselectedItemColor: Colors.grey[400],
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.space_dashboard_rounded), label: 'Início'),
                BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Buscar'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Agenda'),
                BottomNavigationBarItem(icon: Icon(Icons.menu_rounded), label: 'Menu'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}