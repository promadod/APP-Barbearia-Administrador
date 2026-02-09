class AppConfig {
  
  static const bool isBarberVersion = true; 

  
  static String get appName => isBarberVersion ? 'Barber Gestão' : 'Beleza Gestão';
  static String get assetBackground => isBarberVersion ? 'assets/images/barber_bg.jpeg' : 'assets/images/login_bg.jpeg';
}