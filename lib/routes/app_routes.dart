import 'package:bhashverse/presentation/webpage/binding/webpage_binding.dart';
import 'package:bhashverse/presentation/webpage/utils/webview_screen.dart';
import 'package:bhashverse/presentation/webpage/webpage_screen.dart';
import 'package:get/get.dart';

import '../presentation/conversation/binding/conversation_binding.dart';
import '../presentation/conversation/conversation_screen.dart';
import '../presentation/feedback/binding/feedback_binding.dart';
import '../presentation/feedback/feedback_screen.dart';
import '../presentation/home/binding/home_binding.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/source_target_language/binding/source_target_language_binding.dart';
import '../presentation/source_target_language/source_target_language_screen.dart';
import '../presentation/onboarding/binding/onboarding_binding.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/app_language/binding/app_language_binding.dart';
import '../presentation/app_language/app_language_screen.dart';
import '../presentation/voice_assistant/binding/voice_assistant_binding.dart';
import '../presentation/voice_assistant/voice_assistant_screen.dart';
import '../presentation/settings/binding/settings_binding.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/splash/binding/splash_binding.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/text_translate/binding/text_translate_binding.dart';
import '../presentation/text_translate/text_translate_screen.dart';
import '../presentation/voice_text_translate/binding/voice_text_translate_binding.dart';
import '../presentation/voice_text_translate/voice_text_translate_screen.dart';

class AppRoutes {
  static String homeRoute = '/home_route';
  static String splashRoute = '/splash_route';
  static String appLanguageRoute = '/app_language_route';
  static String voiceAssistantRoute = '/voice_assistant_route';
  static String onboardingRoute = '/onboarding_route';
  static String textTranslationRoute = '/text_translation_route';
  static String linkRoute = '/link_route';
  static String webViewRoute = "/webview_route";
  static String conversationRoute = '/conversation_route';
  static String voiceTextTranslationRoute = '/voice_text_translation_route';
  static String languageSelectionRoute = '/language_selection_route';
  static String settingsRoute = '/settingsRoute';
  static String feedbackRoute = '/feedbackRoute';

  static List<GetPage> pages = [
    GetPage(
      name: splashRoute,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: appLanguageRoute,
      page: () => const AppLanguageScreen(),
      binding: AppLanguageBinding(),
    ),
    GetPage(
      name: onboardingRoute,
      page: () => const OnBoardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: voiceAssistantRoute,
      page: () => const VoiceAssistantScreen(),
      binding: VoiceAssistantBinding(),
    ),
    GetPage(
      name: homeRoute,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: textTranslationRoute,
      page: () => const TextTranslateScreen(),
      binding: TextTranslateBinding(),
    ),
    GetPage(
      name: linkRoute, 
      page: () => const WebpageScreen(),
      binding: WebpageBinding(),
      ),
    GetPage(
      name: conversationRoute,
      page: () => const ConversationScreen(),
      binding: ConversationBinding(),
    ),
    GetPage(
      name: voiceTextTranslationRoute,
      page: () => const VoiceTextTranslateScreen(),
      binding: VoiceTextTranslateBinding(),
    ),
    GetPage(
      name: languageSelectionRoute,
      page: () => const SourceTargetLanguageScreen(),
      binding: SourceTargetLanguageBinding(),
    ),
    GetPage(
      name: settingsRoute,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: feedbackRoute,
      page: () => const FeedbackScreen(),
      binding: FeedbackBinding(),
    ),
    GetPage(
      name: webViewRoute, 
      page: () => const WebViewScreen(),
      )
  ];
}
