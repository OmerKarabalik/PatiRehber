class SitterModel {
  final String id;
  final String name;
  final String bio;
  final double rating;
  final int reviewsCount;
  final double hourlyRate;
  final String city; // İl (Örn: İstanbul)
  final String district; // İlçe (Örn: Kadıköy)
  final List<String> services; // e.g. ['Saatlik', 'Günlük', 'Haftalık', 'Aylık', 'Yazlık']
  final String contactPhone;
  final String avatarUrl;
  final bool isFeatured;
  final bool isApproved;

  SitterModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.rating,
    required this.reviewsCount,
    required this.hourlyRate,
    required this.city,
    required this.district,
    required this.services,
    required this.contactPhone,
    required this.avatarUrl,
    this.isFeatured = false,
    this.isApproved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'hourlyRate': hourlyRate,
      'city': city,
      'district': district,
      'services': services,
      'contactPhone': contactPhone,
      'avatarUrl': avatarUrl,
      'isFeatured': isFeatured,
      'isApproved': isApproved,
    };
  }

  factory SitterModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SitterModel(
      id: documentId,
      name: map['name'] ?? '',
      bio: map['bio'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      contactPhone: map['contactPhone'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      isApproved: map['isApproved'] ?? false,
    );
  }
}

