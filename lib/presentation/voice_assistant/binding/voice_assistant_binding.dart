import 'package:get/get.dart';

import '../controller/voice_assistant_controller.dart';

class VoiceAssistantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VoiceAssistantController());
  }
}
