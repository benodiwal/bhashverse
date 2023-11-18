import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

import 'enums/gender_enum.dart';
import 'localization/app_localization.dart';
import 'localization/localization_keys.dart';
import 'presentation/splash/binding/splash_binding.dart';
import 'routes/app_routes.dart';
import 'utils/constants/app_constants.dart';
import 'utils/theme/app_theme.dart';
import 'utils/theme/app_theme_provider.dart';
import 'utils/theme/app_theme_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  GestureBinding.instance.resamplingEnabled = true;

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Hive.initFlutter();
  await Hive.openBox(hiveDBName);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AppThemeProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box hiveDBInstance;
  late String appLocale;

  @override
  void initState() {
    super.initState();
    hiveDBInstance = Hive.box(hiveDBName);

    // Localization preference
    appLocale = hiveDBInstance.get(preferredAppLocale,
        defaultValue: Get.deviceLocale?.languageCode);
    if (appLocale.isEmpty) {
      hiveDBInstance.put(preferredAppLocale, appLocale);
    }

    // Set user selected theme (from Settings screen)
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<AppThemeProvider>(context, listen: false)
          .loadUserPreferredTheme();
    });

    // This callback is called every time the system brightness changes
    var window = WidgetsBinding.instance.platformDispatcher;
    window.onPlatformBrightnessChanged = () {
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      var brightness = window.platformBrightness;
      ThemeMode userPreferredThemeMode =
          getUserPreferredThemeMode(hiveDBInstance);
      if (userPreferredThemeMode == ThemeMode.system) {
        if (brightness == Brightness.light) {
          Provider.of<AppThemeProvider>(context, listen: false)
              .setAppTheme(ThemeMode.light, storeToPreference: false);
        } else {
          Provider.of<AppThemeProvider>(context, listen: false)
              .setAppTheme(ThemeMode.dark, storeToPreference: false);
        }
      }
    };

    // Voice assistant preference
    if (hiveDBInstance.get(preferredVoiceAssistantGender) == null) {
      hiveDBInstance.put(preferredVoiceAssistantGender, GenderEnum.female.name);
    }

    // Transliteration preference
    if (hiveDBInstance.get(enableTransliteration) == null) {
      hiveDBInstance.put(enableTransliteration, true);
    }

    // Streaming vs Batch model preference
    if (hiveDBInstance.get(isStreamingPreferred) == null) {
      hiveDBInstance.put(isStreamingPreferred, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        minTextAdapt: true,
        builder: (context, child) {
          return GetMaterialApp(
            onGenerateTitle: (context) => bhashiniTitle.tr,
            debugShowCheckedModeBanner: false,
            translations: AppLocalization(),
            locale: Locale(appLocale),
            fallbackLocale: const Locale(defaultLangCode, defaultCountry),
            themeMode: context.appThemeMode,
            theme: lightMaterialThemeData(),
            darkTheme: darkMaterialThemeData(),
            getPages: AppRoutes.pages,
            initialBinding: SplashBinding(),
            initialRoute: AppRoutes.splashRoute,
          );
        });
  }
}