import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/base_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(const MeuSalaoApp());
}

class MeuSalaoApp extends StatelessWidget {
  const MeuSalaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bela Agenda App',
      debugShowCheckedModeBanner: false,

      // --- 1. MODO CLARO (BRANCO) ATIVADO ---
      themeMode: ThemeMode.light,

      // --- 2. CONFIGURAÇÃO DO TEMA (SEM O ERRO DO CARDTHEME) ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Cores Principais (Rosa e Branco)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63), // Rosa Pink Base
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFFF48FB1),
          surface: Colors.white, // Isso garante que os Cards fiquem brancos!
          background: const Color(0xFFFAFAFA), // Fundo da tela quase branco
        ),

        scaffoldBackgroundColor: const Color(0xFFFAFAFA),

        // Barra Superior (Branca com ícones Rosa)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFE91E63)),
          titleTextStyle: TextStyle(
              color: Color(0xFF880E4F),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),

        // Botões (Rosa)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),

        // Campos de Texto (Brancos com borda rosa suave)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.pink.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2),
          ),
          prefixIconColor: const Color(0xFFE91E63),
        ),
      ),

      // Configuração básica de Dark (caso um dia precise)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: Color(0xFFE91E63)),
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const CheckAuth(),
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool? _isLogged;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  void _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() => _isLogged = token != null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLogged == null) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63))));
    }
    return _isLogged! ? const BaseScreen() : const LoginScreen();
  }
}
