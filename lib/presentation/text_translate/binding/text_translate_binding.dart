import 'package:get/get.dart';

import '../controller/text_translate_controller.dart';

class TextTranslateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TextTranslateController());
  }
}
