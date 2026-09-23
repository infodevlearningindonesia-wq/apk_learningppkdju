part of devlearning_roles;

class _AdminStat extends StatelessWidget {
  const _AdminStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF126B5B)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
