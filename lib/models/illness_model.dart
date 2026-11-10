class IllnessModel {
  final String id;
  final String petType; // 'dog', 'cat', 'fish', etc.
  final String name; // e.g. 'Canine Parvovirus', 'Feline Leukemia'
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final String severity; // 'Mild', 'Moderate', 'Severe', 'Emergency'
  final String firstAidSteps;
  final String veterinaryTreatment;
  final List<String> preventionTips;
  final bool isContagious;

  IllnessModel({
    required this.id,
    required this.petType,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.severity,
    required this.firstAidSteps,
    required this.veterinaryTreatment,
    this.preventionTips = const [],
    this.isContagious = false,
  });

  factory IllnessModel.fromMap(Map<String, dynamic> data, String documentId) {
    return IllnessModel(
      id: documentId,
      petType: data['petType'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      symptoms: List<String>.from(data['symptoms'] ?? []),
      causes: List<String>.from(data['causes'] ?? []),
      severity: data['severity'] ?? 'Mild',
      firstAidSteps: data['firstAidSteps'] ?? '',
      veterinaryTreatment: data['veterinaryTreatment'] ?? '',
      preventionTips: List<String>.from(data['preventionTips'] ?? []),
      isContagious: data['isContagious'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petType': petType,
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'causes': causes,
      'severity': severity,
      'firstAidSteps': firstAidSteps,
      'veterinaryTreatment': veterinaryTreatment,
      'preventionTips': preventionTips,
      'isContagious': isContagious,
    };
  }
}

