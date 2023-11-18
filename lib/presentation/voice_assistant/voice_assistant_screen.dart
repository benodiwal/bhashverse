import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/custom_elevated_button.dart';
import '../../enums/gender_enum.dart';
import '../../localization/localization_keys.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import 'controller/voice_assistant_controller.dart';
import 'data/voice_assistant_data.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  late VoiceAssistantController _voiceAssistantController;

  @override
  void initState() {
    _voiceAssistantController = Get.find();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.listingScreenBGColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16).w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.w),
              Text(
                selectVoiceAssistant.tr,
                style: semibold24(context),
              ),
              SizedBox(height: 8.w),
              Text(
                youWillHearTheTranslationText.tr,
                style: regular14(context)
                    .copyWith(color: context.appTheme.secondaryTextColor),
              ),
              SizedBox(height: 56.w),
              Row(
                children: [
                  _avatarWidgetBuilder(
                    GenderEnum.male,
                    VoiceAssistantData.maleImgWidget,
                    male.tr,
                  ),
                  SizedBox(width: 10.w),
                  _avatarWidgetBuilder(
                    GenderEnum.female,
                    VoiceAssistantData.femaleImgWidget,
                    female.tr,
                  ),
                ],
              ),
              const Spacer(),
              CustomElevatedButton(
                buttonText: letsTranslate.tr,
                backgroundColor: context.appTheme.primaryColor,
                borderRadius: 16,
                onButtonTap: () {
                  Box hiveDBInstance = Hive.box(hiveDBName);
                  hiveDBInstance.put(introShownAlreadyKey, true);
                  Get.offAllNamed(AppRoutes.homeRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarWidgetBuilder(
    GenderEnum gender,
    Image avatarImage,
    String avatarTitle,
  ) {
    return Expanded(
      child: Obx(
        () => InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _voiceAssistantController.setSelectedGender(gender),
          child: Container(
            padding: const EdgeInsets.all(22).w,
            decoration: BoxDecoration(
              color: (_voiceAssistantController.getSelectedGender() == gender)
                  ? context.appTheme.lightBGColor
                  : context.appTheme.voiceAssistantBGColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1.w,
                color: (_voiceAssistantController.getSelectedGender() == gender)
                    ? context.appTheme.highlightedBorderColor
                    : context.appTheme.disabledBGColor,
              ),
            ),
            child: Column(
              children: [
                avatarImage,
                SizedBox(height: 16.w),
                Text(
                  avatarTitle,
                  style: regular18Primary(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
