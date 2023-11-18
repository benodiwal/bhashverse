import 'package:dio/dio.dart';

import '../utils/constants/api_constants.dart';
import 'data_source_manager/error_handler/error_model.dart';
import 'data_source_manager/exception/exception_helper.dart';

class NetworkError extends ExceptionHandler {
  NetworkError(DioError error) : super(error) {
    handleDioResponseError(error.response);
  }

  late ErrorModel _errorModel;

  @override
  ErrorModel getErrorModel() => _errorModel;

  @override
  void handleDioResponseError(Response? response,
      {bool isFromAuthAPI = false}) {
    switch (response?.statusCode) {
      case 400:
        _errorModel = ErrorModel(
          response?.statusCode,
          APIConstants.kApiResponseError,
          response?.data['message'] as String? ?? '',
        );
        break;
      case 401:
        _errorModel = ErrorModel(
          APIConstants.kApiUnAuthorizedExceptionErrorCode,
          APIConstants.kApiAuthExceptionError,
          APIConstants.kErrorMessageUnAuthorizedException,
        );
        break;
      case 404:
        _errorModel = ErrorModel(
          response?.statusCode,
          APIConstants.kApiResponseError,
          response?.data['message'] as String? ?? '',
        );
        break;
      case 409:
        _errorModel = ErrorModel(
          response?.statusCode,
          APIConstants.kApiDataConflict,
          response?.data['message'] as String? ?? '',
        );
        break;
      // Exception 402,403, ...
      default:
        _errorModel = ErrorModel(
            APIConstants.kApiUnknownErrorCode,
            APIConstants.kApiUnknownError,
            APIConstants.kErrorMessageGenericError);
    }
  }
}
