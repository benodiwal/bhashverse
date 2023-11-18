import '../constants/api_constants.dart';

String get restAPIUserIDKey {
  return const String.fromEnvironment(APIConstants.kUserIdREST,
      defaultValue: '');
}

String get restApiULCAKey {
  return const String.fromEnvironment(APIConstants.kULCAAPIKeyREST,
      defaultValue: '');
}
