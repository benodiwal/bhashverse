import 'package:get/get.dart';

import '../controller/source_target_language_controller.dart';

class SourceTargetLanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SourceTargetLanguageController());
  }
}
