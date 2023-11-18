import 'dart:io';

import 'package:dio/dio.dart';

import '../../../utils/constants/api_constants.dart';
import '../error_handler/error_model.dart';

abstract class ExceptionHandler implements Exception {
  late ErrorModel _errorModel;
  DioError? _dioError;
  late Exception _exception;

  ExceptionHandler(Exception error) {
    // Init the error model for the default case
    _errorModel = ErrorModel(
      APIConstants.kApiUnknownErrorCode,
      APIConstants.kApiUnknownError,
      APIConstants.kErrorMessageGenericError,
    );

    if (error is DioError) {
      _handleDioError(error);
      _dioError = error;
    }

    _exception = error;
  }

  ErrorModel getErrorModel() => _errorModel;

  DioError? getDioError() => _dioError;

  Exception getException() => _exception;

  void _handleDioError(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        _errorModel = ErrorModel(
          APIConstants.kApiCanceledCode,
          APIConstants.kApiCanceled,
          APIConstants.kErrorMessageGenericError,
        );
        break;
      case DioErrorType.connectTimeout:
        _errorModel = ErrorModel(
          APIConstants.kApiConnectionTimeoutCode,
          APIConstants.kApiConnectionTimeout,
          APIConstants.kErrorMessageGenericError,
        );
        break;
      case DioErrorType.other:
        if (error.error is SocketException || error.error is HttpException) {
          _errorModel = ErrorModel(
            APIConstants.kApiDefaultCode,
            APIConstants.kApiDefault,
            APIConstants.kErrorMessageNetworkError,
          );
        } else {
          _errorModel = ErrorModel(
            APIConstants.kApiDefaultCode,
            APIConstants.kApiDefault,
            APIConstants.kErrorMessageGenericError,
          );
        }
        break;
      case DioErrorType.receiveTimeout:
        _errorModel = ErrorModel(
          APIConstants.kApiReceiveTimeoutCode,
          APIConstants.kApiReceiveTimeout,
          APIConstants.kErrorMessageConnectionTimeout,
        );
        break;
      case DioErrorType.response:
        _errorModel = ErrorModel(
          error.response?.statusCode,
          APIConstants.kApiResponseError,
          APIConstants.kErrorMessageGenericError,
        );
        break;
      case DioErrorType.sendTimeout:
        _errorModel = ErrorModel(
          APIConstants.kApiSendTimeoutCode,
          APIConstants.kApiSendTimeout,
          APIConstants.kErrorMessageConnectionTimeout,
        );
        break;
      default:
        _errorModel = ErrorModel(
          APIConstants.kApiUnknownErrorCode,
          APIConstants.kApiUnknownError,
          APIConstants.kErrorMessageGenericError,
        );
    }
  }

  void handleDioResponseError(Response? response, {bool isFromAuthAPI = false});
}
