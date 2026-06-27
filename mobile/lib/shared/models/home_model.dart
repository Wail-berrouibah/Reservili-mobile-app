enum HomeStatus { available, unavailable }

class HomeModel {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final double pricePerNight;
  final HomeStatus status;
  final String? image;

  const HomeModel({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.pricePerNight,
    this.status = HomeStatus.available,
    this.image,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
        id: json['id'] as String,
        name: json['name'] as String,
        location: json['location'] as String,
        capacity: (json['capacity'] as num).toInt(),
        pricePerNight: (json['pricePerNight'] as num).toDouble(),
        status: HomeStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => HomeStatus.available,
        ),
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'capacity': capacity,
        'pricePerNight': pricePerNight,
        'status': status.name,
        'image': image,
      };

  HomeModel copyWith({
    String? id,
    String? name,
    String? location,
    int? capacity,
    double? pricePerNight,
    HomeStatus? status,
    String? image,
  }) {
    return HomeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      status: status ?? this.status,
      image: image ?? this.image,
    );
  }
}
