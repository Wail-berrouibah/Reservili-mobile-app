class HomeModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final double pricePerNight;
  final int maxGuests;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  HomeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.pricePerNight,
    required this.maxGuests,
    this.imageUrl,
    this.isAvailable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HomeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    double? pricePerNight,
    int? maxGuests,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return HomeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      maxGuests: maxGuests ?? this.maxGuests,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'pricePerNight': pricePerNight,
      'maxGuests': maxGuests,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      address: map['address'] as String,
      pricePerNight: (map['pricePerNight'] as num).toDouble(),
      maxGuests: map['maxGuests'] as int,
      imageUrl: map['imageUrl'] as String?,
      isAvailable: (map['isAvailable'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
