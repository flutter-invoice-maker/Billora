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
  double? get tax => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;

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
    double? tax,
    String? notes,
    double? confidence,
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
    Object? tax = freezed,
    Object? notes = freezed,
    Object? confidence = freezed,
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
            tax:
                freezed == tax
                    ? _value.tax
                    : tax // ignore: cast_nullable_to_non_nullable
                        as double?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            confidence:
                freezed == confidence
                    ? _value.confidence
                    : confidence // ignore: cast_nullable_to_non_nullable
                        as double?,
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
    double? tax,
    String? notes,
    double? confidence,
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
    Object? tax = freezed,
    Object? notes = freezed,
    Object? confidence = freezed,
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
        tax:
            freezed == tax
                ? _value.tax
                : tax // ignore: cast_nullable_to_non_nullable
                    as double?,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        confidence:
            freezed == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                    as double?,
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
    this.tax,
    this.notes,
    this.confidence,
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
  final double? tax;
  @override
  final String? notes;
  @override
  final double? confidence;

  @override
  String toString() {
    return 'BillLineItem(id: $id, description: $description, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, tax: $tax, notes: $notes, confidence: $confidence)';
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
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.notes, notes) || other.notes == notes) &&
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
    tax,
    notes,
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
    final double? tax,
    final String? notes,
    final double? confidence,
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
  double? get tax;
  @override
  String? get notes;
  @override
  double? get confidence;

  /// Create a copy of BillLineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BillLineItemImplCopyWith<_$BillLineItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
