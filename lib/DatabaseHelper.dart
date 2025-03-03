import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databasehelper {
  static final Databasehelper instance = Databasehelper._init();
  static Database? _database;

  Databasehelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String dbName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUser(String name, String email) async {
    final db = await Databasehelper.instance.database;
    return await db.insert('users', {
      'name': name,
      'email': email,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await Databasehelper.instance.database;
    return await db.query('users');
  }

  Future<int> updateUser(int id, String name, String email) async {
    final db = await Databasehelper.instance.database;
    return await db.update(
      'users',
      {'name': name, 'email': email},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await Databasehelper.instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
  
}
