import 'package:medTalk/models/records.dart';
import 'package:medTalk/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "Medtalk.db";

  static Future<Database> _getDb() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT,
            address TEXT,
            userType TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE Records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            timestamp DATETIME NOT NULL
          )
        ''');
      },
      version: _version,
    );
  }

  // User table operations

  static Future<int> insertUser(User user) async {
    final db = await _getDb();
    return await db.insert(
      'Users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateUser(User user) async {
    final db = await _getDb();
    return await db.update(
      'Users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deleteUser(User user) async {
    final db = await _getDb();
    return await db.delete(
      'Users',
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Records table operations

  static Future<int> addRecord(Records record) async {
    final db = await _getDb();
    return await db.insert(
      'Records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateRecord(Records record) async {
    final db = await _getDb();
    return await db.update(
      'Records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> deleteRecord(Records record) async {
    final db = await _getDb();
    return await db.delete(
      'Records',
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }
}