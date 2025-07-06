/*
Não ta sendo utilizada ja que esta sendo armazenado no Firebase, deixei aqui caso eu fosse reutilizar quando desse seguimento no projeto


import 'package:Tanamesa/models/doacao.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

import '../models/doacao.dart';




class DoacaoDatabase {
  static final DoacaoDatabase instance = DoacaoDatabase._init();
  static Database? _database;

  DoacaoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('doacoes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> marcarComoColetada(int id) async {
    final db = await instance.database;

    await db.update(
      'doacoes2',
      {'foicoletada': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> _createDB(Database db, int version) async {


    // Cria a tabela com a coluna imagemPath
    await db.execute('''
    CREATE TABLE doacoes2 (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      produto TEXT NOT NULL,
      quantidade TEXT NOT NULL,
      validade TEXT NOT NULL,
      endereco TEXT NOT NULL,
      imagemPath TEXT,
      foicoletada INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }
  Future<Doacao> create(Doacao doacao) async {
    final db = await instance.database;
    final id = await db.insert('doacoes2', doacao.toMap());
    return Doacao(
      id: id,
      produto: doacao.produto,
      quantidade: doacao.quantidade,
      validade: doacao.validade,
      endereco: doacao.endereco,
      imagemPath: doacao.imagemPath,
      foicoletada: doacao.foicoletada,
    );
  }


  Future<List<Doacao>> readAll() async {
    final db = await instance.database;
    final result = await db.query('doacoes2', orderBy: 'id DESC');

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
*/
