class PetModel {
  final String id;
  final String name;
  final String type; // 'dog', 'cat', 'fish', 'bird', etc.
  final String breed;
  final int age;
  final Map<String, bool> dailyTasks; // e.g. {'feeding': true, 'walking': false}

  PetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.dailyTasks,
  });

  PetModel copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    int? age,
    Map<String, bool>? dailyTasks,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      dailyTasks: dailyTasks ?? Map<String, bool>.from(this.dailyTasks),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'dailyTasks': dailyTasks,
    };
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      dailyTasks: Map<String, bool>.from(json['dailyTasks'] as Map),
    );
  }
}

