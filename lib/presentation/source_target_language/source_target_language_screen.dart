import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/language_selection_widget.dart';
import '../../enums/language_enum.dart';
import '../../localization/localization_keys.dart';
import '../../utils/constants/api_constants.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/remove_glow_effect.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import 'controller/source_target_language_controller.dart';

class SourceTargetLanguageScreen extends StatefulWidget {
  const SourceTargetLanguageScreen({super.key});

  @override
  State<SourceTargetLanguageScreen> createState() =>
      _SourceTargetLanguageScreenState();
}

class _SourceTargetLanguageScreenState extends State<SourceTargetLanguageScreen>
    with SingleTickerProviderStateMixin {
  late SourceTargetLanguageController _languageSelectionController;
  late TextEditingController _languageSearchController;
  final FocusNode _focusNodeLanguageSearch = FocusNode();
  bool isUserSelectedFromSearchResult = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _languageSelectionController = Get.find();
    _languageSearchController = TextEditingController();

    super.initState();
    setLanguageListFromArgument();
    _controller = AnimationController(
      vsync: this,
      duration: defaultAnimationTime,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: pi,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _languageSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.listingScreenBGColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16.w),
              _headerWidget(),
              SizedBox(height: 24.w),
              _textFormFieldContainer(),
              SizedBox(height: 20.w),
              _buildLanguages(context),
              SizedBox(height: 16.w),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildLanguages(BuildContext context) {
    return Expanded(
      child: ScrollConfiguration(
        behavior: RemoveScrollingGlowEffect(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRegularLanguageList(context),
              _buildBetaLanguageList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularLanguageList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          generalLanguages.tr,
          style: semibold18(context),
        ),
        SizedBox(height: 8.w),
        Text(
          generalLanguagesBrief.tr,
          style: secondary14(context),
        ),
        SizedBox(height: 16.w),
        Obx(
          () => GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 0.02.sh,
              crossAxisSpacing: 0.02.sh,
              childAspectRatio: 2.3,
              crossAxisCount:
                  MediaQuery.of(context).size.shortestSide > 600 ? 3 : 2,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount:
                _languageSelectionController.getLanguageListRegular().length,
            itemBuilder: (context, index) {
              return Obx(
                () {
                  return LanguageSelectionWidget(
                    title: APIConstants.getLanNameInAppLang(
                        _languageSelectionController
                            .getLanguageListRegular()[index]),
                    subTitle: getNativeNameOfLanguage(
                        _languageSelectionController
                            .getLanguageListRegular()[index]),
                    onItemTap: () => Get.back(
                        result: _languageSelectionController
                            .getLanguageListRegular()[index]),
                    index: index,
                    selectedIndex: _languageSelectionController
                        .getSelectedRegularLangIndex(),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 20.w),
      ],
    );
  }

  Widget _buildBetaLanguageList(BuildContext context) {
    return Visibility(
      visible: _languageSelectionController.getLanguageListBeta().isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () async {
              _languageSelectionController.isAdvanceMenuOpened.value =
                  !_languageSelectionController.isAdvanceMenuOpened.value;
              if (_languageSelectionController.isAdvanceMenuOpened.value) {
                _controller.forward();
                await Future.delayed(const Duration(milliseconds: 100));
                await _scrollController.animateTo(
                    _scrollController.position.pixels + 0.14.sh,
                    duration: defaultAnimationTime,
                    curve: Curves.easeIn);
              } else {
                _controller.reverse();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        betaLanguages.tr,
                        style: semibold18(context),
                      ),
                      SizedBox(height: 8.w),
                      Text(
                        betaLanguagesBrief.tr,
                        style: secondary14(context),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateZ(
                            _animation.value,
                          ),
                        child: SvgPicture.asset(iconArrowDown,
                            color: context.appTheme.highlightedTextColor),
                      );
                    }),
              ],
            ),
          ),
          SizedBox(height: 16.w),
          Obx(
            () => AnimatedContainer(
              duration: defaultAnimationTime,
              height: _languageSelectionController.isAdvanceMenuOpened.value
                  ? null
                  : 0,
              child: Obx(
                () => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 0.02.sh,
                    crossAxisSpacing: 0.02.sh,
                    childAspectRatio: 2.3,
                    crossAxisCount:
                        MediaQuery.of(context).size.shortestSide > 600 ? 3 : 2,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      _languageSelectionController.getLanguageListBeta().length,
                  itemBuilder: (context, index) {
                    return Obx(
                      () {
                        return LanguageSelectionWidget(
                          title: APIConstants.getLanNameInAppLang(
                              _languageSelectionController
                                  .getLanguageListBeta()[index]),
                          subTitle: getNativeNameOfLanguage(
                              _languageSelectionController
                                  .getLanguageListBeta()[index]),
                          onItemTap: () => Get.back(
                              result: _languageSelectionController
                                  .getLanguageListBeta()[index]),
                          index: index,
                          selectedIndex: _languageSelectionController
                              .getSelectedBetaLangIndex(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textFormFieldContainer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      padding: EdgeInsets.only(left: 16.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.appTheme.containerColor,
      ),
      child: TextFormField(
        cursorColor: context.appTheme.secondaryTextColor,
        style: regular18Primary(context),
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
        onChanged: (value) {
          performLanguageSearch(value);
        },
        controller: _languageSearchController,
        focusNode: _focusNodeLanguageSearch,
      ),
    );
  }

  Widget _headerWidget() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8).w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  width: 1.w, color: context.appTheme.containerColor),
            ),
            child: SvgPicture.asset(
              iconPrevious,
            ),
          ),
        ),
        SizedBox(width: 24.w),
        Text(
          Get.arguments[kIsSourceLanguage]
              ? kTranslateSourceTitle.tr
              : kTranslateTargetTitle.tr,
          style: semibold24(context),
        ),
      ],
    );
  }

  void performLanguageSearch(String searchString) {
    if (_languageSelectionController.getLanguageListRegular().isEmpty) {
      _languageSelectionController
          .setLanguageListRegular(Get.arguments[kLanguageListRegular]);
    }
    if (searchString.isNotEmpty) {
      isUserSelectedFromSearchResult = true;

      // Search in Regular languages
      List<dynamic> tempList =
          _languageSelectionController.getLanguageListRegular();
      List<dynamic> searchedLanguageList =
          getSearchedLanguageList(tempList, searchString);
      _languageSelectionController.setLanguageListRegular(searchedLanguageList);
      _languageSelectionController.setSelectedRegularLangIndex(null);
      for (var i = 0; i < searchedLanguageList.length; i++) {
        if (searchedLanguageList[i] == Get.arguments[selectedLanguage]) {
          _languageSelectionController.setSelectedRegularLangIndex(i);
        }
      }

      // Search in Beta languages
      tempList = _languageSelectionController.getLanguageListBeta();
      searchedLanguageList = getSearchedLanguageList(tempList, searchString);
      _languageSelectionController.setLanguageListBeta(searchedLanguageList);
      _languageSelectionController.setSelectedBetaLangIndex(null);
      for (var i = 0; i < searchedLanguageList.length; i++) {
        if (searchedLanguageList[i] == Get.arguments[selectedLanguage]) {
          _languageSelectionController.setSelectedBetaLangIndex(i);
        }
      }
    } else {
      setLanguageListFromArgument();
      isUserSelectedFromSearchResult = false;
    }
  }

  List<dynamic> getSearchedLanguageList(
      List<dynamic> languageList, String searchString) {
    List<dynamic> searchedLanguageList = languageList.where(
      (languageCode) {
        String languageNameInEnglish = APIConstants.getLanguageCodeOrName(
            value: languageCode,
            returnWhat: LanguageMap.englishName,
            lang_code_map: APIConstants.LANGUAGE_CODE_MAP);

        return languageNameInEnglish
                .toLowerCase()
                .contains(searchString.toLowerCase()) ||
            getNativeNameOfLanguage(languageCode)
                .toLowerCase()
                .contains(searchString.toLowerCase()) ||
            APIConstants.getLanNameInAppLang(languageCode)
                .contains(searchString);
      },
    ).toList();
    return searchedLanguageList;
  }

  void setLanguageListFromArgument() {
    var regularLangListArgument = Get.arguments[kLanguageListRegular];
    var betaLangListArgument = Get.arguments[kLanguageListBeta];
    if (regularLangListArgument != null && regularLangListArgument.isNotEmpty) {
      _languageSelectionController
          .setLanguageListRegular(regularLangListArgument);
      _languageSelectionController.setSelectedRegularLangIndex(
          _languageSelectionController.getLanguageListRegular().indexWhere(
              (element) => element == Get.arguments[selectedLanguage]));
    }

    if (betaLangListArgument != null && betaLangListArgument.isNotEmpty) {
      _languageSelectionController.setLanguageListBeta(betaLangListArgument);
      _languageSelectionController.setSelectedBetaLangIndex(
          _languageSelectionController.getLanguageListBeta().indexWhere(
              (element) => element == Get.arguments[selectedLanguage]));
    }
  }

  String getNativeNameOfLanguage(String languageCode) {
    return APIConstants.getLanguageCodeOrName(
        value: languageCode,
        returnWhat: LanguageMap.nativeName,
        lang_code_map: APIConstants.LANGUAGE_CODE_MAP);
  }
}
