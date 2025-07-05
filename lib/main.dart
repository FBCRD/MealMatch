// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:Tanamesa/telas/cadastro_doacao_page.dart';
import 'package:Tanamesa/telas/cadastro_usuario.dart';
import 'package:Tanamesa/telas/coleta_doacao_page.dart';
import 'package:Tanamesa/telas/home_doador_page.dart';
import 'package:Tanamesa/telas/home_instituicao_page.dart';
import 'package:Tanamesa/telas/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealMatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Exemplo de fonte padrão
      ),
      // Necessário para o DatePicker em português
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
        // A rota de edição não foi criada, mas pode ser adicionada aqui
        // '/editar': (context) => EditarDoacaoPage(), 
      },
    );
  }
}