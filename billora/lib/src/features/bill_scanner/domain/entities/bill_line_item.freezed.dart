// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_line_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BillLineItem _$BillLineItemFromJson(Map<String, dynamic> json) {
  return _BillLineItem.fromJson(json);
}

/// @nodoc
mixin _$BillLineItem {
  String get id => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  double? get discount => throw _privateConstructorUsedError;
  double? get tax => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;

  /// Serializes this BillLineItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BillLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BillLineItemCopyWith<BillLineItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillLineItemCopyWith<$Res> {
  factory $BillLineItemCopyWith(
    BillLineItem value,
    $Res Function(BillLineItem) then,
  ) = _$BillLineItemCopyWithImpl<$Res, BillLineItem>;
  @useResult
  $Res call({
    String id,
    String description,
    double quantity,
    double unitPrice,
    double totalPrice,
    String? unit,
    String? category,
    String? sku,
    double? discount,
    double? tax,
    double confidence,
  });
}

/// @nodoc
class _$BillLineItemCopyWithImpl<$Res, $Val extends BillLineItem>
    implements $BillLineItemCopyWith<$Res> {
  _$BillLineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BillLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? unit = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? discount = freezed,
    Object? tax = freezed,
    Object? confidence = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            quantity:
                null == quantity
                    ? _value.quantity
                    : quantity // ignore: cast_nullable_to_non_nullable
                        as double,
            unitPrice:
                null == unitPrice
                    ? _value.unitPrice
                    : unitPrice // ignore: cast_nullable_to_non_nullable
                        as double,
            totalPrice:
                null == totalPrice
                    ? _value.totalPrice
                    : totalPrice // ignore: cast_nullable_to_non_nullable
                        as double,
            unit:
                freezed == unit
                    ? _value.unit
                    : unit // ignore: cast_nullable_to_non_nullable
                        as String?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as String?,
            sku:
                freezed == sku
                    ? _value.sku
                    : sku // ignore: cast_nullable_to_non_nullable
                        as String?,
            discount:
                freezed == discount
                    ? _value.discount
                    : discount // ignore: cast_nullable_to_non_nullable
                        as double?,
            tax:
                freezed == tax
                    ? _value.tax
                    : tax // ignore: cast_nullable_to_non_nullable
                        as double?,
            confidence:
                null == confidence
                    ? _value.confidence
                    : confidence // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BillLineItemImplCopyWith<$Res>
    implements $BillLineItemCopyWith<$Res> {
  factory _$$BillLineItemImplCopyWith(
    _$BillLineItemImpl value,
    $Res Function(_$BillLineItemImpl) then,
  ) = __$$BillLineItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String description,
    double quantity,
    double unitPrice,
    double totalPrice,
    String? unit,
    String? category,
    String? sku,
    double? discount,
    double? tax,
    double confidence,
  });
}

/// @nodoc
class __$$BillLineItemImplCopyWithImpl<$Res>
    extends _$BillLineItemCopyWithImpl<$Res, _$BillLineItemImpl>
    implements _$$BillLineItemImplCopyWith<$Res> {
  __$$BillLineItemImplCopyWithImpl(
    _$BillLineItemImpl _value,
    $Res Function(_$BillLineItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillLineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? description = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? unit = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? discount = freezed,
    Object? tax = freezed,
    Object? confidence = null,
  }) {
    return _then(
      _$BillLineItemImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        quantity:
            null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                    as double,
        unitPrice:
            null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                    as double,
        totalPrice:
            null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                    as double,
        unit:
            freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                    as String?,
        category:
            freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as String?,
        sku:
            freezed == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                    as String?,
        discount:
            freezed == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                    as double?,
        tax:
            freezed == tax
                ? _value.tax
                : tax // ignore: cast_nullable_to_non_nullable
                    as double?,
        confidence:
            null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BillLineItemImpl implements _BillLineItem {
  const _$BillLineItemImpl({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.unit,
    this.category,
    this.sku,
    this.discount,
    this.tax,
    this.confidence = 0.0,
  });

  factory _$BillLineItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BillLineItemImplFromJson(json);

  @override
  final String id;
  @override
  final String description;
  @override
  final double quantity;
  @override
  final double unitPrice;
  @override
  final double totalPrice;
  @override
  final String? unit;
  @override
  final String? category;
  @override
  final String? sku;
  @override
  final double? discount;
  @override
  final double? tax;
  @override
  @JsonKey()
  final double confidence;

  @override
  String toString() {
    return 'BillLineItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, unit: $unit, category: $category, sku: $sku, discount: $discount, tax: $tax, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BillLineItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    description,
    quantity,
    unitPrice,
    totalPrice,
    unit,
    category,
    sku,
    discount,
    tax,
    confidence,
  );

  /// Create a copy of BillLineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BillLineItemImplCopyWith<_$BillLineItemImpl> get copyWith =>
      __$$BillLineItemImplCopyWithImpl<_$BillLineItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BillLineItemImplToJson(this);
  }
}

abstract class _BillLineItem implements BillLineItem {
  const factory _BillLineItem({
    required final String id,
    required final String description,
    required final double quantity,
    required final double unitPrice,
    required final double totalPrice,
    final String? unit,
    final String? category,
    final String? sku,
    final double? discount,
    final double? tax,
    final double confidence,
  }) = _$BillLineItemImpl;

  factory _BillLineItem.fromJson(Map<String, dynamic> json) =
      _$BillLineItemImpl.fromJson;

  @override
  String get id;
  @override
  String get description;
  @override
  double get quantity;
  @override
  double get unitPrice;
  @override
  double get totalPrice;
  @override
  String? get unit;
  @override
  String? get category;
  @override
  String? get sku;
  @override
  double? get discount;
  @override
  double? get tax;
  @override
  double get confidence;

  /// Create a copy of BillLineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillLineItemImplCopyWith<_$BillLineItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
