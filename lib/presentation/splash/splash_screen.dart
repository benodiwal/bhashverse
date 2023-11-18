import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../localization/localization_keys.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import '../../utils/voice_recorder.dart';
import '../home/data/home_data.dart';
import '../onboarding/data/onboarding_data.dart';
import '../voice_assistant/data/voice_assistant_data.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Box _hiveDBInstance;
  bool isIntroShownAlready = false;
  Image appLogo = Image.asset(
    imgAppLogoSmall,
    height: 100.h,
    width: 100.w,
  );

  @override
  void initState() {
    _hiveDBInstance = Hive.box(hiveDBName);
    isIntroShownAlready =
        _hiveDBInstance.get(introShownAlreadyKey, defaultValue: false);
    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      Get.offNamed(isIntroShownAlready
          ? AppRoutes.homeRoute
          : AppRoutes.appLanguageRoute);
    });
    VoiceRecorder voiceRecorder = VoiceRecorder();
    voiceRecorder.clearOldRecordings();
  }

  @override
  void didChangeDependencies() {
    // Precache splash screen logo
    precacheImage(appLogo.image, context);
    // Precache home screen menu images
    for (var i = 0; i < HomeData.menuItems.length; i++) {
      precacheImage(HomeData.menuItems[i].imageWidget.image, context);
    }

    if (!isIntroShownAlready) {
      // Precache Onboarding screen images
      for (var i = 0; i < OnboardingData.onboardingPages.length; i++) {
        precacheImage(
            OnboardingData.onboardingPages[i].imageWidget.image, context);
      }

      // Precache voice assistant screen images
      precacheImage(VoiceAssistantData.maleImgWidget.image, context);
      precacheImage(VoiceAssistantData.femaleImgWidget.image, context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.splashScreenBGColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appLogo,
              SizedBox(
                height: 24.h,
              ),
              Text(
                bhashiniTitle.tr,
                textAlign: TextAlign.center,
                style: bold24(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
