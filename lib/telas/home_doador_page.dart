import 'package:flutter/material.dart';
import '../models/doacao.dart';
import '../database/doacao_database.dart';

class HomeDoadorPage extends StatefulWidget {
  const HomeDoadorPage({super.key});

  @override
  State<HomeDoadorPage> createState() => _HomeDoadorPageState();
}

class _HomeDoadorPageState extends State<HomeDoadorPage> {
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

  Future<void> excluirDoacao(int id) async {
    await DoacaoDatabase.instance.delete(id);
    carregarDoacoes(); // Atualiza a lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7D0C3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Image.asset('assets/logo.png', height: 80),
              const SizedBox(height: 12),
              const Text('Bem vindo, Doador',
                  style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro').then((_) {
                    carregarDoacoes(); // Atualiza após cadastro
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  elevation: 6,
                ),
                child: const Text('Fazer doação'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: doacoes.isEmpty
                        ? const Center(child: Text('Nenhuma doação cadastrada'))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Produtos doados',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: doacoes.length,
                            itemBuilder: (context, index) {
                              final d = doacoes[index];
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(d.produto,
                                              style: const TextStyle(
                                                  fontSize: 15)),
                                          Text('Validade: ${d.validade}',
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                          Text('Endereço: ${d.endereco}',
                                              style: const TextStyle(
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(d.quantidade,
                                            style: const TextStyle(fontSize: 15)),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/editar',
                                                  arguments: d,
                                                ).then((_) => carregarDoacoes());
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                excluirDoacao(d.id!);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
