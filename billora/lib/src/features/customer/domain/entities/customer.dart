class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final bool isVip;
  final String? avatarUrl;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.isVip = false,
    this.avatarUrl,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    bool? isVip,
    String? avatarUrl,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isVip: isVip ?? this.isVip,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Convert Customer to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'isVip': isVip,
      'avatarUrl': avatarUrl,
    };
  }
} 
