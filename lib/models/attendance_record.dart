class AttendanceRecord {
  const AttendanceRecord({
    this.id,
    this.userId,
    required this.email,
    required this.date,
    required this.status,
    required this.note,
    required this.createdAt,
    this.checkIn,
  });

  final int? id;
  final int? userId;
  final String email;
  final String date;
  final String status;
  final String note;
  final String createdAt;
  final String? checkIn;

  // ============================================================
  // FROM MAP
  // ============================================================

  factory AttendanceRecord.fromMap(
    Map<String, dynamic> map,
  ) {
    return AttendanceRecord(
      id: _parseInt(
        map['id'],
      ),
      userId: _parseInt(
        map['user_id'],
      ),
      email:
          map['email']?.toString() ??
              '',
      date:
          map['date']?.toString() ??
              '',
      status:
          map['status']?.toString() ??
              'Hadir',
      note:
          map['note']?.toString() ??
              '',
      createdAt:
          map['created_at']?.toString() ??
              '',
      checkIn:
          map['check_in']?.toString(),
    );
  }

  // ============================================================
  // TO MAP
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'date': date,
      'status': status,
      'note': note,
      'created_at': createdAt,
      'check_in': checkIn,
    };
  }

  // ============================================================
  // PARSE INT
  // ============================================================

  static int? _parseInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }
}