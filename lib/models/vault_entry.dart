import 'vault_category.dart';

class VaultEntry {
  final String id;
  final VaultCategory category;
  final String title;
  final String content;
  final int createdAt;

  VaultEntry({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'title': title,
        'content': content,
        'createdAt': createdAt,
      };

  factory VaultEntry.fromJson(Map<String, dynamic> json) => VaultEntry(
        id: json['id'] as String,
        category: categoryFromString(json['category'] as String? ?? 'note'),
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      );
}
