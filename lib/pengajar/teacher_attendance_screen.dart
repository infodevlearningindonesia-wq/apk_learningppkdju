part of devlearning_roles;

class TeacherAttendanceScreen extends StatelessWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap kehadiran')),
      body: FutureBuilder<(List<User>, List<AttendanceRecord>)>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Data tidak tersedia.'));
          }
          final attendance = data.$2;
          final participants = data.$1
              .where((user) => user.role == UserRole.peserta)
              .toList();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: participants.map((participant) {
              final records = attendance
                  .where((record) => record.email == participant.email)
                  .toList();
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(participant.name),
                  subtitle: Text('${records.length} catatan kehadiran'),
                  trailing: Text(records.isEmpty ? '-' : records.last.date),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<(List<User>, List<AttendanceRecord>)> _loadData() async {
    final users = await DatabaseHelper.instance.getUsers();
    final attendance = await DatabaseHelper.instance.getAllAttendance();
    return (users, attendance);
  }
}
