import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../utils/network_utils.dart';
import '../no_internet_screen.dart';

class NoInternetController extends GetxController {
  late StreamSubscription<ConnectivityResult> subscription;
  bool shouldShowDialog = true;
  @override
  void onInit() async {
    shouldShowDialog = !await isNetworkConnected();
    if (shouldShowDialog) {
      Get.dialog(const NoInternetScreen(),
          barrierDismissible: false, useSafeArea: false);
      shouldShowDialog = false;
    }
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        if (shouldShowDialog) {
          Get.dialog(const NoInternetScreen(),
              barrierDismissible: false, useSafeArea: false);
        }
        shouldShowDialog = false;
      } else if (!shouldShowDialog) {
        Get.back();
        shouldShowDialog = true;
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    subscription.cancel();
    super.onClose();
  }
}
