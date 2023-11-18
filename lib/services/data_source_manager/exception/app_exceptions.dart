import '../error_handler/error_model.dart';

/// Class for masking the exceptions
class AppException implements Exception {
  final String? _message;
  final String? _prefix;
  final ErrorModel? _errorModel;

  AppException([this._message, this._prefix = '', this._errorModel]);

  String? get message => _message;

  ErrorModel? get errorModel => _errorModel;

  @override
  String toString() {
    return "$_prefix$_message";
  }
}
