import 'package:get/get.dart';

import '../controller/voice_text_translate_controller.dart';

class VoiceTextTranslateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VoiceTextTranslateController());
  }
}
