import 'dart:math' show pi;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/common_app_bar.dart';
import '../../enums/gender_enum.dart';
import '../../localization/localization_keys.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import 'controller/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late SettingsController _settingsController;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _settingsController = Get.find();

    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        backgroundColor: context.appTheme.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.h),
                  CommonAppBar(
                      title: kSettings.tr,
                      onBackPress: () async => _onWillPop()),
                  SizedBox(height: 36.h),
                  _settingHeading(
                    action: _popupMenuBuilder(),
                    title: appTheme.tr,
                    subtitle: appInterfaceWillChange.tr,
                  ),
                  SizedBox(height: 20.w),
                  Obx(
                    () => InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.appLanguageRoute, arguments: {
                          selectedLanguage:
                              _settingsController.preferredLanguage.value,
                        })?.then(
                            (_) => _settingsController.getPreferredLanguage());
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: _settingHeading(
                        action: Row(
                          children: [
                            Text(
                              _settingsController.preferredLanguage.value,
                              style: regular14(context),
                            ),
                            SizedBox(width: 8.w),
                            RotatedBox(
                              quarterTurns: 3,
                              child: SvgPicture.asset(iconArrowDown,
                                  color: context.appTheme.highlightedTextColor),
                            ),
                          ],
                        ),
                        title: appLanguage.tr,
                        subtitle: appInterfaceWillChangeInSelected.tr,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.w),
                  _voiceAssistantTileWidget(),
                  SizedBox(height: 20.w),
                  _settingHeading(
                    action: Obx(
                      () => CupertinoSwitch(
                        value:
                            _settingsController.isTransLiterationEnabled.value,
                        activeColor: context.appTheme.highlightedBorderColor,
                        trackColor: context.appTheme.disabledBGColor,
                        onChanged: (value) => _settingsController
                            .changeTransliterationPref(value),
                      ),
                    ),
                    title: transLiteration.tr,
                    subtitle: transLiterationWillInitiateWord.tr,
                  ),
                  SizedBox(height: 20.w),
                  Obx(
                    () => _expandableSettingHeading(
                        title: advanceSettings.tr,
                        isExpanded:
                            _settingsController.isAdvanceMenuOpened.value,
                        onTitleClick: () {
                          _settingsController.isAdvanceMenuOpened.value =
                              !_settingsController.isAdvanceMenuOpened.value;
                          _settingsController.isAdvanceMenuOpened.value
                              ? _controller.forward()
                              : _controller.reverse();
                        },
                        child: AnimatedCrossFade(
                          duration: defaultAnimationTime,
                          crossFadeState:
                              _settingsController.isAdvanceMenuOpened.value
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                          firstChild: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Flexible(child: Divider()),
                              Flexible(
                                child: Row(
                                  children: [
                                    Text(
                                      realTimeResponse.tr,
                                      style: regular18Primary(context).copyWith(
                                        fontSize: 18.sp,
                                        color:
                                            context.appTheme.primaryTextColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    Obx(
                                      () => CupertinoSwitch(
                                        value: _settingsController
                                            .isStreamingEnabled.value,
                                        activeColor: context
                                            .appTheme.highlightedBorderColor,
                                        trackColor:
                                            context.appTheme.disabledBGColor,
                                        onChanged: (value) {
                                          _settingsController
                                              .changeStreamingPref(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                _settingsController.isAdvanceMenuOpened.value
                                    ? realTimeResponseInfo.tr
                                    : '',
                                style: regular14(context).copyWith(
                                  color: context.appTheme.secondaryTextColor,
                                ),
                              ),
                              SizedBox(height: 14.w),
                            ],
                          ),
                          secondChild: const SizedBox.shrink(),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingHeading({
    required String title,
    required Widget action,
    String? subtitle,
    Widget? child,
    double? height,
  }) {
    return AnimatedContainer(
      duration: defaultAnimationTime,
      padding: const EdgeInsets.all(12).w,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1.w,
            color: context.appTheme.containerColor,
          ),
          color: context.appTheme.cardBGColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: regular17Primary(context),
                ),
              ),
              const Spacer(),
              action,
            ],
          ),
          if (subtitle != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 14.h),
                Text(
                  subtitle,
                  style: secondary13(context).copyWith(),
                ),
              ],
            ),
          if (child != null) Expanded(child: child),
        ],
      ),
    );
  }

  Widget _expandableSettingHeading({
    required String title,
    required Function onTitleClick,
    required bool isExpanded,
    Widget? child,
  }) {
    return AnimatedContainer(
      duration: defaultAnimationTime,
      padding: EdgeInsets.only(top: 10.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1.w,
            color: context.appTheme.containerColor,
          ),
          color: context.appTheme.cardBGColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => onTitleClick(),
            child: Row(
              children: [
                Text(
                  title,
                  style: regular16(context).copyWith(
                    color: context.appTheme.primaryTextColor,
                  ),
                ),
                const Spacer(),
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
          SizedBox(height: isExpanded ? 6.h : 12.h),
          if (child != null) Flexible(child: child),
        ],
      ),
    );
  }

  Widget _voiceAssistantTileWidget() {
    return Container(
      padding: const EdgeInsets.all(12).w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 1.w,
            color: context.appTheme.containerColor,
          ),
          color: context.appTheme.cardBGColor),
      child: Row(
        children: [
          Expanded(
            child: Text(
              voiceAssistant.tr,
              style: regular16(context).copyWith(
                color: context.appTheme.primaryTextColor,
              ),
            ),
          ),
          _radioWidgetBuilder(
            GenderEnum.male,
            male.tr,
          ),
          SizedBox(width: 8.w),
          _radioWidgetBuilder(
            GenderEnum.female,
            female.tr,
          ),
        ],
      ),
    );
  }

  Widget _radioWidgetBuilder(
    GenderEnum currentGender,
    String title,
  ) {
    return Obx(
      () => InkWell(
        onTap: () =>
            _settingsController.changeVoiceAssistantPref(currentGender),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.w,
              color: (_settingsController.preferredVoiceAssistant.value ==
                      currentGender)
                  ? context.appTheme.highlightedBorderColor
                  : context.appTheme.secondaryTextColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          child: Row(
            children: <Widget>[
              Icon(
                (_settingsController.preferredVoiceAssistant.value ==
                        currentGender)
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off,
                color: (_settingsController.preferredVoiceAssistant.value ==
                        currentGender)
                    ? context.appTheme.highlightedBorderColor
                    : context.appTheme.secondaryTextColor,
              ),
              SizedBox(width: 5.w),
              Text(
                title,
                style: secondary14(context).copyWith(
                  color: (_settingsController.preferredVoiceAssistant.value ==
                          currentGender)
                      ? context.appTheme.highlightedBorderColor
                      : context.appTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popupMenuBuilder() {
    return Obx(
      () => PopupMenuButton(
        onSelected: (value) {
          Provider.of<AppThemeProvider>(context, listen: false)
              .setAppTheme(value);
          _settingsController.selectedThemeMode.value = value;
        },
        child: Row(
          children: [
            Text(
              _getThemeModeName(_settingsController.selectedThemeMode.value),
              style: regular14(context),
            ),
            SizedBox(width: 8.w),
            SvgPicture.asset(iconArrowDown,
                color: context.appTheme.highlightedTextColor),
          ],
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: ThemeMode.light,
            child: Text(light.tr),
          ),
          PopupMenuItem(
            value: ThemeMode.dark,
            child: Text(dark.tr),
          ),
          PopupMenuItem(
            value: ThemeMode.system,
            child: Text(systemDefault.tr),
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return systemDefault.tr;
      case ThemeMode.light:
        return light.tr;
      case ThemeMode.dark:
        return dark.tr;
    }
  }

  Future<bool> _onWillPop() async {
    Get.back();
    return Future.value(false);
  }
}
