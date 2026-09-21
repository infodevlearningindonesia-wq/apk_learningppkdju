import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:devlearning_indonesia/database/database_platform.dart';
import 'package:devlearning_indonesia/models/attendance_record.dart';
import 'package:devlearning_indonesia/models/user.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const _databaseName = 'devlearning.db';
  static const _databaseVersion = 7;
  static const usersTable = 'users';
  static const attendanceTable = 'attendance';

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
            role TEXT NOT NULL DEFAULT 'peserta',
            created_at TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 5) await _ensureUserColumns(database);
        if (oldVersion < 6) {
          await database.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS one_admin_only ON $usersTable(role) '
            "WHERE role = 'admin'",
          );
        }
        if (oldVersion < 7) await _createAttendanceTable(database);
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
    if (!existingColumns.contains('role')) {
      await database.execute(
        "ALTER TABLE $usersTable ADD COLUMN role TEXT NOT NULL DEFAULT 'peserta'",
      );
    }
  }

  static Future<void> _createAttendanceTable(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS $attendanceTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        email TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        UNIQUE(email, date)
      )
    ''');
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

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final database = await this.database;
    final updated = await database.update(
      usersTable,
      {'password': _hashPassword(newPassword)},
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    return updated > 0;
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
    UserRole? role,
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
    if (role != null) values['role'] = role.value;
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

  Future<int> saveAttendance({
    required String email,
    required String status,
    required String note,
  }) async {
    final database = await this.database;
    final normalizedEmail = email.trim().toLowerCase();
    final user = await getUserByEmail(normalizedEmail);
    final date = DateTime.now().toIso8601String().substring(0, 10);
    return database.insert(
      attendanceTable,
      {
        'user_id': user?['id'],
        'email': normalizedEmail,
        'date': date,
        'status': status,
        'note': note.trim(),
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceRecord>> getAttendanceForUser(String email) async {
    final database = await this.database;
    final rows = await database.query(
      attendanceTable,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      orderBy: 'date ASC',
    );
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<List<AttendanceRecord>> getAllAttendance() async {
    final database = await this.database;
    final rows = await database.query(attendanceTable, orderBy: 'date DESC');
    return rows.map(AttendanceRecord.fromMap).toList();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
