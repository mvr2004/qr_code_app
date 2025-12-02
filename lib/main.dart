import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importação correta
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar serviço de localização
  final localizationService = LocalizationService();
  await localizationService.loadSavedLanguage();
  
  runApp(MyApp(localizationService: localizationService));
}

class MyApp extends StatelessWidget {
  final LocalizationService localizationService;

  const MyApp({super.key, required this.localizationService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: localizationService,
      child: const QRApp(),
    );
  }
}

class QRApp extends StatelessWidget {
  const QRApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return MaterialApp(
      title: 'RDS QR Code App',
      debugShowCheckedModeBanner: false,
      
      // Configurações de localização - IMPORTANTE!
      locale: localizationService.locale,
      localizationsDelegates: const [
        // Delegates padrão do Flutter para widgets Material
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // Para widgets Cupertino (iOS)
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'PT'), // Português
        Locale('en', 'US'), // Inglês
      ],
      
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}