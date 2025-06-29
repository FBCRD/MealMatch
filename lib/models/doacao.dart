class Doacao {
  final int? id;
  final String produto;
  final String quantidade;
  final String validade;
  final String endereco;
  final String? imagemPath;

  Doacao({
    this.id,
    required this.produto,
    required this.quantidade,
    required this.validade,
    required this.endereco,
    this.imagemPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produto': produto,
      'quantidade': quantidade,
      'validade': validade,
      'endereco': endereco,
      'imagemPath': imagemPath,
    };
  }

  factory Doacao.fromMap(Map<String, dynamic> map) {
    return Doacao(
      id: map['id'],
      produto: map['produto'],
      quantidade: map['quantidade'],
      validade: map['validade'],
      endereco: map['endereco'],
      imagemPath: map['imagemPath'],
    );
  }
}
