import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
        CREATE TABLE pacientes(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          nome TEXT,
          idade INT,
          sexo CHAR
        )
      """);
  }

  // inicia o banco de dados
  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'pacientes.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // cria novo item
  static Future<int> createItem(String nome, int idade, String sexo) async {
    final db = await SQLHelper.db();

    final data = {'nome': nome, 'idade': idade, 'sexo': sexo};
    final id = await db.insert('pacientes', data);
    return id;
  }

  // le os dados da tabela
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('pacientes', orderBy: "id");
  }

  // alterar item
  static Future<int> updateItem(
      int id, String nome, int idade, String sexo) async {
    final db = await SQLHelper.db();

    final data = {
      'nome': nome,
      'idade': idade,
      'sexo': sexo
    };

    final result =
        await db.update('pacientes', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // deletar itens
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("pacientes", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("$err");
    }
  }
}
