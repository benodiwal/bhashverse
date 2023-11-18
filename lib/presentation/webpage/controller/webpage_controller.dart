import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class WebpageController extends GetxController {
  
  TextEditingController urlController = TextEditingController();

  @override
  void onClose() {
    urlController.dispose();
    super.onClose();
  }
  
}
