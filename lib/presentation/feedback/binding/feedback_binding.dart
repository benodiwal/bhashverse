import 'package:get/get.dart';

import '../controller/feedback_controller.dart';

class FeedbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FeedbackController());
  }
}
