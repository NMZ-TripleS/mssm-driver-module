import 'dart:async';

import 'package:mssm_driver_app/database/models/models.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PersonDatabaseProvider {
  PersonDatabaseProvider._();

  static final PersonDatabaseProvider db = PersonDatabaseProvider._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await getDatabaseInstance();
    return _database!;
  }

  Future<Database> getDatabaseInstance() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'way_cost.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE ways(`id` INTEGER PRIMARY KEY, `date` TEXT, `from` TEXT,`to` TEXT)',
        );
        db.execute(
          'CREATE TABLE costs(`id` INTEGER PRIMARY KEY, `title` TEXT, `description` TEXT,`date` TEXT,`amount` TEXT,`cost_type` TEXT,`way_id` TEXT)',
        );
        return;
      },
      version: 1,
    );
  }

  Future<void> insertWay(Way way) async {
    final db = await database;
    await db.insert(
      'ways',
      way.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCost(Cost cost) async {
    final db = await database;
    await db.insert(
      'costs',
      cost.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Way>> ways() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ways',
      orderBy: "id DESC",
    );

    return List.generate(maps.length, (i) {
      return Way(
          id: maps[i]['id'],
          from: maps[i]['from'],
          to: maps[i]['to'],
          date: maps[i]['date']);
    });
  }

  Future<List<Cost>> costs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'costs',
      orderBy: "id DESC",
    );

    return List.generate(maps.length, (i) {
      return Cost(
          id: maps[i]['id'],
          title: maps[i]['title'],
          description: maps[i]['description'],
          amount: maps[i]['amount'],
          costType: maps[i]['cost_type'] == "income"
              ? CostType.income
              : CostType.outcome,
          wayId: maps[i]['way_id'],
          date: maps[i]['date']);
    });
  }

  Future<void> updateWay(Way way) async {
    final db = await database;
    await db.update(
      'ways',
      way.toMap(),
      where: 'id = ?',
      whereArgs: [way.id],
    );
  }

  Future<void> updateCost(Cost cost) async {
    final db = await database;
    await db.update(
      'costs',
      cost.toMap(),
      where: 'id = ?',
      whereArgs: [cost.id],
    );
  }

  Future<void> deleteWay(int id) async {
    final db = await database;
    await db.delete(
      'ways',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCost(int id) async {
    final db = await database;
    await db.delete(
      'costs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  deleteAllWays() async {
    final db = await database;
    db.delete("ways");
  }
}
