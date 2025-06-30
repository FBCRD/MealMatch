import 'package:flutter/material.dart';
import 'package:mealmatch/telas/cadastro_doacao_page.dart';
import 'package:mealmatch/telas/cadastro_usuario.dart';
import 'package:mealmatch/telas/coleta_doacao_page.dart';
import 'package:mealmatch/telas/home_doador_page.dart';
import 'package:mealmatch/telas/home_instituicao_page.dart';
import 'package:mealmatch/telas/login_page.dart';


void main() {
  runApp(MealMatchApp());
}

class MealMatchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealMatch',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => CadastroDoacaoPage(),
        '/homeDoador': (context) => HomeDoadorPage(),
        '/homeInstituicao': (context) => HomeInstituicaoPage(),
        '/cadastro': (context) => CadastroDoacaoPage(),
        '/coleta': (context) => ColetaDoacaoPage(),
      },
    );
  }
}
