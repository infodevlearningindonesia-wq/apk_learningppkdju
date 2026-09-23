part of devlearning_roles;

class TeacherParticipantsScreen extends StatelessWidget {
  const TeacherParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peserta belajar')),
      body: FutureBuilder<List<User>>(
        future: DatabaseHelper.instance.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final participants = (snapshot.data ?? <User>[])
              .where((user) => user.role == UserRole.peserta)
              .toList();
          if (participants.isEmpty) {
            return const Center(child: Text('Belum ada peserta terdaftar.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  ),
                  title: Text(participant.name),
                  subtitle: Text('${participant.email}\n${participant.city}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
