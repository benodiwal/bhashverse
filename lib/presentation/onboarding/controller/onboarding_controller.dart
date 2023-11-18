import 'package:get/get.dart';

class OnboardingController extends GetxController {
  final RxInt _currentPageIndex = 0.obs;

  int getCurrentPageIndex() => _currentPageIndex.value;

  void setCurrentPageIndex(int index) {
    _currentPageIndex.value = index;
  }
}
