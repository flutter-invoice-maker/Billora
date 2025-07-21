import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:billora/src/features/customer/domain/entities/customer.dart';

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
    required String userId,
    @Default([]) List<String> searchKeywords,
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
}

extension CustomerModelX on CustomerModel {
  Customer toEntity() => Customer(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

  static CustomerModel fromEntity(Customer customer, String userId) => CustomerModel(
        id: customer.id,
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        address: customer.address,
        userId: userId,
      );
}
