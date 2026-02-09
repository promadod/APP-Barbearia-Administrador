import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/base_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(const MeuSalaoApp());
}

class MeuSalaoApp extends StatelessWidget {
  const MeuSalaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a cor fixa baseada na versão do App (Config)
    final primaryColor = AppConfig.isBarberVersion ? const Color(0xFF1565C0) : const Color(0xFFE91E63);
    final seedColor = AppConfig.isBarberVersion ? const Color(0xFF0D47A1) : const Color(0xFFE91E63);

    return MaterialApp(
      title: AppConfig.appName, 
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          primary: primaryColor,
          surface: Colors.white,
          background: const Color(0xFFFAFAFA),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        
        // Barra Superior
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: primaryColor),
          titleTextStyle: TextStyle(
            color: seedColor, 
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),

        // Inputs
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          prefixIconColor: primaryColor,
        ),
        
        progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryColor),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _isLogged! ? const BaseScreen() : const LoginScreen();
  }
}