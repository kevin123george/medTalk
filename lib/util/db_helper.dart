import 'package:medTalk/models/records.dart';
import 'package:medTalk/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "Medtalk.db";
  DatabaseFactory? databaseFactory; // Add this line


  static Future<Database> _getDb() async {
    // print('path ist ' + dataDirectory.path);
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT,
            address TEXT,
            userType TEXT NOT NULL
          )
        ''');

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
  static Future<User> fetchUser() async {
    final db = await _getDb();
    final List<Map<String, dynamic>> results = await db.query(
      'Users',
      limit: 1,
    );

    if (results.isNotEmpty) {
      // User already exists in the database, return the fetched user
      final userData = results.first;
      final userTypeString = userData['userType'] as String;
      final userType = UserType.values.firstWhere(
            (type) => type.toString() == 'UserType.$userTypeString',
        orElse: () => UserType.Patient,
      );
      return User(
        id: userData['id'] as int,
        name: userData['name'] as String,
        email: userData['email'] as String?,
        address: userData['address'] as String?,
        userType: userType,
      );
    } else {
      // User doesn't exist in the database, return a new empty user
      return User(
        id: null,
        name: '',
        email: null,
        address: null,
        userType: UserType.Patient,
      );
    }
  }


  // Records table operations

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




