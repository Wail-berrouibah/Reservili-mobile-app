class GuestModel {
  final String id;
  final String fullName;
  final String phone;
  final String? email;

  const GuestModel({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
  });

  factory GuestModel.fromJson(Map<String, dynamic> json) => GuestModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'email': email,
      };

  GuestModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
  }) {
    return GuestModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
