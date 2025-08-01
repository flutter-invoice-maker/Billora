import 'package:json_annotation/json_annotation.dart';

part 'extraction_result_model.g.dart';

@JsonSerializable()
class ExtractionResultModel {
  final String storeName;
  final double totalAmount;
  final String? date;
  final String? phone;
  final String? address;
  final List<Map<String, dynamic>>? items;
  final double? subtotal;
  final double? tax;
  final String? currency;
  final double confidence;

  ExtractionResultModel({
    required this.storeName,
    required this.totalAmount,
    this.date,
    this.phone,
    this.address,
    this.items,
    this.subtotal,
    this.tax,
    this.currency,
    required this.confidence,
  });

  factory ExtractionResultModel.fromJson(Map<String, dynamic> json) =>
      _$ExtractionResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExtractionResultModelToJson(this);
} 