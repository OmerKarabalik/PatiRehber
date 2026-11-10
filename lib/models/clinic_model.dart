class ClinicModel {
  final String id;
  final String name;
  final String type;
  final String city;
  final String district;
  final String address;
  final String phone;
  final double rating;
  final int reviewsCount;
  final bool is24Hours;
  final String workingHours;
  final List<String> services;

  const ClinicModel({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.district,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewsCount,
    required this.is24Hours,
    required this.workingHours,
    required this.services,
  });
}
