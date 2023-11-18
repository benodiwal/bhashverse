import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/common_app_bar.dart';
import '../../localization/localization_keys.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/theme/app_theme_provider.dart';
import '../../utils/theme/app_text_style.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16).w,
          child: Column(
            children: [
              SizedBox(height: 20.w),
              CommonAppBar(title: bhashiniTitle.tr, showBackButton: false),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(imgNoInternet),
                    SizedBox(height: 16.w),
                    Text(
                      errorNoInternetTitle.tr,
                      style: bold24(context),
                    ),
                    SizedBox(height: 12.w),
                    Text(
                      errorNoInternetSubTitle.tr,
                      style: regular16(context)
                          .copyWith(color: context.appTheme.disabledTextColor),
                    ),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
