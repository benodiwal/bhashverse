import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_generic_response.freezed.dart';
part 'api_generic_response.g.dart';

@freezed
class ApiGenericResponse with _$ApiGenericResponse {
  factory ApiGenericResponse({
    int? status,
    String? message,
  }) = _ApiGenericResponse;

  factory ApiGenericResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiGenericResponseFromJson(json);
}
