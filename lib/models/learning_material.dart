class LearningMaterial {
  const LearningMaterial({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.createdBy,
    this.createdAt,
  });

  final int? id;
  final String title;
  final String description;
  final String content;
  final String createdBy;
  final String? createdAt;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title.trim(),
        'description': description.trim(),
        'content': content.trim(),
        'created_by': createdBy.trim(),
        'created_at': createdAt ?? DateTime.now().toIso8601String(),
      };

  factory LearningMaterial.fromMap(Map<String, dynamic> map) => LearningMaterial(
        id: map['id'] as int?,
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        content: map['content'] as String? ?? '',
        createdBy: map['created_by'] as String? ?? '',
        createdAt: map['created_at'] as String?,
      );
}
