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

    final database = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT,
            address TEXT,
            userType TEXT NOT NULL,
            profileImagePath TEXT
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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('''
          ALTER TABLE Users ADD COLUMN profileImagePath TEXT
        ''');
        }
        await db.execute('PRAGMA user_version = $newVersion');
      },
      version: _version,
    );
    final columns = await database.rawQuery("PRAGMA table_info(Users)");
    final hasProfileImagePathColumn = columns.any((column) => column['name'] == 'profileImagePath');

    if (!hasProfileImagePathColumn) {
      await database.execute('ALTER TABLE Users ADD COLUMN profileImagePath TEXT');
    }

    return database;

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
    print('user submit db ist ' );
    print(user.profileImagePath);
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
        profileImagePath: userData['profileImagePath'] as String?,
      );
    } else {
      // User doesn't exist in the database, return a new empty user
      return User(
        id: null,
        name: '',
        email: null,
        address: null,
        userType: UserType.Patient,
        profileImagePath: null,
      );
    }
  }



  // Records table operations

  static Future<int> addRecord(Records record) async {
    final db = await _getDb();
    Records? latestRecord = await fetchLatestRecord();
    if (latestRecord != null) {
      if (record.text == latestRecord.text || record.text.isEmpty || record.text.length ==0){
        return 0;
      }
      if(latestRecord.text.split(" ").length +1 == record.text.split(" ").length){
        print("there is a duplicate ");
        await deleteRecord(latestRecord);
        // Records records = Records(text: record.text, timestamp: record.timestamp, id: latestRecord.id);
        // return updateRecord(records);
      }
    }
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
        'Records',
        orderBy: 'timestamp DESC',
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
      orderBy: 'timestamp DESC',
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
  static Future<Records?> fetchLatestRecord() async {
    final db = await _getDb();
    final List<Map<String, dynamic>> records = await db.query(
      'Records',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (records.isNotEmpty) {
      Map<String, dynamic> latestRecord = records.first;
      return Records(
        id: latestRecord['id'],
        text: latestRecord['text'],
        timestamp: latestRecord['timestamp'],
      );
    }

    return null; // Return null if no records found
  }

  void deleteOlderThanSixMonths(List<Records> recordsList) {
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 30 * 6));

    recordsList.removeWhere((record) {
      final recordDate = DateTime.fromMillisecondsSinceEpoch(record.timestamp * 1000);
      return recordDate.isBefore(sixMonthsAgo);
    });
  }



  static Future<Records?> fetchRecordById(int id) async {
    final db = await _getDb();
    final List<Map<String, dynamic>> records = await db.query(
      'Records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (records.isNotEmpty) {
      Map<String, dynamic> item = records.first;
      Records record = Records(
        id: item['id'],
        text: item['text'],
        timestamp: item['timestamp'],
      );
      return record;
    }

    return null; // Return null if record with the given ID is not found
  }

}




