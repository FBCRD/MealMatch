import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doacao.dart';

class HomeInstituicaoPage extends StatefulWidget {
  const HomeInstituicaoPage({super.key});

  @override
  State<HomeInstituicaoPage> createState() => _HomeInstituicaoPageState();
}

class _HomeInstituicaoPageState extends State<HomeInstituicaoPage> {
  Doacao? coletaAtual;
  String? nomeInstituicao;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
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
          nomeInstituicao = userDoc.get('nome');
        });
      }
    }
  }

  void _finalizarColetaAtual() {
    setState(() {
      // Ao definir como nulo, o card de coleta atual desaparecerá.
      coletaAtual = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coleta finalizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  void abrirNoGoogleMaps(String enderecoDestino) async {
    final queryDestino = Uri.encodeComponent(enderecoDestino);
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$queryDestino');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Google Maps.')),
      );
    }
  }

  Future<void> _navegarParaColeta() async {
    final resultado = await Navigator.pushNamed(context, '/coleta');
    if (resultado != null && resultado is Doacao) {
      setState(() {
        coletaAtual = resultado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDB92E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _carregarDadosUsuario();
          },
          color: Colors.black,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                Image.asset('assets/logo.png', height: 80),
                const SizedBox(height: 12),
                Text(
                    'Bem vindo, ${nomeInstituicao ?? 'Instituição'}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navegarParaColeta,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black ,foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Fazer Coleta', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { Navigator.pushNamed(context, '/minhasColetas');},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Minhas coletas', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 24),

                if (coletaAtual != null)
                  _buildCardColetaAtual(coletaAtual!),

                _buildCardDoacoesDisponiveis(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardColetaAtual(Doacao coleta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sua coleta atual', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('Lembre-se de coletar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => abrirNoGoogleMaps(coleta.endereco),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                child: const Text('Ver rota'),
              ),
              ElevatedButton(
                onPressed: _finalizarColetaAtual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.check, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(coleta.produto, style: const TextStyle(fontSize: 16)),
              Text(coleta.quantidade, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(coleta.endereco, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCardDoacoesDisponiveis() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Válido até Hoje', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Doações disponíveis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Divider(height: 24),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('doacoes')
                .where('foicoletada', isEqualTo: false)
                .orderBy('dataCadastro', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar doações.'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Nenhuma doação disponível no momento.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                );
              }
              final doacoesDocs = snapshot.data!.docs;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doacoesDocs.length,
                itemBuilder: (context, index) {
                  final doacao = Doacao.fromFirestore(doacoesDocs[index]);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(doacao.produto, style: const TextStyle(fontSize: 16)),
                            Text(doacao.quantidade, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(doacao.endereco, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
              );
            },
          ),
        ],
      ),
    );
  }
}