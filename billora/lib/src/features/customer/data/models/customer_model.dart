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
  }) = _CustomerModel;

  factory CustomerModel.fromJson(Map<String, dynamic> json) => _$CustomerModelFromJson(json);
}

extension CustomerModelMapper on CustomerModel {
  Customer toEntity() => Customer(
    id: id,
    name: name,
    email: email,
    phone: phone,
    address: address,
  );
}

extension CustomerEntityMapper on Customer {
  CustomerModel toModel() => CustomerModel(
    id: id,
    name: name,
    email: email,
    phone: phone,
    address: address,
  );
}
