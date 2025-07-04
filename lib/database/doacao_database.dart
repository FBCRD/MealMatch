import 'package:mealmatch/models/doacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';



class DoacaoDatabase {
  static final DoacaoDatabase instance = DoacaoDatabase._init();
  static Database? _database;

  DoacaoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('doacoes.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Deleta a tabela, se já existir

    // Cria a tabela com a coluna imagemPath
    await db.execute('''
    CREATE TABLE doacoes2 (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      produto TEXT NOT NULL,
      quantidade TEXT NOT NULL,
      validade TEXT NOT NULL,
      endereco TEXT NOT NULL,
      imagemPath TEXT
    )
  ''');
  }

  Future<int> create(Doacao doacao) async {
    final db = await instance.database;
    return await db.insert('doacoes2', doacao.toMap());
  }

  Future<List<Doacao>> readAll() async {
    final db = await instance.database;
    final result = await db.query('doacoes2');

    return result.map((json) => Doacao.fromMap(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('doacoes2', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
