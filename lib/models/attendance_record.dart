class AttendanceRecord {
  const AttendanceRecord({
    this.id,
    required this.userId,
    required this.email,
    required this.date,
    required this.status,
    required this.note,
    required this.createdAt,
  });

  final int? id;
  final int? userId;
  final String email;
  final String date;
  final String status;
  final String note;
  final String createdAt;

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      email: map['email'] as String? ?? '',
      date: map['date'] as String? ?? '',
      status: map['status'] as String? ?? 'Hadir',
      note: map['note'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }
}
