import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../enums/gender_enum.dart';
import '../../../utils/constants/app_constants.dart';

class VoiceAssistantController extends GetxController {
  late final Rx<GenderEnum> _selectedGender;
  Box hiveDBInstance = Hive.box(hiveDBName);

  GenderEnum getSelectedGender() => _selectedGender.value;

  @override
  void onInit() {
    var selectedGender = hiveDBInstance.get(preferredVoiceAssistantGender);
    if (selectedGender != null && selectedGender.isNotEmpty) {
      _selectedGender = GenderEnum.values.byName(selectedGender).obs;
    } else {
      _selectedGender = GenderEnum.female.obs;
    }
    super.onInit();
  }

  void setSelectedGender(GenderEnum selectedGender) {
    _selectedGender.value = selectedGender;
    hiveDBInstance.put(preferredVoiceAssistantGender, selectedGender.name);
  }
}
