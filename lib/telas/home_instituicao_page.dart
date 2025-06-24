import 'package:flutter/material.dart';
import '../models/doacao.dart';
import '../database/doacao_database.dart';

class HomeInstituicaoPage extends StatefulWidget {
  const HomeInstituicaoPage({super.key});

  @override
  State<HomeInstituicaoPage> createState() => _HomeInstituicaoPageState();
}

class _HomeInstituicaoPageState extends State<HomeInstituicaoPage> {
  List<Doacao> doacoes = [];

  @override
  void initState() {
    super.initState();
    carregarDoacoes();
  }

  Future<void> carregarDoacoes() async {
    final lista = await DoacaoDatabase.instance.readAll();
    setState(() {
      doacoes = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doações Disponíveis')),
      body: RefreshIndicator(
        onRefresh: carregarDoacoes,
        child: ListView.builder(
          itemCount: doacoes.length,
          itemBuilder: (context, index) {
            final doacao = doacoes[index];
            return ListTile(
              title: Text('${doacao.produto} - ${doacao.quantidade}'),
              subtitle: Text('Endereço: ${doacao.endereco} | Validade: ${doacao.validade}'),
              onTap: () {
                Navigator.pushNamed(context, '/coleta');
              },
            );
          },
        ),
      ),
    );
  }
}
