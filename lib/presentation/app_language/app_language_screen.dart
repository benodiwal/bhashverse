import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/custom_elevated_button.dart';
import '../../common/widgets/language_selection_widget.dart';
import '../../enums/language_enum.dart';
import '../../localization/localization_keys.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants/api_constants.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/remove_glow_effect.dart';
import '../../utils/snackbar_utils.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import 'controller/app_language_controller.dart';

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({super.key});

  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {
  late AppLanguageController _appLanguageController;
  late TextEditingController _languageSearchController;
  final FocusNode _focusNodeLanguageSearch = FocusNode();
  late final Box _hiveDBInstance;

  @override
  void initState() {
    _appLanguageController = Get.find();
    _languageSearchController = TextEditingController();
    _hiveDBInstance = Hive.box(hiveDBName);
    setSelectedLanguageFromArg();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_focusNodeLanguageSearch.hasFocus) {
      _focusNodeLanguageSearch.unfocus();
    }
    _focusNodeLanguageSearch.dispose();
    _appLanguageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        backgroundColor: context.appTheme.listingScreenBGColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.w),
                Text(
                  selectAppLanguage.tr,
                  style: semibold22(context),
                ),
                SizedBox(height: 8.w),
                Text(
                  youCanAlwaysChange.tr,
                  style: secondary14(context),
                ),
                SizedBox(height: 24.w),
                _textFormFieldContainer(),
                SizedBox(height: 24.w),
                Obx(
                  () => Expanded(
                    child: ScrollConfiguration(
                      behavior: RemoveScrollingGlowEffect(),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 0.02.sh,
                          crossAxisSpacing: 0.02.sh,
                          childAspectRatio: 2.3,
                          crossAxisCount:
                              MediaQuery.of(context).size.shortestSide > 600
                                  ? 3
                                  : 2,
                        ),
                        itemCount:
                            _appLanguageController.getAppLanguageList().length,
                        itemBuilder: (context, index) {
                          return Obx(
                            () => LanguageSelectionWidget(
                              title: getLangNameInAppLanguage(
                                  _appLanguageController
                                          .getAppLanguageList()[index]
                                      [APIConstants.kLanguageCode],
                                  _appLanguageController
                                      .getSelectedLanguageCode()),
                              subTitle: _appLanguageController
                                      .getAppLanguageList()[index]
                                  [APIConstants.kNativeName],
                              onItemTap: () {
                                _appLanguageController
                                    .setSelectedLanguageIndex(index);
                              },
                              index: index,
                              selectedIndex: _appLanguageController
                                  .getSelectedLanguageIndex(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.w),
                CustomElevatedButton(
                  buttonText: continueText.tr,
                  backgroundColor: context.appTheme.primaryColor,
                  borderRadius: 16,
                  onButtonTap: () {
                    if (_appLanguageController
                            .getAppLanguageList()
                            .isNotEmpty &&
                        _appLanguageController.getSelectedLanguageIndex() !=
                            null &&
                        _appLanguageController.getSelectedLanguageIndex()! <
                            _appLanguageController
                                .getAppLanguageList()
                                .length) {
                      _languageSearchController.clear();
                      _appLanguageController.saveSelectedLocaleInDB();
                      Get.updateLocale(Locale(
                          _appLanguageController.getSelectedLanguageCode()));
                      if (_hiveDBInstance.get(introShownAlreadyKey,
                          defaultValue: false)) {
                        Get.back();
                      } else {
                        Get.toNamed(AppRoutes.onboardingRoute);
                      }
                    } else {
                      showDefaultSnackbar(
                          message: errorPleaseSelectLanguage.tr);
                    }
                  },
                ),
                SizedBox(height: 16.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFormFieldContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8).w,
      padding: const EdgeInsets.only(left: 16).w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.appTheme.containerColor,
      ),
      child: TextFormField(
        cursorColor: context.appTheme.secondaryTextColor,
        style: regular16(context).copyWith(fontSize: 18),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(0),
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: context.appTheme.secondaryTextColor,
          ),
          hintText: searchLanguage.tr,
          hintStyle: light16(context)
              .copyWith(fontSize: 18, color: context.appTheme.titleTextColor),
        ),
        onChanged: ((value) => performLanguageSearch(value)),
        controller: _languageSearchController,
        focusNode: _focusNodeLanguageSearch,
      ),
    );
  }

  void performLanguageSearch(String searchString) {
    if (_appLanguageController.getAppLanguageList().isEmpty) {
      _appLanguageController.setAllLanguageList();
    }

    List<Map<String, dynamic>> tempList =
        _appLanguageController.getAppLanguageList();
    if (searchString.isNotEmpty) {
      List<Map<String, dynamic>> searchedLanguageList = tempList.where(
        (language) {
          return language[APIConstants.kEnglishName]
                  .toLowerCase()
                  .contains(searchString.toLowerCase()) ||
              language[APIConstants.kNativeName]
                  .toLowerCase()
                  .contains(searchString.toLowerCase()) ||
              getLangNameInAppLanguage(language[APIConstants.kLanguageCode],
                      _appLanguageController.getSelectedLanguageCode())
                  .contains(searchString);
        },
      ).toList();
      _appLanguageController.setCustomLanguageList(searchedLanguageList);
      _appLanguageController.setSelectedLanguageIndex(null);
      for (var i = 0; i < searchedLanguageList.length; i++) {
        if (searchedLanguageList[i][APIConstants.kLanguageCode] ==
            Get.locale?.languageCode) {
          _appLanguageController.setSelectedLanguageIndex(i);
        }
      }
    } else {
      _appLanguageController.setAllLanguageList();
    }
  }

  String getLangNameInAppLanguage(
      String languageCode, String selectedLangCode) {
    return APIConstants.getLanguageCodeOrName(
        value: languageCode,
        returnWhat: LanguageMap.languageNameInAppLanguage,
        lang_code_map: APIConstants.LANGUAGE_CODE_MAP,
        langCode: selectedLangCode);
  }

  void setSelectedLanguageFromArg() {
    if (Get.arguments != null && Get.arguments[selectedLanguage] != null) {
      _appLanguageController.setSelectedLanguageIndex(_appLanguageController
          .getAppLanguageList()
          .indexWhere((element) =>
              element[APIConstants.kNativeName] ==
              Get.arguments[selectedLanguage]));
    }
  }

  Future<bool> _onWillPop() async {
    if (_focusNodeLanguageSearch.hasFocus) {
      _focusNodeLanguageSearch.unfocus();
      _languageSearchController.clear();
      _appLanguageController.setAllLanguageList();
    } else {
      Get.updateLocale(
        Locale(_hiveDBInstance.get(preferredAppLocale)),
      );
      Get.back();
    }
    return Future.value(false);
  }
}
