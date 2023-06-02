import 'package:medTalk/models/records.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "Medtalk.db";

  static Future<Database> _getDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
      version: _version,
    );
  }

  static Future<int> addRecord(Records record) async {
    final db = await _getDb();
    return await db.insert("Records", record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateRecord(Records record) async {
    final db = await _getDb();
    return await db.update("Records", record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<int> deleteRecord(Records record) async {
    final db = await _getDb();
    return await db.delete(
      "Records",
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<List<Records>> fetchAllRecords() async {
    List<Records> recordsList = <Records>[];
    final db = await _getDb();
    final List<Map<String, dynamic>> records = await db.query(
        'Records'
    );

    for (Map<String, dynamic> item in records) {
      Records record = new Records(
        id: item['id'],
        text: item['text'],
        timestamp: item['timestamp'],
      );
      recordsList.add(record);
    }

    return recordsList;
  }

  static Future<List<Records>> fetchAllRecordsInTimeRange(DateTime start, DateTime end) async {
    List<Records> recordsList = <Records>[];
    final db = await _getDb();
    final List<Map<String, dynamic>> records = await db.query(
      'Records',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    for (Map<String, dynamic> item in records) {
      Records record = new Records(
        id: item['id'],
        text: item['text'],
        timestamp: item['timestamp'],
      );
      recordsList.add(record);
    }

    return recordsList;
  }



}




