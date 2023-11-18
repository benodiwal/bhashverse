// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_generic_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ApiGenericResponseImpl _$$ApiGenericResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ApiGenericResponseImpl(
      status: json['status'] as int?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$ApiGenericResponseImplToJson(
        _$ApiGenericResponseImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };
