import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isNetworkConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return checkConnectivityResult(connectivityResult);
}

bool checkConnectivityResult(ConnectivityResult connectivityResult) {
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}
