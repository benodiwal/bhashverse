import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../localization/localization_keys.dart';
import '../models/task_sequence_response_model.dart';
import '../models/rest_compute_response_model.dart';
import '../utils/constants/api_constants.dart';
import '../utils/environment/rest_api_key_env.dart';
import 'data_source_manager/exception/app_exceptions.dart';
import 'data_source_manager/models/api_result.dart';
import 'network_error.dart';

class DHRUVAAPIClient {
  late Dio _dio;

  static DHRUVAAPIClient? translationAppAPIClient;

  DHRUVAAPIClient(dio) {
    _dio = dio;
  }

  CancelToken transliterationAPIcancelToken = CancelToken();

  static DHRUVAAPIClient getAPIClientInstance() {
    var options = BaseOptions(
      baseUrl: APIConstants.ULCA_CONFIG_API_URL,
      connectTimeout: 80000,
      receiveTimeout: 50000,
    );
    translationAppAPIClient = translationAppAPIClient ??
        DHRUVAAPIClient(Dio(options)
          ..interceptors.addAll(
            [AuthKeyHeaderInterceptor()],
          ));
    return translationAppAPIClient!;
  }

  Future<Result<AppException, TaskSequenceResponse>> getTaskSequence(
      {required requestPayload}) async {
    try {
      var response = await _dio.post(
        APIConstants.TASK_SEQUENCE_ENDPOINT,
        data: requestPayload,
      );
      if (response.data == null) {
        return Result.failure(AppException(somethingWentWrong.tr));
      }
      return Result.success(TaskSequenceResponse.fromJson(response.data));
    } on DioError catch (error) {
      return Result.failure(
          AppException(NetworkError(error).getErrorModel().errorMessage));
    } on Exception catch (_) {
      return Result.failure(AppException(somethingWentWrong.tr));
    }
  }

  Future<Result<AppException, RESTComputeResponseModel>> sendComputeRequest({
    required baseUrl,
    required authorizationKey,
    required authorizationValue,
    required computePayload,
  }) async {
    try {
      // using new instance of Dio as both baseUrl and
      // header wil dynamic in this API call
      var response = await Dio(
          BaseOptions(connectTimeout: 80000, receiveTimeout: 50000, headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        authorizationKey: authorizationValue,
      })).post(
        baseUrl,
        data: computePayload,
      );

      if (response.data == null) {
        return Result.failure(AppException(somethingWentWrong.tr));
      }
      return Result.success(RESTComputeResponseModel.fromJson(response.data));
    } on DioError catch (error) {
      return Result.failure(
          AppException(NetworkError(error).getErrorModel().errorMessage));
    } on Exception catch (_) {
      return Result.failure(AppException(somethingWentWrong.tr));
    }
  }

  Future<Result<AppException, dynamic>> sendFeedbackRequest(
      {required requestPayload}) async {
    Dio dio = Dio(BaseOptions(
        baseUrl: APIConstants.FEEDBACK_BASE_URL_DEV,
        connectTimeout: 80000,
        receiveTimeout: 50000,
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        }));
    try {
      var response = await dio.post(
        APIConstants.FEEDBACK_REQ_URL,
        data: requestPayload,
      );
      if (response.data == null) {
        return Result.failure(AppException(somethingWentWrong.tr));
      }
      return Result.success(response.data);
    } on DioError catch (error) {
      return Result.failure(
          AppException(NetworkError(error).getErrorModel().errorMessage));
    } on Exception catch (_) {
      return Result.failure(AppException(somethingWentWrong.tr));
    }
  }

  Future<Result<AppException, dynamic>> submitFeedback(
      {required url,
      required requestPayload,
      required authorizationKey,
      required authorizationValue}) async {
    Dio dio =
        Dio(BaseOptions(connectTimeout: 80000, receiveTimeout: 50000, headers: {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      authorizationKey: authorizationValue,
    }));

    try {
      var response = await dio.post(
        url,
        data: requestPayload,
      );
      if (response.data == null) {
        return Result.failure(AppException(somethingWentWrong.tr));
      }
      return Result.success(response.data);
    } on DioError catch (error) {
      return Result.failure(
          AppException(NetworkError(error).getErrorModel().errorMessage));
    } on Exception catch (_) {
      return Result.failure(AppException(somethingWentWrong.tr));
    }
  }
}

class AuthKeyHeaderInterceptor extends Interceptor {
  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      options.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': '*/*',
        APIConstants.kUserIdREST: restAPIUserIDKey,
        APIConstants.kULCAAPIKeyREST: restApiULCAKey,
      });
    } catch (_) {}
    return super.onRequest(options, handler);
  }
}
