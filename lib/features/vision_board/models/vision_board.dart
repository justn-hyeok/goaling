class VisionBoardItem {
  final String id;
  final String imagePath;
  final String title;
  final String description;
  final DateTime createdAt;

  VisionBoardItem({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  VisionBoardItem copyWith({
    String? id,
    String? imagePath,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return VisionBoardItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
