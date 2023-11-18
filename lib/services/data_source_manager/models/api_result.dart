import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.freezed.dart';

@freezed
class Result<F, S> with _$Result<F, S> {
  const factory Result.success(S data) = Success<F, S>;

  const factory Result.failure(F error) = Failure<F, S>;
}
