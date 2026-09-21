import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:devlearning_indonesia/database/database_platform.dart';
import 'package:devlearning_indonesia/models/user.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'devlearning.db';
  static const _databaseVersion = 4;
  static const usersTable = 'users';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    await initializeDatabasePlatform();
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasePath, _databaseName),
      version: _databaseVersion,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE $usersTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            phone TEXT NOT NULL,
            password TEXT NOT NULL,
            city TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 4) await _ensureUserColumns(database);
      },
    );

    return _database!;
  }

  static Future<void> _ensureUserColumns(Database database) async {
    final columns = await database.rawQuery('PRAGMA table_info($usersTable)');
    final existingColumns = columns
        .map((column) => column['name'] as String)
        .toSet();

    if (!existingColumns.contains('phone')) {
      await database.execute(
        "ALTER TABLE $usersTable ADD COLUMN phone TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!existingColumns.contains('city')) {
      await database.execute(
        "ALTER TABLE $usersTable ADD COLUMN city TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!existingColumns.contains('created_at')) {
      await database.execute(
        "ALTER TABLE $usersTable ADD COLUMN created_at TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  Future<int> insertUser(User user) async {
    final database = await this.database;
    await _ensureUserColumns(database);
    final values = user.toMap()..['password'] = _hashPassword(user.password);
    return database.insert(
      usersTable,
      values,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<User>> getUsers() async {
    final database = await this.database;
    final rows = await database.query(usersTable, orderBy: 'id DESC');
    return rows.map(User.fromMap).toList();
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final database = await this.database;
    final users = await database.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    return users.isEmpty ? null : users.first;
  }

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final database = await this.database;
    final users = await database.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (users.isEmpty) return null;

    final user = users.first;
    final storedPassword = user['password'] as String? ?? '';
    final hashedPassword = _hashPassword(password);
    if (storedPassword == hashedPassword) return user;

    // Upgrade accounts created before password hashing was introduced.
    if (storedPassword == password) {
      await database.update(
        usersTable,
        {'password': hashedPassword},
        where: 'id = ?',
        whereArgs: [user['id']],
      );
      return {...user, 'password': hashedPassword};
    }

    return null;
  }

  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<int> updateUser({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String city,
    String? password,
  }) async {
    final database = await this.database;
    final values = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'city': city.trim(),
    };
    if (password != null && password.isNotEmpty) {
      values['password'] = _hashPassword(password);
    }

    return database.update(
      usersTable,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final database = await this.database;
    return database.delete(usersTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
