class Attendance {
  const Attendance({
    this.id,
    required this.email,
    required this.subject,
    required this.date,
    required this.checkIn,
    this.checkOut,
  });

  final int? id;
  final String email;
  final String subject;
  final String date;
  final DateTime checkIn;
  final DateTime? checkOut;

  factory Attendance.fromMap(Map<String, Object?> map) {
    return Attendance(
      id: map['id'] as int?,
      email: map['email'] as String,
      subject: (map['subject'] as String?) ?? 'Umum',
      date: map['date'] as String,
      checkIn: DateTime.parse(map['check_in'] as String),
      checkOut: map['check_out'] == null
          ? null
          : DateTime.parse(map['check_out'] as String),
    );
  }
}
