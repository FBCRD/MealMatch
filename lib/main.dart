
import 'package:Tanamesa/telas/coletas_efetuadas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Tanamesa/telas/cadastro_doacao_page.dart';
import 'package:Tanamesa/telas/cadastro_usuario.dart';
import 'package:Tanamesa/telas/coleta_doacao_page.dart';
import 'package:Tanamesa/telas/home_doador_page.dart';
import 'package:Tanamesa/telas/home_instituicao_page.dart';
import 'package:Tanamesa/telas/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:Tanamesa/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tánamesa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      //DatePicker em português
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      // Define a rota inicial
      initialRoute: '/login',
      // Define todas as rotas nomeadas
      routes: {
        '/login': (context) => LoginPage(),
        '/cadastroUsuario': (context) => CadastroDoadorPage(),
        '/homeDoador': (context) => const HomeDoadorPage(),
        '/homeInstituicao': (context) => const HomeInstituicaoPage(),
        '/cadastroDoacao': (context) => const CadastroDoacaoPage(),
        '/coleta': (context) => const ColetaDoacaoPage(),
        '/minhasColetas': (context) => const MinhasColetasPage(),
      },
    );
  }
}