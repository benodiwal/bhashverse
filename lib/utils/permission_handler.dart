import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<bool> requestPermissions() async {
    final micResStatus = await Permission.microphone.request();

    if (micResStatus == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }
}
