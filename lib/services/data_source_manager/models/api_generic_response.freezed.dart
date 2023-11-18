// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_generic_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ApiGenericResponse _$ApiGenericResponseFromJson(Map<String, dynamic> json) {
  return _ApiGenericResponse.fromJson(json);
}

/// @nodoc
mixin _$ApiGenericResponse {
  int? get status => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApiGenericResponseCopyWith<ApiGenericResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiGenericResponseCopyWith<$Res> {
  factory $ApiGenericResponseCopyWith(
          ApiGenericResponse value, $Res Function(ApiGenericResponse) then) =
      _$ApiGenericResponseCopyWithImpl<$Res, ApiGenericResponse>;
  @useResult
  $Res call({int? status, String? message});
}

/// @nodoc
class _$ApiGenericResponseCopyWithImpl<$Res, $Val extends ApiGenericResponse>
    implements $ApiGenericResponseCopyWith<$Res> {
  _$ApiGenericResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApiGenericResponseImplCopyWith<$Res>
    implements $ApiGenericResponseCopyWith<$Res> {
  factory _$$ApiGenericResponseImplCopyWith(_$ApiGenericResponseImpl value,
          $Res Function(_$ApiGenericResponseImpl) then) =
      __$$ApiGenericResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? status, String? message});
}

/// @nodoc
class __$$ApiGenericResponseImplCopyWithImpl<$Res>
    extends _$ApiGenericResponseCopyWithImpl<$Res, _$ApiGenericResponseImpl>
    implements _$$ApiGenericResponseImplCopyWith<$Res> {
  __$$ApiGenericResponseImplCopyWithImpl(_$ApiGenericResponseImpl _value,
      $Res Function(_$ApiGenericResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? message = freezed,
  }) {
    return _then(_$ApiGenericResponseImpl(
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiGenericResponseImpl implements _ApiGenericResponse {
  _$ApiGenericResponseImpl({this.status, this.message});

  factory _$ApiGenericResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiGenericResponseImplFromJson(json);

  @override
  final int? status;
  @override
  final String? message;

  @override
  String toString() {
    return 'ApiGenericResponse(status: $status, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiGenericResponseImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, status, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiGenericResponseImplCopyWith<_$ApiGenericResponseImpl> get copyWith =>
      __$$ApiGenericResponseImplCopyWithImpl<_$ApiGenericResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiGenericResponseImplToJson(
      this,
    );
  }
}

abstract class _ApiGenericResponse implements ApiGenericResponse {
  factory _ApiGenericResponse({final int? status, final String? message}) =
      _$ApiGenericResponseImpl;

  factory _ApiGenericResponse.fromJson(Map<String, dynamic> json) =
      _$ApiGenericResponseImpl.fromJson;

  @override
  int? get status;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$ApiGenericResponseImplCopyWith<_$ApiGenericResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
