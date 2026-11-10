class CareArticleModel {
  final String id;
  final String petType; // 'dog', 'cat', 'fish', 'bird', etc.
  final String title;
  final String category; // e.g. 'nutrition', 'training', 'grooming', 'environment'
  final String summary;
  final String content;
  final List<String> steps;
  final List<String> requiredItems;
  final String? imageUrl;
  final String difficultyLevel; // 'Beginner', 'Intermediate', 'Advanced'

  CareArticleModel({
    required this.id,
    required this.petType,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    this.steps = const [],
    this.requiredItems = const [],
    this.imageUrl,
    this.difficultyLevel = 'Beginner',
  });

  factory CareArticleModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CareArticleModel(
      id: documentId,
      petType: data['petType'] ?? '',
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      steps: List<String>.from(data['steps'] ?? []),
      requiredItems: List<String>.from(data['requiredItems'] ?? []),
      imageUrl: data['imageUrl'],
      difficultyLevel: data['difficultyLevel'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petType': petType,
      'title': title,
      'category': category,
      'summary': summary,
      'content': content,
      'steps': steps,
      'requiredItems': requiredItems,
      'imageUrl': imageUrl,
      'difficultyLevel': difficultyLevel,
    };
  }
}

