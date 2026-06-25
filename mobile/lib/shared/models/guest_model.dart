class GuestModel {
  final String name;
  final String? phone;
  final String? email;

  const GuestModel({
    required this.name,
    this.phone,
    this.email,
  });

  GuestModel copyWith({
    String? name,
    String? phone,
    String? email,
  }) {
    return GuestModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
    };
  }

  factory GuestModel.fromMap(Map<String, dynamic> map) {
    return GuestModel(
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
    );
  }
}
