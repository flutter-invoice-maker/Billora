import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'customer_model.freezed.dart';
part 'customer_model.g.dart';

@freezed
class CustomerModel with _$CustomerModel {
  const factory CustomerModel({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? address,
    @Default(false) bool isVip,
    String? avatarUrl,
    required String userId,
    @Default([]) List<String> searchKeywords,
    DateTime? createdAt,
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(_normalizeCustomerJson(json));

  // Let Freezed/json_serializable generate toJson
}



extension CustomerModelX on CustomerModel {
  Customer toEntity() => Customer(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        isVip: isVip,
        avatarUrl: avatarUrl,
      );

  static CustomerModel fromEntity(Customer customer, String userId) => CustomerModel(
        id: customer.id,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        address: customer.address,
        isVip: customer.isVip,
        avatarUrl: customer.avatarUrl,
        userId: userId,
        createdAt: DateTime.now(),
      );
}

// Helper to normalize incoming JSON for createdAt field, without breaking
// Freezed's generated serialization methods.
Map<String, dynamic> _normalizeCustomerJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  final value = normalized['createdAt'];
  if (value != null) {
    if (value is Timestamp) {
      normalized['createdAt'] = value.toDate().toIso8601String();
    } else if (value is DateTime) {
      normalized['createdAt'] = value.toIso8601String();
    } else if (value is int) {
      normalized['createdAt'] = DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
    } // if it's already String, leave as-is; if other, drop
  }
  return normalized;
}
