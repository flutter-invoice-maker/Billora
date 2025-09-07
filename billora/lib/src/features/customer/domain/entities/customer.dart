class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final bool isVip;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.isVip = false,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    bool? isVip,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isVip: isVip ?? this.isVip,
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
    };
  }
} 
