import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:devlearning_indonesia/database/database_platform.dart';
import 'package:devlearning_indonesia/models/attendance_record.dart';
import 'package:devlearning_indonesia/models/learning_material.dart';
import 'package:devlearning_indonesia/models/user.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance =
      DatabaseHelper._();

  static const String _databaseName =
      'devlearning.db';

  // Naikkan versi database agar semua instance lama otomatis migrasi ke schema terbaru.
  static const int _databaseVersion = 14;

  static const String usersTable = 'users';
  static const String attendanceTable = 'attendance';
  static const String materialsTable = 'learning_materials';

  Database? _database;

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    await initializeDatabasePlatform();

    final databasePath =
        await getDatabasesPath();

    final path = join(
      databasePath,
      _databaseName,
    );

    _database = await openDatabase(
      path,
      version: _databaseVersion,

      onCreate: (db, version) async {
        await _createUsersTable(db);
        await _createAttendanceTable(db);
        await _createMaterialsTable(db);
        await _createIndexes(db);
      },

      onUpgrade: (
        db,
        oldVersion,
        newVersion,
      ) async {
        await _migrateDatabase(
          db,
          oldVersion,
          newVersion,
        );
      },

      onDowngrade:
          onDatabaseDowngradeDelete,
    );

    // Pastikan database lama tetap diperbaiki.
    await _ensureUsersTable(
      _database!,
    );

    await _ensureUserColumns(
      _database!,
    );

    await _ensureAttendanceTable(
      _database!,
    );

    await _ensureAttendanceColumns(
      _database!,
    );
    await _createMaterialsTable(_database!);

    await _createIndexes(
      _database!,
    );

    return _database!;
  }

  // ============================================================
  // MIGRATION
  // ============================================================

  static Future<void> _migrateDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await _ensureUsersTable(db);

    await _ensureUserColumns(db);

    await _ensureAttendanceTable(db);

    await _ensureAttendanceColumns(db);
    await _createMaterialsTable(db);

    await _createIndexes(db);
  }

  // ============================================================
  // USERS TABLE
  // ============================================================

  static Future<void> _createUsersTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $usersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL DEFAULT '',
        password TEXT NOT NULL DEFAULT '',
        city TEXT NOT NULL DEFAULT '',
        role TEXT NOT NULL DEFAULT 'peserta',
        profile_photo TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  static Future<void> _ensureUsersTable(
    Database db,
  ) async {
    await _createUsersTable(db);
  }

  // ============================================================
  // USERS COLUMNS
  // ============================================================

  static Future<void> _ensureUserColumns(
    Database db,
  ) async {
    final result = await db.rawQuery(
      'PRAGMA table_info($usersTable)',
    );

    final columns = result
        .map(
          (row) => row['name']?.toString(),
        )
        .whereType<String>()
        .toSet();

    if (!columns.contains('name')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN name TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('email')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN email TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('phone')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN phone TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('password')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN password TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('city')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN city TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('role')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN role TEXT NOT NULL DEFAULT 'peserta'",
      );
    }

    if (!columns.contains('profile_photo')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN profile_photo TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('created_at')) {
      await db.execute(
        "ALTER TABLE $usersTable "
        "ADD COLUMN created_at TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  // ============================================================
  // ATTENDANCE TABLE
  // ============================================================

  static Future<void> _createAttendanceTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $attendanceTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        email TEXT NOT NULL DEFAULT '',
        date TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'Hadir',
        note TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT '',
        check_in TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  static Future<void> _ensureAttendanceTable(
    Database db,
  ) async {
    await _createAttendanceTable(db);
  }

  // ============================================================
  // ATTENDANCE COLUMNS
  // ============================================================

  static Future<void> _ensureAttendanceColumns(
    Database db,
  ) async {
    final result = await db.rawQuery(
      'PRAGMA table_info($attendanceTable)',
    );

    final columns = result
        .map(
          (row) => row['name']?.toString(),
        )
        .whereType<String>()
        .toSet();

    if (!columns.contains('user_id')) {
      await db.execute(
        "ALTER TABLE $attendanceTable "
        "ADD COLUMN user_id INTEGER",
      );
    }

    if (!columns.contains('email')) {
      await db.execute(
        "ALTER TABLE $attendanceTable "
        "ADD COLUMN email TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('date')) {
      await db.execute(
        "ALTER TABLE $attendanceTable "
        "ADD COLUMN date TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('status')) {
      await db.execute(
        "ALTER TABLE $attendanceTable "
        "ADD COLUMN status TEXT NOT NULL DEFAULT 'Hadir'",
      );
    }

    if (!columns.contains('note')) {
      await db.execute(
        "ALTER TABLE $attendanceTable "
        "ADD COLUMN note TEXT NOT NULL DEFAULT ''",
      );
    }

    if (!columns.contains('created_at')) {
      await db.execute(
        "ALTER TABLE $attendanceTable "
        "ADD COLUMN created_at TEXT NOT NULL DEFAULT ''",
      );
    }

    // ==========================================================
    // CHECK IN
    // ==========================================================

    if (!columns.contains('check_in')) {
      await db.execute(
        "ALTER TABLE $attendanceTable "
        "ADD COLUMN check_in TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  // ============================================================
  // INDEX
  // ============================================================

  static Future<void> _createIndexes(
    Database db,
  ) async {
    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_attendance_email
      ON $attendanceTable(email)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_attendance_date
      ON $attendanceTable(date)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_attendance_email_date
      ON $attendanceTable(email, date)
    ''');
  }

  static Future<void> _createMaterialsTable(Database db) => db.execute('''
    CREATE TABLE IF NOT EXISTS $materialsTable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      content TEXT NOT NULL DEFAULT '',
      created_by TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL DEFAULT ''
    )
  ''');

  Future<List<LearningMaterial>> getMaterials() async {
    final db = await database;
    final rows = await db.query(materialsTable, orderBy: 'id DESC');
    return rows
        .map(
          (row) => LearningMaterial.fromMap(
            Map<String, dynamic>.from(row),
          ),
        )
        .toList();
  }

  Future<int> insertMaterial(LearningMaterial material) async {
    final db = await database;
    return db.insert(materialsTable, material.toMap());
  }

  Future<int> updateMaterial(LearningMaterial material) async {
    if (material.id == null) throw ArgumentError('ID materi tidak tersedia.');
    final db = await database;
    return db.update(materialsTable, material.toMap(),
        where: 'id = ?', whereArgs: [material.id]);
  }

  Future<int> deleteMaterial(int id) async {
    final db = await database;
    return db.delete(materialsTable, where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // INSERT USER
  // ============================================================

  Future<int> insertUser(
    User user,
  ) async {
    final db = await database;

    final values =
        Map<String, dynamic>.from(
      user.toMap(),
    );

    values['name'] =
        user.name.trim();

    values['email'] =
        user.email.trim().toLowerCase();

    values['phone'] =
        user.phone.trim();

    values['city'] =
        user.city.trim();

    values['password'] =
        _hashPassword(
      user.password,
    );

    values['profile_photo'] =
        (user.profilePhoto ?? '').trim();

    values['created_at'] =
        DateTime.now()
            .toIso8601String();

    return db.insert(
      usersTable,
      values,
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // GET USERS
  // ============================================================

  Future<List<User>> getUsers() async {
    final db = await database;

    final rows = await db.query(
      usersTable,
      orderBy: 'id DESC',
    );

    return rows
        .map(User.fromMap)
        .toList();
  }

  // ============================================================
  // GET USER BY EMAIL
  // ============================================================

  Future<Map<String, dynamic>?>
      getUserByEmail(
    String email,
  ) async {
    final db = await database;

    final normalizedEmail =
        email.trim().toLowerCase();

    final rows = await db.query(
      usersTable,
      where: 'LOWER(email) = ?',
      whereArgs: [
        normalizedEmail,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final db = await database;

    final normalizedEmail =
        email.trim().toLowerCase();

    final rows = await db.query(
      usersTable,
      where: 'LOWER(email) = ?',
      whereArgs: [
        normalizedEmail,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final user = rows.first;

    final storedPassword =
        user['password']
                ?.toString() ??
            '';

    final hashedPassword =
        _hashPassword(password);

    if (storedPassword ==
        hashedPassword) {
      return user;
    }

    // Dukungan password lama.
    if (storedPassword ==
        password) {
      await db.update(
        usersTable,
        {
          'password':
              hashedPassword,
        },
        where: 'id = ?',
        whereArgs: [
          user['id'],
        ],
      );

      return {
        ...user,
        'password':
            hashedPassword,
      };
    }

    return null;
  }

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final db = await database;

    final updated =
        await db.update(
      usersTable,
      {
        'password':
            _hashPassword(
          newPassword,
        ),
      },
      where: 'LOWER(email) = ?',
      whereArgs: [
        email.trim().toLowerCase(),
      ],
    );

    return updated > 0;
  }

  // ============================================================
  // UPDATE USER
  // ============================================================

  Future<int> updateUser({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String city,
    String? password,
    String? profilePhoto,
    UserRole? role,
  }) async {
    final db = await database;

    final normalizedEmail = email.trim().toLowerCase();
    final currentUser = await db.query(
      usersTable,
      columns: ['id', 'email'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    final currentEmail = (currentUser.firstOrNull?['email'] as String? ?? '').trim().toLowerCase();

    if (normalizedEmail != currentEmail) {
      final conflict = await db.query(
        usersTable,
        columns: ['id'],
        where: 'LOWER(email) = ? AND id != ?',
        whereArgs: [normalizedEmail, id],
        limit: 1,
      );

      if (conflict.isNotEmpty) {
        throw const FormatException('Email sudah digunakan oleh user lain.');
      }
    }

    final values =
        <String, dynamic>{
      'name': name.trim(),
      'email': normalizedEmail,
      'phone': phone.trim(),
      'city': city.trim(),
    };

    if (password != null &&
        password.trim().isNotEmpty) {
      values['password'] =
          _hashPassword(
        password.trim(),
      );
    }

    if (profilePhoto != null) {
      values['profile_photo'] =
          profilePhoto.trim();
    }

    if (role != null) {
      values['role'] =
          role.value;
    }

    return db.update(
      usersTable,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE USER
  // ============================================================

  Future<int> deleteUser(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // SAVE ATTENDANCE
  // ============================================================

  Future<int> saveAttendance({
    required String email,
    required String status,
    required String note,
  }) async {
    final db = await database;

    final normalizedEmail =
        email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw Exception(
        'Email pengguna tidak ditemukan.',
      );
    }

    final normalizedStatus =
        status.trim().isEmpty
            ? 'Hadir'
            : status.trim();

    final normalizedNote =
        note.trim();

    final now =
        DateTime.now();

    final today =
        _dateOnly(now);

    final createdAt =
        now.toIso8601String();

    // Waktu check-in.
    final checkIn =
        now.toIso8601String();

    // ==========================================================
    // CARI USER
    // ==========================================================

    final user =
        await getUserByEmail(
      normalizedEmail,
    );

    final dynamic userId =
        user?['id'];

    // ==========================================================
    // CEK DATA HARI INI
    // ==========================================================

    final existing =
        await db.query(
      attendanceTable,
      where:
          'LOWER(email) = ? AND date = ?',
      whereArgs: [
        normalizedEmail,
        today,
      ],
      orderBy: 'id DESC',
      limit: 1,
    );

    // ==========================================================
    // UPDATE
    // ==========================================================

    if (existing.isNotEmpty) {
      final existingId =
          existing.first['id'];

      final existingCheckIn =
          existing.first['check_in']
              ?.toString();

      return db.update(
        attendanceTable,
        {
          'user_id': userId,
          'email': normalizedEmail,
          'date': today,
          'status': normalizedStatus,
          'note': normalizedNote,
          'created_at': createdAt,

          // Jangan kosongkan check-in lama.
          'check_in':
              existingCheckIn == null ||
                      existingCheckIn.isEmpty
                  ? checkIn
                  : existingCheckIn,
        },
        where: 'id = ?',
        whereArgs: [
          existingId,
        ],
      );
    }

    // ==========================================================
    // INSERT
    // ==========================================================

    return db.insert(
      attendanceTable,
      {
        'user_id': userId,
        'email': normalizedEmail,
        'date': today,
        'status': normalizedStatus,
        'note': normalizedNote,
        'created_at': createdAt,

        // WAJIB DIISI
        'check_in': checkIn,
      },
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // CEK ATTENDANCE HARI INI
  // ============================================================

  Future<bool> hasAttendanceToday(
    String email,
  ) async {
    final db = await database;

    final normalizedEmail =
        email.trim().toLowerCase();

    final today =
        _dateOnly(
      DateTime.now(),
    );

    final rows =
        await db.query(
      attendanceTable,
      where:
          'LOWER(email) = ? AND date = ?',
      whereArgs: [
        normalizedEmail,
        today,
      ],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  // ============================================================
  // GET ATTENDANCE USER
  // ============================================================

  Future<List<AttendanceRecord>>
      getAttendanceForUser(
    String email,
  ) async {
    final db = await database;

    final normalizedEmail =
        email.trim().toLowerCase();

    final rows =
        await db.query(
      attendanceTable,
      where: 'LOWER(email) = ?',
      whereArgs: [
        normalizedEmail,
      ],
      orderBy:
          'date DESC, id DESC',
    );

    return rows
        .map(
          (row) =>
              AttendanceRecord
                  .fromMap(row),
        )
        .toList();
  }

  // ============================================================
  // GET ALL ATTENDANCE
  // ============================================================

  Future<List<AttendanceRecord>>
      getAllAttendance() async {
    final db = await database;

    final rows =
        await db.query(
      attendanceTable,
      orderBy:
          'date DESC, id DESC',
    );

    return rows
        .map(
          (row) =>
              AttendanceRecord
                  .fromMap(row),
        )
        .toList();
  }

  // ============================================================
  // DELETE ATTENDANCE
  // ============================================================

  Future<int> deleteAttendance(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      attendanceTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // HASH PASSWORD
  // ============================================================

  static String _hashPassword(
    String password,
  ) {
    return sha256
        .convert(
          utf8.encode(password),
        )
        .toString();
  }

  // ============================================================
  // DATE YYYY-MM-DD
  // ============================================================

  static String _dateOnly(
    DateTime date,
  ) {
    final year =
        date.year.toString().padLeft(
              4,
              '0',
            );

    final month =
        date.month.toString().padLeft(
              2,
              '0',
            );

    final day =
        date.day.toString().padLeft(
              2,
              '0',
            );

    return '$year-$month-$day';
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> close() async {
    await _database?.close();

    _database = null;
  }

  // ============================================================
  // RESET DATABASE
  //
  // JANGAN DIPANGGIL DARI main.dart
  // ============================================================

  Future<void> resetDatabase() async {
    await close();

    await initializeDatabasePlatform();

    final databasePath =
        await getDatabasesPath();

    final path = join(
      databasePath,
      _databaseName,
    );

    await deleteDatabase(path);

    _database = null;
  }
}
