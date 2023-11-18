import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/localization_keys.dart';
import '../../../models/onboarding_model.dart';
import '../../../utils/constants/app_constants.dart';

class OnboardingData {
  static final List<OnboardingModel> onboardingPages = [
    OnboardingModel(
      imageWidget: Image.asset(
        imgOnboarding1,
        fit: BoxFit.fitWidth,
      ),
      headerText: speechRecognition.tr,
      bodyText: automaticallyRecognizeAndConvert.tr,
    ),
    OnboardingModel(
      imageWidget: Image.asset(
        imgOnboarding2,
        fit: BoxFit.fitWidth,
      ),
      headerText: speechToSpeechTranslation.tr,
      bodyText: translateYourVoiceInOneIndianLanguage.tr,
    ),
    OnboardingModel(
      imageWidget: Image.asset(
        imgOnboarding3,
        fit: BoxFit.fitWidth,
      ),
      headerText: languageTranslation.tr,
      bodyText: translateSentencesFromOneIndianLanguageToAnother.tr,
    ),
    // TODO: uncomment after chat feature added
    // OnboardingModel(
    //   image: Image.asset(
    //     imgOnboarding4,
    //     fit: BoxFit.fitWidth,
    //   ),
    //   headerText: bhashaverseChatBot.tr,
    //   bodyText: translateSentencesFromOneIndianLanguageToAnother.tr,
    // )
  ];
}
