import 'package:flutter/material.dart';
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
    final List<Widget> telas = [
      DashboardScreen(irParaAba: _mudarAba),
      const BuscaClienteScreen(),
      const AgendaScreen(),
      const MenuScreen(),
    ];

    return Scaffold(
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
          // --- CORES DO MENU ---
          selectedItemColor: const Color(0xFFE91E63), // Rosa Pink
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
    );
  }
}