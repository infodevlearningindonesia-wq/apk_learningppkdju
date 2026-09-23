part of '../home_screen.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;

  final String title;

  final Color color;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF3F7D27), size: 28),

            const SizedBox(height: 16),

            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;

  final String title;

  final String subtitle;

  final Color color;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,

      child: ListTile(
        onTap: onTap,

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),

        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: const Color(0xFF3F7D27)),
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),

        subtitle: Text(subtitle),

        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;

  final IconData icon;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,

      avatar: Icon(icon, size: 18, color: const Color(0xFF3F7D27)),

      label: Text(label),

      backgroundColor: Colors.white,

      side: BorderSide.none,

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;

  final String value;

  final String label;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: const Color(0xFF3F7D27)),
        ),

        title: Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),

        subtitle: Text(label),
      ),
    );
  }
}


