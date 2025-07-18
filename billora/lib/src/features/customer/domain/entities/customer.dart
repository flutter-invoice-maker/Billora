class Customer {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;

  Customer({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
} 
