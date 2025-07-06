
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/doacao.dart';


class HomeDoadorPage extends StatefulWidget {
  const HomeDoadorPage({super.key});

  @override
  State<HomeDoadorPage> createState() => _HomeDoadorPageState();
}

class _HomeDoadorPageState extends State<HomeDoadorPage> {
  String? nomeDoador;


  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario(); //Chama a função para buscar o nome do usuário
  }
  Future<void> _carregarDadosUsuario() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          nomeDoador = userDoc.get('nome');
        });
      }
    }
  }




  Future<void> _excluirDoacao(String doacaoId) async {
    try {
      await FirebaseFirestore.instance.collection('doacoes').doc(doacaoId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doação excluída com sucesso.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir doação: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //Pega o usuário logado para filtrar as doações
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFDB92E), // Cor de fundo
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.logout, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Image.asset('assets/logo.png', height: 150),
              const SizedBox(height: 12),
              Text('Bem vindo, ${nomeDoador ?? 'Doador'}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {

                    Navigator.pushNamed(context, '/cadastroDoacao');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Fazer Nova Doação', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Suas doações cadastradas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('doacoes')
                      .where('idDoador', isEqualTo: currentUser?.uid)
                      .orderBy('dataCadastro', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.black));
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Ocorreu um erro ao carregar os dados.'));
                    }
                    if (currentUser == null) {
                      return const Center(child: Text('Erro: usuário não encontrado.'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma doação cadastrada ainda.\nClique no botão acima para começar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      );
                    }
                    final doacoesDocs = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: doacoesDocs.length,
                      itemBuilder: (context, index) {
                        final doacao = Doacao.fromFirestore(doacoesDocs[index]);
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(doacao.produto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('Quantidade: ${doacao.quantidade}', style: const TextStyle(color: Colors.black87)),
                                      Text('Validade: ${doacao.validade}', style: const TextStyle(color: Colors.black87)),
                                      Text('Endereço: ${doacao.endereco}', style: const TextStyle(color: Colors.grey)),
                                      Text(
                                        'Status: ${doacao.foicoletada ? "Coletado" : "Aguardando coleta"}',
                                        style: TextStyle(
                                          color: doacao.foicoletada ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!doacao.foicoletada)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _excluirDoacao(doacao.id!),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}