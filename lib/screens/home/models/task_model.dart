class Task {
  final String? id;
  final String? userId;
  String title;
  String description;
  String category;
  bool isCompleted;
  bool isPinned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.isCompleted,
    required this.isPinned,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'is_completed': isCompleted,
      'is_pinned': isPinned,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
