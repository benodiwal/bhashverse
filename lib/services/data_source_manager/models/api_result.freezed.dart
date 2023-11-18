// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Result<F, S> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(S data) success,
    required TResult Function(F error) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(S data)? success,
    TResult? Function(F error)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(S data)? success,
    TResult Function(F error)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<F, S> value) success,
    required TResult Function(Failure<F, S> value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<F, S> value)? success,
    TResult? Function(Failure<F, S> value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<F, S> value)? success,
    TResult Function(Failure<F, S> value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<F, S, $Res> {
  factory $ResultCopyWith(
          Result<F, S> value, $Res Function(Result<F, S>) then) =
      _$ResultCopyWithImpl<F, S, $Res, Result<F, S>>;
}

/// @nodoc
class _$ResultCopyWithImpl<F, S, $Res, $Val extends Result<F, S>>
    implements $ResultCopyWith<F, S, $Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<F, S, $Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl<F, S> value, $Res Function(_$SuccessImpl<F, S>) then) =
      __$$SuccessImplCopyWithImpl<F, S, $Res>;
  @useResult
  $Res call({S data});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<F, S, $Res>
    extends _$ResultCopyWithImpl<F, S, $Res, _$SuccessImpl<F, S>>
    implements _$$SuccessImplCopyWith<F, S, $Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl<F, S> _value, $Res Function(_$SuccessImpl<F, S>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$SuccessImpl<F, S>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as S,
    ));
  }
}

/// @nodoc

class _$SuccessImpl<F, S> implements Success<F, S> {
  const _$SuccessImpl(this.data);

  @override
  final S data;

  @override
  String toString() {
    return 'Result<$F, $S>.success(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl<F, S> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<F, S, _$SuccessImpl<F, S>> get copyWith =>
      __$$SuccessImplCopyWithImpl<F, S, _$SuccessImpl<F, S>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(S data) success,
    required TResult Function(F error) failure,
  }) {
    return success(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(S data)? success,
    TResult? Function(F error)? failure,
  }) {
    return success?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(S data)? success,
    TResult Function(F error)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<F, S> value) success,
    required TResult Function(Failure<F, S> value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<F, S> value)? success,
    TResult? Function(Failure<F, S> value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<F, S> value)? success,
    TResult Function(Failure<F, S> value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class Success<F, S> implements Result<F, S> {
  const factory Success(final S data) = _$SuccessImpl<F, S>;

  S get data;
  @JsonKey(ignore: true)
  _$$SuccessImplCopyWith<F, S, _$SuccessImpl<F, S>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureImplCopyWith<F, S, $Res> {
  factory _$$FailureImplCopyWith(
          _$FailureImpl<F, S> value, $Res Function(_$FailureImpl<F, S>) then) =
      __$$FailureImplCopyWithImpl<F, S, $Res>;
  @useResult
  $Res call({F error});
}

/// @nodoc
class __$$FailureImplCopyWithImpl<F, S, $Res>
    extends _$ResultCopyWithImpl<F, S, $Res, _$FailureImpl<F, S>>
    implements _$$FailureImplCopyWith<F, S, $Res> {
  __$$FailureImplCopyWithImpl(
      _$FailureImpl<F, S> _value, $Res Function(_$FailureImpl<F, S>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = freezed,
  }) {
    return _then(_$FailureImpl<F, S>(
      freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as F,
    ));
  }
}

/// @nodoc

class _$FailureImpl<F, S> implements Failure<F, S> {
  const _$FailureImpl(this.error);

  @override
  final F error;

  @override
  String toString() {
    return 'Result<$F, $S>.failure(error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureImpl<F, S> &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureImplCopyWith<F, S, _$FailureImpl<F, S>> get copyWith =>
      __$$FailureImplCopyWithImpl<F, S, _$FailureImpl<F, S>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(S data) success,
    required TResult Function(F error) failure,
  }) {
    return failure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(S data)? success,
    TResult? Function(F error)? failure,
  }) {
    return failure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(S data)? success,
    TResult Function(F error)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<F, S> value) success,
    required TResult Function(Failure<F, S> value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<F, S> value)? success,
    TResult? Function(Failure<F, S> value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<F, S> value)? success,
    TResult Function(Failure<F, S> value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class Failure<F, S> implements Result<F, S> {
  const factory Failure(final F error) = _$FailureImpl<F, S>;

  F get error;
  @JsonKey(ignore: true)
  _$$FailureImplCopyWith<F, S, _$FailureImpl<F, S>> get copyWith =>
      throw _privateConstructorUsedError;
}
