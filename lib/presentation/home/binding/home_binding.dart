import 'package:get/get.dart';

import '../../no_internet/controller/no_internet_controller.dart';
import '../controller/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.put(NoInternetController(), permanent: true);
  }
}
