import 'package:get/get.dart';

import '../../../utils/constants/language_map_translated.dart';

class SourceTargetLanguageController extends GetxController {
  final RxList<dynamic> _languagesListRegular = [].obs;
  final RxList<dynamic> _languagesListBeta = [].obs;
  final _selectedRegularLangIndex = Rxn<int>();
  final _selectedBetaLangIndex = Rxn<int>();
  RxBool isAdvanceMenuOpened = false.obs;

  Map<String, String>? selectedLanguageMap = {};

  @override
  void onInit() {
    selectedLanguageMap =
        TranslatedLanguagesMap.language[Get.locale?.languageCode];
    super.onInit();
  }

  List<dynamic> getLanguageListRegular() {
    return _languagesListRegular;
  }

  List<dynamic> getLanguageListBeta() {
    return _languagesListBeta;
  }

  void setLanguageListRegular(List<dynamic> languageList) {
    _languagesListRegular.clear();
    _languagesListRegular.addAll(languageList);
  }

  void setLanguageListBeta(List<dynamic> languageList) {
    _languagesListBeta.clear();
    _languagesListBeta.addAll(languageList);
  }

  int? getSelectedRegularLangIndex() {
    return _selectedRegularLangIndex.value;
  }

  void setSelectedRegularLangIndex(int? index) {
    _selectedRegularLangIndex.value = index;
  }

  int? getSelectedBetaLangIndex() {
    return _selectedBetaLangIndex.value;
  }

  void setSelectedBetaLangIndex(int? index) {
    _selectedBetaLangIndex.value = index;
  }
}
