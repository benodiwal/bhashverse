import 'package:bhashverse/presentation/webpage/controller/webpage_controller.dart';
import 'package:get/get.dart';

class WebpageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WebpageController());
  }
}