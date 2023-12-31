import 'dart:convert';

import 'package:medTalk/models/records.dart';
import 'package:medTalk/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/schedulers.dart';

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
            name TEXT,
            text TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            title TEXT,
            session TEXT
          )
        ''');

        await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_session ON Records (session)
        ''');
        await db.execute('''
          CREATE TABLE schedulers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            startDateTime INTEGER,
            endDateTime INTEGER,
            reminderTime INTEGER,
            body TEXT,
            reminderType TEXT,
            repeatType TEXT,
            isRecurrent BOOLEAN,
            notificationIds TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('''
          ALTER TABLE Users ADD COLUMN profileImagePath TEXT
        ''');
          await db.execute('''
              ALTER TABLE schedulers ADD COLUMN notificationIds TEXT
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

    final schedulersColumns = await database.rawQuery("PRAGMA table_info(schedulers)");
    final hasNotificationIdsColumn = schedulersColumns.any((column) => column['name'] == 'notificationIds');
    if (!hasNotificationIdsColumn) {
      await database.execute('ALTER TABLE schedulers ADD COLUMN notificationIds TEXT');
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
      if(latestRecord.text.split(" ").length +1 == record.text.split(" ").length || latestRecord.text.split(" ").length +2 == record.text.split(" ").length){
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
  static Future<List<Records>> searchRecords(String searchQuery) async {
    List<Records> recordsList = <Records>[];
    final db = await _getDb();
    final List<Map<String, dynamic>> records = await db.rawQuery('''
  SELECT * FROM Records
  WHERE LOWER(name) LIKE '%${searchQuery.toLowerCase()}%' 
     OR LOWER(title) LIKE '%${searchQuery.toLowerCase()}%'
  ORDER BY timestamp DESC
''');
    for (Map<String, dynamic> item in records) {
      Records record = new Records(
        id: item['id'],
        text: item['text'],
        name: item['name'],
        title: item['title'],
        timestamp: item['timestamp'],
      );
      recordsList.add(record);
    }

    return recordsList;
  }

  static Future<List<Records>> fetchRecordBySession(String session) async {
    List<Records> recordsList = <Records>[];
    final db = await _getDb();
    final List<Map<String, dynamic>> records = await db.query(
      'Records',
      where: 'session = ?',
      whereArgs: [session],
      orderBy: 'id'
    );
    for (Map<String, dynamic> item in records) {
      Records record = new Records(
        id: item['id'],
        text: item['text'],
        name: item['name'],
        title: item['title'],
        timestamp: item['timestamp'],
        session: item['session'],
      );
      recordsList.add(record);
    }

    return recordsList;
  }

  static String concatenateText(List<Records> sessionRecords) {
    String concatenatedText = '';
    String? session = '';
    for (Records record in sessionRecords) {
      concatenatedText += record.text + '. ';
      session = record.session;// You can change the separator if needed
    }
    return concatenatedText;
  }

  static Future<int> deleteRecordBySession(String session) async {
    final Database db = await _getDb();;
    return await db.delete(
      'Records',
      where: 'session = ?',
      whereArgs: [session],
    );
  }


  static Future<List> handleDuplicateSession() async {
    final db = await _getDb();

    // Fetch unique session IDs
    final List<Map<String, dynamic>> sessions = await db.rawQuery('''
      SELECT DISTINCT session FROM Records
    ''');

    List uniqueSessionIds = sessions.map((session) => session['session']).toList();
    print(uniqueSessionIds);
    for (String sessionId in uniqueSessionIds) {
      List<Records> session = await fetchRecordBySession(sessionId);
      if(session.length == 1){
        continue;
      }
      try{
        var latestRecord = session.last;
        latestRecord.text = concatenateText(session);
         deleteRecordBySession(sessionId);
         addRecord(latestRecord);
      }catch(e){

      }


    }

    return uniqueSessionIds;
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
        name: item['name'],
        title: item['title'],
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
          title: item['title'],
        name: item['name'],
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
        title:latestRecord['title'],
        name:latestRecord['name'],
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
        title: item['title'],
        name: item['name'],
        timestamp: item['timestamp'],
      );
      return record;
    }

    return null; // Return null if record with the given ID is not found
  }

  // Schedulers table operations

  static Future<int> insertScheduler(Schedulers scheduler) async {
    final Database db = await _getDb();;
    return await db.insert('schedulers', scheduler.toMap());
  }

  static Future<List<Schedulers>> getAllSchedulers() async {
    final Database db = await _getDb();
    final List<Map<String, dynamic>> maps = await db.query('schedulers',
      orderBy: 'id DESC',);
    return List.generate(maps.length, (index) {
      return Schedulers(
        id: maps[index]['id'],
        title: maps[index]['title'],
        startDateTime: maps[index]['startDateTime'],
        // endDateTime: DateTime.fromMicrosecondsSinceEpoch(maps[index]['endDateTime']),
        reminderTime: maps[index]['reminderTime'],
        body: maps[index]['body'],
        reminderType: getScheduleTypeFromString(maps[index]['reminderType']),
        repeatType: getRepeatTypeFromString(maps[index]['repeatType']),
        // repeatEndDate: DateTime.parse(maps[index]['repeatEndDate']),
        isRecurrent: maps[index]['isRecurrent'] == 1 ? true : false,
        notificationIds: List<int>.from(jsonDecode(maps[index]['notificationIds'])),
      );
    });
  }


  Future<int> updateScheduler(Schedulers scheduler) async {
    final Database db = await _getDb();;
    return await db.update(
      'schedulers',
      scheduler.toMap(),
      where: 'id = ?',
      whereArgs: [scheduler.id],
    );
  }

  Future<int> deleteScheduler(int id) async {
    final Database db = await _getDb();;
    return await db.delete(
      'schedulers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  static ScheduleType getScheduleTypeFromString(String type) {
    switch (type) {
      case 'Appointment':
        return ScheduleType.Appointment;
      case 'GeneralReminder':
        return ScheduleType.GeneralReminder;
      default:
        return ScheduleType.GeneralReminder;
    }
  }

  static RepeatType getRepeatTypeFromString(String type) {
    switch (type) {
      case 'Daily':
        return RepeatType.Daily;
      case 'Weekly':
        return RepeatType.Weekly;
      case 'Monthly':
        return RepeatType.Monthly;
      default:
        return RepeatType.Daily;
    }
  }


}




