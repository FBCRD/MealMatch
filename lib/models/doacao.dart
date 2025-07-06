import 'package:cloud_firestore/cloud_firestore.dart';

class Doacao {
  final String? id;
  final String produto;
  final String quantidade;
  final String validade;
  final String endereco;
  final String? imagemPath;
  final bool foicoletada;
  final Timestamp? dataColeta;
  final String? idDoador;
  final String? idCessao;
  final Timestamp? dataCadastro;

  Doacao({
    this.idCessao,
    this.dataColeta,
    this.idDoador,
    this.id,
    required this.produto,
    required this.quantidade,
    required this.validade,
    required this.endereco,
    this.imagemPath,
    this.foicoletada = false,
    this.dataCadastro

  });

  factory Doacao.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Doacao(
      // Pega o ID do documento
      id: snapshot.id,
      idCessao: data['idCessao'],
      dataColeta: data['dataColeta'],
      idDoador: data['idDoador'],
      produto: data['produto'] ?? '',
      quantidade: data['quantidade'] ?? '',
      validade: data['validade'] ?? '',
      endereco: data['endereco'] ?? '',
      imagemPath: data['imagemPath'],
      foicoletada: data['foicoletada'] ?? false,
      dataCadastro: data['dataCadastro'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dataColeta': dataColeta,
      'idCessao': idCessao,
      'produto': produto,
      'idDoador': idDoador,
      'quantidade': quantidade,
      'validade':validade,
      'endereco': endereco,
      if(imagemPath != null)'imagemPath':imagemPath,
      'foicoletada': foicoletada,
      'dataCadastro':FieldValue.serverTimestamp(),
    };
  }
}

