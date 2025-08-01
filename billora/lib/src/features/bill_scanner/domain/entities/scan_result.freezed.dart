// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scan_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScanResult _$ScanResultFromJson(Map<String, dynamic> json) {
  return _ScanResult.fromJson(json);
}

/// @nodoc
mixin _$ScanResult {
  String get rawText => throw _privateConstructorUsedError;
  ScanConfidence get confidence => throw _privateConstructorUsedError;
  DateTime get processedAt => throw _privateConstructorUsedError;
  String? get ocrProvider => throw _privateConstructorUsedError;
  Map<String, double>? get fieldConfidence =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this ScanResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScanResultCopyWith<ScanResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanResultCopyWith<$Res> {
  factory $ScanResultCopyWith(
    ScanResult value,
    $Res Function(ScanResult) then,
  ) = _$ScanResultCopyWithImpl<$Res, ScanResult>;
  @useResult
  $Res call({
    String rawText,
    ScanConfidence confidence,
    DateTime processedAt,
    String? ocrProvider,
    Map<String, double>? fieldConfidence,
    String? errorMessage,
  });
}

/// @nodoc
class _$ScanResultCopyWithImpl<$Res, $Val extends ScanResult>
    implements $ScanResultCopyWith<$Res> {
  _$ScanResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawText = null,
    Object? confidence = null,
    Object? processedAt = null,
    Object? ocrProvider = freezed,
    Object? fieldConfidence = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            rawText:
                null == rawText
                    ? _value.rawText
                    : rawText // ignore: cast_nullable_to_non_nullable
                        as String,
            confidence:
                null == confidence
                    ? _value.confidence
                    : confidence // ignore: cast_nullable_to_non_nullable
                        as ScanConfidence,
            processedAt:
                null == processedAt
                    ? _value.processedAt
                    : processedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            ocrProvider:
                freezed == ocrProvider
                    ? _value.ocrProvider
                    : ocrProvider // ignore: cast_nullable_to_non_nullable
                        as String?,
            fieldConfidence:
                freezed == fieldConfidence
                    ? _value.fieldConfidence
                    : fieldConfidence // ignore: cast_nullable_to_non_nullable
                        as Map<String, double>?,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScanResultImplCopyWith<$Res>
    implements $ScanResultCopyWith<$Res> {
  factory _$$ScanResultImplCopyWith(
    _$ScanResultImpl value,
    $Res Function(_$ScanResultImpl) then,
  ) = __$$ScanResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String rawText,
    ScanConfidence confidence,
    DateTime processedAt,
    String? ocrProvider,
    Map<String, double>? fieldConfidence,
    String? errorMessage,
  });
}

/// @nodoc
class __$$ScanResultImplCopyWithImpl<$Res>
    extends _$ScanResultCopyWithImpl<$Res, _$ScanResultImpl>
    implements _$$ScanResultImplCopyWith<$Res> {
  __$$ScanResultImplCopyWithImpl(
    _$ScanResultImpl _value,
    $Res Function(_$ScanResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rawText = null,
    Object? confidence = null,
    Object? processedAt = null,
    Object? ocrProvider = freezed,
    Object? fieldConfidence = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$ScanResultImpl(
        rawText:
            null == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                    as String,
        confidence:
            null == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                    as ScanConfidence,
        processedAt:
            null == processedAt
                ? _value.processedAt
                : processedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        ocrProvider:
            freezed == ocrProvider
                ? _value.ocrProvider
                : ocrProvider // ignore: cast_nullable_to_non_nullable
                    as String?,
        fieldConfidence:
            freezed == fieldConfidence
                ? _value._fieldConfidence
                : fieldConfidence // ignore: cast_nullable_to_non_nullable
                    as Map<String, double>?,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScanResultImpl implements _ScanResult {
  const _$ScanResultImpl({
    required this.rawText,
    required this.confidence,
    required this.processedAt,
    this.ocrProvider,
    final Map<String, double>? fieldConfidence,
    this.errorMessage,
  }) : _fieldConfidence = fieldConfidence;

  factory _$ScanResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanResultImplFromJson(json);

  @override
  final String rawText;
  @override
  final ScanConfidence confidence;
  @override
  final DateTime processedAt;
  @override
  final String? ocrProvider;
  final Map<String, double>? _fieldConfidence;
  @override
  Map<String, double>? get fieldConfidence {
    final value = _fieldConfidence;
    if (value == null) return null;
    if (_fieldConfidence is EqualUnmodifiableMapView) return _fieldConfidence;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'ScanResult(rawText: $rawText, confidence: $confidence, processedAt: $processedAt, ocrProvider: $ocrProvider, fieldConfidence: $fieldConfidence, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanResultImpl &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.ocrProvider, ocrProvider) ||
                other.ocrProvider == ocrProvider) &&
            const DeepCollectionEquality().equals(
              other._fieldConfidence,
              _fieldConfidence,
            ) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rawText,
    confidence,
    processedAt,
    ocrProvider,
    const DeepCollectionEquality().hash(_fieldConfidence),
    errorMessage,
  );

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanResultImplCopyWith<_$ScanResultImpl> get copyWith =>
      __$$ScanResultImplCopyWithImpl<_$ScanResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanResultImplToJson(this);
  }
}

abstract class _ScanResult implements ScanResult {
  const factory _ScanResult({
    required final String rawText,
    required final ScanConfidence confidence,
    required final DateTime processedAt,
    final String? ocrProvider,
    final Map<String, double>? fieldConfidence,
    final String? errorMessage,
  }) = _$ScanResultImpl;

  factory _ScanResult.fromJson(Map<String, dynamic> json) =
      _$ScanResultImpl.fromJson;

  @override
  String get rawText;
  @override
  ScanConfidence get confidence;
  @override
  DateTime get processedAt;
  @override
  String? get ocrProvider;
  @override
  Map<String, double>? get fieldConfidence;
  @override
  String? get errorMessage;

  /// Create a copy of ScanResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScanResultImplCopyWith<_$ScanResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
