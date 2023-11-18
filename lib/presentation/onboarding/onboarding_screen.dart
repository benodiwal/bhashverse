import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/custom_elevated_button.dart';
import '../../localization/localization_keys.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/remove_glow_effect.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';
import 'controller/onboarding_controller.dart';
import 'data/onboarding_data.dart';
import 'widgets/indicator.dart';
import 'widgets/onboarding_content.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late OnboardingController _onboardingController;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _onboardingController = Get.put(OnboardingController());
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _onboardingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16).w,
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _headerWidget(),
                SizedBox(height: 16.h),
                _pageViewBuilder(),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    OnboardingData.onboardingPages.length,
                    (index) => IndicatorWidget(
                      currentIndex: _onboardingController.getCurrentPageIndex(),
                      indicatorIndex: index,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                CustomElevatedButton(
                  buttonText: (_onboardingController.getCurrentPageIndex() ==
                          OnboardingData.onboardingPages.length - 1)
                      ? getStarted.tr
                      : next.tr,
                  backgroundColor: context.appTheme.primaryColor,
                  borderRadius: 16,
                  onButtonTap: (_onboardingController.getCurrentPageIndex() ==
                          OnboardingData.onboardingPages.length - 1)
                      ? () => Get.offNamed(AppRoutes.voiceAssistantRoute)
                      : () {
                          _pageController?.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut);
                        },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerWidget() {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: (_onboardingController.getCurrentPageIndex() == 0)
              ? () => Get.back()
              : () {
                  _pageController?.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                },
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
        const Spacer(),
        Visibility(
          visible: (_onboardingController.getCurrentPageIndex() ==
                  OnboardingData.onboardingPages.length - 1)
              ? false
              : true,
          child: InkWell(
            onTap: () => Get.offNamed(AppRoutes.voiceAssistantRoute),
            child: Text(
              skip.tr,
              style: regular14(context).copyWith(
                color: context.appTheme.highlightedBGColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pageViewBuilder() {
    return Expanded(
      child: ScrollConfiguration(
        behavior: RemoveScrollingGlowEffect(),
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (index) {
            _onboardingController.setCurrentPageIndex(index);
          },
          itemCount: OnboardingData.onboardingPages.length,
          itemBuilder: (context, index) {
            return OnBoardingContentWidget(
                image: OnboardingData.onboardingPages[index].imageWidget,
                headerText: OnboardingData.onboardingPages[index].headerText,
                bodyText: OnboardingData.onboardingPages[index].bodyText);
          },
        ),
      ),
    );
  }
}
