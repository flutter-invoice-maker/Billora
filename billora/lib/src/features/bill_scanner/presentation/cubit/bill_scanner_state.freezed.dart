// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_scanner_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BillScannerState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BillScannerStateCopyWith<$Res> {
  factory $BillScannerStateCopyWith(
    BillScannerState value,
    $Res Function(BillScannerState) then,
  ) = _$BillScannerStateCopyWithImpl<$Res, BillScannerState>;
}

/// @nodoc
class _$BillScannerStateCopyWithImpl<$Res, $Val extends BillScannerState>
    implements $BillScannerStateCopyWith<$Res> {
  _$BillScannerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$BillScannerStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'BillScannerState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements BillScannerState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$BillScannerStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'BillScannerState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements BillScannerState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$ScanningImplCopyWith<$Res> {
  factory _$$ScanningImplCopyWith(
    _$ScanningImpl value,
    $Res Function(_$ScanningImpl) then,
  ) = __$$ScanningImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ScanningImplCopyWithImpl<$Res>
    extends _$BillScannerStateCopyWithImpl<$Res, _$ScanningImpl>
    implements _$$ScanningImplCopyWith<$Res> {
  __$$ScanningImplCopyWithImpl(
    _$ScanningImpl _value,
    $Res Function(_$ScanningImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ScanningImpl implements _Scanning {
  const _$ScanningImpl();

  @override
  String toString() {
    return 'BillScannerState.scanning()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ScanningImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) {
    return scanning();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) {
    return scanning?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (scanning != null) {
      return scanning();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) {
    return scanning(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return scanning?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (scanning != null) {
      return scanning(this);
    }
    return orElse();
  }
}

abstract class _Scanning implements BillScannerState {
  const factory _Scanning() = _$ScanningImpl;
}

/// @nodoc
abstract class _$$ProcessingImplCopyWith<$Res> {
  factory _$$ProcessingImplCopyWith(
    _$ProcessingImpl value,
    $Res Function(_$ProcessingImpl) then,
  ) = __$$ProcessingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ProcessingImplCopyWithImpl<$Res>
    extends _$BillScannerStateCopyWithImpl<$Res, _$ProcessingImpl>
    implements _$$ProcessingImplCopyWith<$Res> {
  __$$ProcessingImplCopyWithImpl(
    _$ProcessingImpl _value,
    $Res Function(_$ProcessingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ProcessingImpl implements _Processing {
  const _$ProcessingImpl();

  @override
  String toString() {
    return 'BillScannerState.processing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ProcessingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) {
    return processing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) {
    return processing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _Processing implements BillScannerState {
  const factory _Processing() = _$ProcessingImpl;
}

/// @nodoc
abstract class _$$ScanSuccessImplCopyWith<$Res> {
  factory _$$ScanSuccessImplCopyWith(
    _$ScanSuccessImpl value,
    $Res Function(_$ScanSuccessImpl) then,
  ) = __$$ScanSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ScanResult result});

  $ScanResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$ScanSuccessImplCopyWithImpl<$Res>
    extends _$BillScannerStateCopyWithImpl<$Res, _$ScanSuccessImpl>
    implements _$$ScanSuccessImplCopyWith<$Res> {
  __$$ScanSuccessImplCopyWithImpl(
    _$ScanSuccessImpl _value,
    $Res Function(_$ScanSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? result = null}) {
    return _then(
      _$ScanSuccessImpl(
        null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                as ScanResult,
      ),
    );
  }

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScanResultCopyWith<$Res> get result {
    return $ScanResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value));
    });
  }
}

/// @nodoc

class _$ScanSuccessImpl implements _ScanSuccess {
  const _$ScanSuccessImpl(this.result);

  @override
  final ScanResult result;

  @override
  String toString() {
    return 'BillScannerState.scanSuccess(result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanSuccessImpl &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, result);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanSuccessImplCopyWith<_$ScanSuccessImpl> get copyWith =>
      __$$ScanSuccessImplCopyWithImpl<_$ScanSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) {
    return scanSuccess(result);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) {
    return scanSuccess?.call(result);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (scanSuccess != null) {
      return scanSuccess(result);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) {
    return scanSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return scanSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (scanSuccess != null) {
      return scanSuccess(this);
    }
    return orElse();
  }
}

abstract class _ScanSuccess implements BillScannerState {
  const factory _ScanSuccess(final ScanResult result) = _$ScanSuccessImpl;

  ScanResult get result;

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScanSuccessImplCopyWith<_$ScanSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ExtractionSuccessImplCopyWith<$Res> {
  factory _$$ExtractionSuccessImplCopyWith(
    _$ExtractionSuccessImpl value,
    $Res Function(_$ExtractionSuccessImpl) then,
  ) = __$$ExtractionSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ScannedBill bill});

  $ScannedBillCopyWith<$Res> get bill;
}

/// @nodoc
class __$$ExtractionSuccessImplCopyWithImpl<$Res>
    extends _$BillScannerStateCopyWithImpl<$Res, _$ExtractionSuccessImpl>
    implements _$$ExtractionSuccessImplCopyWith<$Res> {
  __$$ExtractionSuccessImplCopyWithImpl(
    _$ExtractionSuccessImpl _value,
    $Res Function(_$ExtractionSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? bill = null}) {
    return _then(
      _$ExtractionSuccessImpl(
        null == bill
            ? _value.bill
            : bill // ignore: cast_nullable_to_non_nullable
                as ScannedBill,
      ),
    );
  }

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScannedBillCopyWith<$Res> get bill {
    return $ScannedBillCopyWith<$Res>(_value.bill, (value) {
      return _then(_value.copyWith(bill: value));
    });
  }
}

/// @nodoc

class _$ExtractionSuccessImpl implements _ExtractionSuccess {
  const _$ExtractionSuccessImpl(this.bill);

  @override
  final ScannedBill bill;

  @override
  String toString() {
    return 'BillScannerState.extractionSuccess(bill: $bill)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractionSuccessImpl &&
            (identical(other.bill, bill) || other.bill == bill));
  }

  @override
  int get hashCode => Object.hash(runtimeType, bill);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractionSuccessImplCopyWith<_$ExtractionSuccessImpl> get copyWith =>
      __$$ExtractionSuccessImplCopyWithImpl<_$ExtractionSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) {
    return extractionSuccess(bill);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) {
    return extractionSuccess?.call(bill);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (extractionSuccess != null) {
      return extractionSuccess(bill);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) {
    return extractionSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return extractionSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (extractionSuccess != null) {
      return extractionSuccess(this);
    }
    return orElse();
  }
}

abstract class _ExtractionSuccess implements BillScannerState {
  const factory _ExtractionSuccess(final ScannedBill bill) =
      _$ExtractionSuccessImpl;

  ScannedBill get bill;

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExtractionSuccessImplCopyWith<_$ExtractionSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$BillScannerStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'BillScannerState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function() scanning,
    required TResult Function() processing,
    required TResult Function(ScanResult result) scanSuccess,
    required TResult Function(ScannedBill bill) extractionSuccess,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function()? scanning,
    TResult? Function()? processing,
    TResult? Function(ScanResult result)? scanSuccess,
    TResult? Function(ScannedBill bill)? extractionSuccess,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function()? scanning,
    TResult Function()? processing,
    TResult Function(ScanResult result)? scanSuccess,
    TResult Function(ScannedBill bill)? extractionSuccess,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Scanning value) scanning,
    required TResult Function(_Processing value) processing,
    required TResult Function(_ScanSuccess value) scanSuccess,
    required TResult Function(_ExtractionSuccess value) extractionSuccess,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Scanning value)? scanning,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_ScanSuccess value)? scanSuccess,
    TResult? Function(_ExtractionSuccess value)? extractionSuccess,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Scanning value)? scanning,
    TResult Function(_Processing value)? processing,
    TResult Function(_ScanSuccess value)? scanSuccess,
    TResult Function(_ExtractionSuccess value)? extractionSuccess,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements BillScannerState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of BillScannerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
