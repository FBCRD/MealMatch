class Doacao {
  final int? id;
  final String produto;
  final String quantidade;
  final String validade;
  final String endereco;
  final String? imagemPath;
  bool foicoletada;

  Doacao({
    this.id,
    required this.produto,
    required this.quantidade,
    required this.validade,
    required this.endereco,
    this.imagemPath,
    this.foicoletada = false

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produto': produto,
      'quantidade': quantidade,
      'validade':validade,
      'endereco': endereco,
      'imagemPath': imagemPath,
      'foicoletada': foicoletada ? 1 : 0,
    };
  }



  factory
  Doacao.fromMap
      (
      Map<String, dynamic> map) {
    return Doacao(
      id: map['id'],
      produto: map['produto'],
      validade: map['validade'],
      quantidade: map['quantidade'],
      endereco: map['endereco'],
      imagemPath: map['imagemPath'],
      foicoletada: map['foicoletada'] == 1, // SQLite usa int para boolean
    );
  }





}

