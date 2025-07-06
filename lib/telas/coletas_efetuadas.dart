import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import para formatação de data
import '../models/doacao.dart';

class MinhasColetasPage extends StatelessWidget {
  const MinhasColetasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega o usuário logado para filtrar as coletas
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Função para formatar o Timestamp do Firebase para uma String de data
    String formatarData(Timestamp? timestamp) {
      if (timestamp == null) {
        return 'N/A';
      }
      final DateTime data = timestamp.toDate();
      return DateFormat('dd/MM/yyyy').format(data);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDB92E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Image.asset('assets/logo.png', height: 40),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.black,
              child: Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Coletas ja efetuadas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Cabeçalho da Tabela
              Row(
                children: [
                  _buildHeaderCell('Produto'),
                  _buildHeaderCell('Quantidade', alignment: TextAlign.center),
                  _buildHeaderCell('Data', alignment: TextAlign.end),
                ],
              ),
              const Divider(thickness: 1.5),
              // Lista de Coletas
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  // Consulta que busca as doações coletadas pela instituição logada
                  stream: FirebaseFirestore.instance
                      .collection('doacoes')
                      .where('idCessao', isEqualTo: currentUser?.uid)
                      .orderBy('dataColeta', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.black));
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar coletas.'));
                    }
                    if (currentUser == null) {
                      return const Center(child: Text('Usuário não autenticado.'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('Nenhuma coleta efetuada ainda.'));
                    }

                    final coletasDocs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: coletasDocs.length,
                      itemBuilder: (context, index) {
                        final coleta = Doacao.fromFirestore(coletasDocs[index]);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              _buildDataCell(coleta.produto),
                              _buildDataCell(coleta.quantidade, alignment: TextAlign.center),
                              _buildDataCell(formatarData(coleta.dataColeta), alignment: TextAlign.end),
                            ],
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

  // Widget auxiliar para criar as células do cabeçalho da tabela
  Widget _buildHeaderCell(String text, {TextAlign alignment = TextAlign.start}) {
    return Expanded(
      child: Text(
        text,
        textAlign: alignment,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // Widget auxiliar para criar as células de dados da tabela
  Widget _buildDataCell(String text, {TextAlign alignment = TextAlign.start}) {
    return Expanded(
      child: Text(text, textAlign: alignment),
    );
  }
}