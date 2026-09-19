import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/attendance.dart';
import '../models/user.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static const _databaseName = 'devlearning.db';
  static const _databaseVersion = 5;
  static bool _factoryInitialized = false;

  Database? _database;

  static Future<void> init() async {
    if (_factoryInitialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _factoryInitialized = true;
  }

  Future<Database> get database async {
    await init();
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (database, version) => _ensureTables(database),
      onUpgrade: (database, oldVersion, newVersion) =>
          _ensureTables(database),
      onOpen: _ensureTables,
    );
  }

  Future<void> _ensureTables(Database database) async {
    await _ensureUsersTable(database);
    await _ensureAttendanceTable(database);
  }

  Future<void> _ensureUsersTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL DEFAULT '',
        phone TEXT NOT NULL DEFAULT '',
        password TEXT NOT NULL DEFAULT '',
        city TEXT NOT NULL DEFAULT '',
        photo_path TEXT NOT NULL DEFAULT ''
      )
    ''');

    final columns = await database.rawQuery('PRAGMA table_info(users)');
    final existingColumns = columns
        .map((column) => column['name'] as String)
        .toSet();
    const requiredColumns = {
      'name': "TEXT NOT NULL DEFAULT ''",
      'email': "TEXT NOT NULL DEFAULT ''",
      'phone': "TEXT NOT NULL DEFAULT ''",
      'password': "TEXT NOT NULL DEFAULT ''",
      'city': "TEXT NOT NULL DEFAULT ''",
      'photo_path': "TEXT NOT NULL DEFAULT ''",
    };

    for (final entry in requiredColumns.entries) {
      if (!existingColumns.contains(entry.key)) {
        await database.execute(
          'ALTER TABLE users ADD COLUMN ${entry.key} ${entry.value}',
        );
      }
    }
  }

  Future<int> insertUser(User user) async {
    final database = await this.database;
    return database.insert('users', user.toMap());
  }

  Future<int> updateUser(User user) async {
    final database = await this.database;
    final values = user.toMap()..remove('id');
    return database.update(
      'users',
      values,
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final database = await this.database;
    return database.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> _ensureAttendanceTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        subject TEXT NOT NULL DEFAULT 'Umum',
        date TEXT NOT NULL,
        check_in TEXT NOT NULL,
        check_out TEXT
      )
    ''');

    final columns = await database.rawQuery('PRAGMA table_info(attendance)');
    final existingColumns = columns.map((column) => column['name'] as String).toSet();
    if (!existingColumns.contains('subject')) {
      await database.execute(
        "ALTER TABLE attendance ADD COLUMN subject TEXT NOT NULL DEFAULT 'Umum'",
      );
    }
  }

  Future<Attendance?> getTodayAttendance(
    String email,
    String date,
    String subject,
  ) async {
    final database = await this.database;
    final rows = await database.query(
      'attendance',
      where: 'email = ? AND date = ? AND subject = ?',
      whereArgs: [email, date, subject],
      limit: 1,
    );
    return rows.isEmpty ? null : Attendance.fromMap(rows.first);
  }

  Future<int> insertAttendance(Attendance attendance) async {
    final database = await this.database;
    return database.insert('attendance', {
      'email': attendance.email,
      'subject': attendance.subject,
      'date': attendance.date,
      'check_in': attendance.checkIn.toIso8601String(),
      'check_out': attendance.checkOut?.toIso8601String(),
    });
  }

  Future<int> updateAttendanceCheckout(int id, DateTime checkOut) async {
    final database = await this.database;
    return database.update(
      'attendance',
      {'check_out': checkOut.toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Attendance>> getAttendanceForEmail(String email) async {
    final database = await this.database;
    final rows = await database.query(
      'attendance',
      where: 'email = ?',
      whereArgs: [email],
      orderBy: 'id DESC',
    );
    return rows.map(Attendance.fromMap).toList();
  }

  Future<List<User>> getUsers() async {
    final database = await this.database;
    final rows = await database.query('users', orderBy: 'id DESC');
    return rows.map(User.fromMap).toList();
  }

  Future<User?> getUserByEmail(String email) async {
    final database = await this.database;
    final rows = await database.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : User.fromMap(rows.first);
  }
}
