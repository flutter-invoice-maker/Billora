// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanned_bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScannedBill _$ScannedBillFromJson(Map<String, dynamic> json) {
  return _ScannedBill.fromJson(json);
}

/// @nodoc
mixin _$ScannedBill {
  String get id => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  String get storeName => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  DateTime get scanDate => throw _privateConstructorUsedError;
  ScanResult get scanResult => throw _privateConstructorUsedError;
  List<BillLineItem>? get items => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  double? get subtotal => throw _privateConstructorUsedError;
  double? get tax => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;

  /// Serializes this ScannedBill to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScannedBill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScannedBillCopyWith<ScannedBill> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScannedBillCopyWith<$Res> {
  factory $ScannedBillCopyWith(
    ScannedBill value,
    $Res Function(ScannedBill) then,
  ) = _$ScannedBillCopyWithImpl<$Res, ScannedBill>;
  @useResult
  $Res call({
    String id,
    String imagePath,
    String storeName,
    double totalAmount,
    DateTime scanDate,
    ScanResult scanResult,
    List<BillLineItem>? items,
    String? phone,
    String? address,
    String? note,
    double? subtotal,
    double? tax,
    String? currency,
  });

  $ScanResultCopyWith<$Res> get scanResult;
}

/// @nodoc
class _$ScannedBillCopyWithImpl<$Res, $Val extends ScannedBill>
    implements $ScannedBillCopyWith<$Res> {
  _$ScannedBillCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScannedBill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imagePath = null,
    Object? storeName = null,
    Object? totalAmount = null,
    Object? scanDate = null,
    Object? scanResult = null,
    Object? items = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? note = freezed,
    Object? subtotal = freezed,
    Object? tax = freezed,
    Object? currency = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            imagePath:
                null == imagePath
                    ? _value.imagePath
                    : imagePath // ignore: cast_nullable_to_non_nullable
                        as String,
            storeName:
                null == storeName
                    ? _value.storeName
                    : storeName // ignore: cast_nullable_to_non_nullable
                        as String,
            totalAmount:
                null == totalAmount
                    ? _value.totalAmount
                    : totalAmount // ignore: cast_nullable_to_non_nullable
                        as double,
            scanDate:
                null == scanDate
                    ? _value.scanDate
                    : scanDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            scanResult:
                null == scanResult
                    ? _value.scanResult
                    : scanResult // ignore: cast_nullable_to_non_nullable
                        as ScanResult,
            items:
                freezed == items
                    ? _value.items
                    : items // ignore: cast_nullable_to_non_nullable
                        as List<BillLineItem>?,
            phone:
                freezed == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String?,
            address:
                freezed == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String?,
            note:
                freezed == note
                    ? _value.note
                    : note // ignore: cast_nullable_to_non_nullable
                        as String?,
            subtotal:
                freezed == subtotal
                    ? _value.subtotal
                    : subtotal // ignore: cast_nullable_to_non_nullable
                        as double?,
            tax:
                freezed == tax
                    ? _value.tax
                    : tax // ignore: cast_nullable_to_non_nullable
                        as double?,
            currency:
                freezed == currency
                    ? _value.currency
                    : currency // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ScannedBill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScanResultCopyWith<$Res> get scanResult {
    return $ScanResultCopyWith<$Res>(_value.scanResult, (value) {
      return _then(_value.copyWith(scanResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScannedBillImplCopyWith<$Res>
    implements $ScannedBillCopyWith<$Res> {
  factory _$$ScannedBillImplCopyWith(
    _$ScannedBillImpl value,
    $Res Function(_$ScannedBillImpl) then,
  ) = __$$ScannedBillImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String imagePath,
    String storeName,
    double totalAmount,
    DateTime scanDate,
    ScanResult scanResult,
    List<BillLineItem>? items,
    String? phone,
    String? address,
    String? note,
    double? subtotal,
    double? tax,
    String? currency,
  });

  @override
  $ScanResultCopyWith<$Res> get scanResult;
}

/// @nodoc
class __$$ScannedBillImplCopyWithImpl<$Res>
    extends _$ScannedBillCopyWithImpl<$Res, _$ScannedBillImpl>
    implements _$$ScannedBillImplCopyWith<$Res> {
  __$$ScannedBillImplCopyWithImpl(
    _$ScannedBillImpl _value,
    $Res Function(_$ScannedBillImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScannedBill
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imagePath = null,
    Object? storeName = null,
    Object? totalAmount = null,
    Object? scanDate = null,
    Object? scanResult = null,
    Object? items = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? note = freezed,
    Object? subtotal = freezed,
    Object? tax = freezed,
    Object? currency = freezed,
  }) {
    return _then(
      _$ScannedBillImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        imagePath:
            null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                    as String,
        storeName:
            null == storeName
                ? _value.storeName
                : storeName // ignore: cast_nullable_to_non_nullable
                    as String,
        totalAmount:
            null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                    as double,
        scanDate:
            null == scanDate
                ? _value.scanDate
                : scanDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        scanResult:
            null == scanResult
                ? _value.scanResult
                : scanResult // ignore: cast_nullable_to_non_nullable
                    as ScanResult,
        items:
            freezed == items
                ? _value._items
                : items // ignore: cast_nullable_to_non_nullable
                    as List<BillLineItem>?,
        phone:
            freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String?,
        address:
            freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String?,
        note:
            freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                    as String?,
        subtotal:
            freezed == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                    as double?,
        tax:
            freezed == tax
                ? _value.tax
                : tax // ignore: cast_nullable_to_non_nullable
                    as double?,
        currency:
            freezed == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScannedBillImpl implements _ScannedBill {
  const _$ScannedBillImpl({
    required this.id,
    required this.imagePath,
    required this.storeName,
    required this.totalAmount,
    required this.scanDate,
    required this.scanResult,
    final List<BillLineItem>? items,
    this.phone,
    this.address,
    this.note,
    this.subtotal,
    this.tax,
    this.currency,
  }) : _items = items;

  factory _$ScannedBillImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScannedBillImplFromJson(json);

  @override
  final String id;
  @override
  final String imagePath;
  @override
  final String storeName;
  @override
  final double totalAmount;
  @override
  final DateTime scanDate;
  @override
  final ScanResult scanResult;
  final List<BillLineItem>? _items;
  @override
  List<BillLineItem>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? phone;
  @override
  final String? address;
  @override
  final String? note;
  @override
  final double? subtotal;
  @override
  final double? tax;
  @override
  final String? currency;

  @override
  String toString() {
    return 'ScannedBill(id: $id, imagePath: $imagePath, storeName: $storeName, totalAmount: $totalAmount, scanDate: $scanDate, scanResult: $scanResult, items: $items, phone: $phone, address: $address, note: $note, subtotal: $subtotal, tax: $tax, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScannedBillImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.scanDate, scanDate) ||
                other.scanDate == scanDate) &&
            (identical(other.scanResult, scanResult) ||
                other.scanResult == scanResult) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    imagePath,
    storeName,
    totalAmount,
    scanDate,
    scanResult,
    const DeepCollectionEquality().hash(_items),
    phone,
    address,
    note,
    subtotal,
    tax,
    currency,
  );

  /// Create a copy of ScannedBill
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScannedBillImplCopyWith<_$ScannedBillImpl> get copyWith =>
      __$$ScannedBillImplCopyWithImpl<_$ScannedBillImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScannedBillImplToJson(this);
  }
}

abstract class _ScannedBill implements ScannedBill {
  const factory _ScannedBill({
    required final String id,
    required final String imagePath,
    required final String storeName,
    required final double totalAmount,
    required final DateTime scanDate,
    required final ScanResult scanResult,
    final List<BillLineItem>? items,
    final String? phone,
    final String? address,
    final String? note,
    final double? subtotal,
    final double? tax,
    final String? currency,
  }) = _$ScannedBillImpl;

  factory _ScannedBill.fromJson(Map<String, dynamic> json) =
      _$ScannedBillImpl.fromJson;

  @override
  String get id;
  @override
  String get imagePath;
  @override
  String get storeName;
  @override
  double get totalAmount;
  @override
  DateTime get scanDate;
  @override
  ScanResult get scanResult;
  @override
  List<BillLineItem>? get items;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  String? get note;
  @override
  double? get subtotal;
  @override
  double? get tax;
  @override
  String? get currency;

  /// Create a copy of ScannedBill
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScannedBillImplCopyWith<_$ScannedBillImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
