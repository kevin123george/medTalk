import 'package:animated_responsive_layout/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "Chat.db";

  static Future<Database> _getDb() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async => await db.execute(
            "CREATE TABLE Users (id INT PRIMARY KEY AUTO_INCREMENT,first_name VARCHAR(255) NOT NULL,last_name VARCHAR(255) NOT NULL,avatar_url VARCHAR(255) NOT NULL,last_active DATETIME NOT NULL);"),
        version: _version);
  }

  static Future<int> addUser(User user) async {
    final db = await _getDb();
    return await db.insert("Users", user as Map<String, Object?>,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateUser(User user) async {
    final db = await _getDb();
    return await db.update("Users", user as Map<String, Object?>,
        where: 'id = ?',
        whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteUser(User user) async {
    final db = await _getDb();
    return await db.delete(
      "Users",
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<List<User>?> getAllNotes() async {
    final db = await _getDb();
    final List<User> users = db.query("User") as List<User>;
    if (users.isEmpty) {
      return null;
    }
    return users;
  }
}
