import 'package:bhashaverse/common/widgets/common_app_bar.dart';
import 'package:bhashaverse/localization/localization_keys.dart';
import 'package:bhashaverse/presentation/webpage/controller/webpage_controller.dart';
import 'package:bhashaverse/routes/app_routes.dart';
import 'package:bhashaverse/utils/constants/app_constants.dart';
import 'package:bhashaverse/utils/snackbar_utils.dart';
import 'package:bhashaverse/utils/theme/app_text_style.dart';
import 'package:bhashaverse/utils/theme/app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WebpageScreen extends StatefulWidget {
  const WebpageScreen({super.key});

  @override
  State<WebpageScreen> createState() => _WebpageScreenState();
}

class _WebpageScreenState extends State<WebpageScreen> {
  late WebpageController _textController;
  final FocusNode _urlFocusNode = FocusNode();
  late bool isLoading;
  bool isWebPageVisible = false;
  String selectedLanguage = "en";

  @override
  void initState() {
    _textController = Get.find();
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return tablet(context);
      } else {
        return defult(context);
      }
    });
  }

  Widget defult(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).w,
              child: Column(
                children: [
                  SizedBox(
                    height: 16.h,
                  ),
                  CommonAppBar(
                    title: browse.tr,
                    onBackPress: () => Get.back(),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Container(
                    margin: const EdgeInsets.all(14).w,
                    height: 120.h,
                    decoration: BoxDecoration(
                        color: context.appTheme.normalTextFieldColor,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(textFieldRadius)),
                        border: Border.all(
                            color: context.appTheme.disabledBGColor)),
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 16.w),
                        child: _buildUrlInputTextField()),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  // ElevatedButton(
                  //     onPressed: _pasteFromClipboard,
                  //     child: const Text("Paste")),
                  // SizedBox(
                  //   height: 14.h,
                  // ),
                  Text(
                    "Translate to:".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appTheme.titleTextColor,
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16, right: 4, top: 1, bottom: 1),
                    decoration: BoxDecoration(
                      color: context.appTheme.backgroundColor,
                      border: Border.all(color: context.appTheme.textFieldBorderColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                        value: selectedLanguage,
                        style:
                            TextStyle(color: context.appTheme.titleTextColor, fontSize: 18),
                        underline: Container(
                          height: 0,
                          color: Colors.transparent,
                        ),
                        iconSize: 36,
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'hi',
                            child: Text('Hindi'),
                          ),
                          DropdownMenuItem(
                            value: 'ta',
                            child: Text('Tamil'),
                          ),
                          DropdownMenuItem(
                            value: 'te',
                            child: Text('Telugu'),
                          ),
                          DropdownMenuItem(
                            value: 'ml',
                            child: Text('Malayalam'),
                          ),
                          DropdownMenuItem(
                            value: 'mr',
                            child: Text('Marathi'),
                          ),
                          DropdownMenuItem(
                            value: 'bn',
                            child: Text('Bengali'),
                          ),
                          DropdownMenuItem(
                            value: 'as',
                            child: Text('Assamese'),
                          ),
                          DropdownMenuItem(
                            value: 'gu',
                            child: Text('Gujarati'),
                          ),
                          DropdownMenuItem(
                            value: 'kn',
                            child: Text('Kannada'),
                          ),
                          DropdownMenuItem(
                            value: 'or',
                            child: Text('Odia'),
                          ),
                          DropdownMenuItem(
                            value: 'pa',
                            child: Text('Punjabi'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value!;
                          });
                        }),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  ElevatedButton(
                      onPressed: _generateWebPage,
                      child: const Text("Generate Web Page")),
                  SizedBox(
                    height: 12.h,
                  ),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  SizedBox(
                    height: 10.h,
                  ),
                  if (isLoading)
                    const Text(
                      "Generating web page",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white,
                      ),
                    ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 1.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Developed by",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 8.0,
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    child: Image.asset(
                                      'assets/images/sst-logo.png',
                                      height: 15,
                                      width: 57,
                                      fit: BoxFit.contain,
                                    ))
                              ],
                            ),
                          ))),
                  SizedBox(
                    height: 17.h,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tablet(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14).w,
              child: Column(
                children: [
                  SizedBox(
                    height: 16.h,
                  ),
                  CommonAppBar(
                    title: browse.tr,
                    onBackPress: () => Get.back(),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  Container(
                    margin: const EdgeInsets.all(14).w,
                    height: 120.h,
                    decoration: BoxDecoration(
                        color: context.appTheme.normalTextFieldColor,
                        borderRadius: const BorderRadius.all(
                            Radius.circular(textFieldRadius)),
                        border: Border.all(
                            color: context.appTheme.disabledBGColor)),
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.h, horizontal: 16.w),
                        child: _buildUrlInputTextField()),
                  ),
                  SizedBox(
                    height: 8.h,
                  ),
                  // ElevatedButton(
                  //     onPressed: _pasteFromClipboard,
                  //     child: const Text("Paste")),
                  // SizedBox(
                  //   height: 14.h,
                  // ),
                  Text(
                    "Translate to:".tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 16, right: 4, top: 1, bottom: 1),
                    decoration: BoxDecoration(
                      color: context.appTheme.backgroundColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                        value: selectedLanguage,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 30),
                        underline: Container(
                          height: 0,
                          color: Colors.transparent,
                        ),
                        iconSize: 44,
                        items: const [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'hi',
                            child: Text('Hindi'),
                          ),
                          DropdownMenuItem(
                            value: 'ta',
                            child: Text('Tamil'),
                          ),
                          DropdownMenuItem(
                            value: 'te',
                            child: Text('Telugu'),
                          ),
                          DropdownMenuItem(
                            value: 'ml',
                            child: Text('Malayalam'),
                          ),
                          DropdownMenuItem(
                            value: 'mr',
                            child: Text('Marathi'),
                          ),
                          DropdownMenuItem(
                            value: 'bn',
                            child: Text('Bengali'),
                          ),
                          DropdownMenuItem(
                            value: 'as',
                            child: Text('Assamese'),
                          ),
                          DropdownMenuItem(
                            value: 'gu',
                            child: Text('Gujarati'),
                          ),
                          DropdownMenuItem(
                            value: 'kn',
                            child: Text('Kannada'),
                          ),
                          DropdownMenuItem(
                            value: 'or',
                            child: Text('Odia'),
                          ),
                          DropdownMenuItem(
                            value: 'pa',
                            child: Text('Punjabi'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value!;
                          });
                        }),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  ElevatedButton(
                    onPressed: _generateWebPage,
                    child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 18.0),
                        child: Text(
                          "Generate Web Page",
                          style: TextStyle(fontSize: 22.0),
                        )),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  SizedBox(
                    height: 10.h,
                  ),
                  if (isLoading)
                    const Text(
                      "Generating web page",
                      style: TextStyle(
                        fontSize: 27.0,
                        color: Colors.white,
                      ),
                    ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 2.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Developed by",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16.0,
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Image.asset(
                                      'assets/images/sst-logo.png',
                                      height: 30,
                                      width: 110,
                                      fit: BoxFit.contain,
                                    ))
                              ],
                            ),
                          ))),
                  SizedBox(
                    height: 17.h,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInputTextField() {
    return TextField(
      controller: _textController.urlController,
      focusNode: _urlFocusNode,
      style: regular18Primary(context),
      maxLines: null,
      expands: false,
      maxLength: textCharMaxLength,
      autocorrect: false,
      decoration: InputDecoration(
          hintText: "Write or paste the url here ...",
          hintStyle: regular18Primary(context)
              .copyWith(color: context.appTheme.hintTextColor),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          counterText: ''),
    );
  }

  // void _pasteFromClipboard() async {
  //   ClipboardData? clipboardData =
  //       await Clipboard.getData(Clipboard.kTextPlain);
  //   if (clipboardData != null) {
  //     setState(() {
  //       _textController.urlController.text = clipboardData.text ?? '';
  //     });
  //   }
  // }

//  void _generateWebPage() async {
//   String url = _textController.urlController.text.trim().toLowerCase(); // Remove leading/trailing spaces
  
//   if (url.isEmpty) {
//     showDefaultSnackbar(
//         message: "URL can't be empty. Please enter a valid URL");
//     return;
//   }

//   RegExp urlPattern = RegExp(
//       r'^(https?|ftp)://[^\s/$.?#].[^\s]*$');

//   if (!urlPattern.hasMatch(url)) {
//     showDefaultSnackbar(
//         message: "Invalid URL format. Please enter a valid URL");
//     return;
//   }

//   if (!url.startsWith('http://') && !url.startsWith('https://')) {
//     url = 'https://$url';
//   }

//   Get.toNamed(AppRoutes.webViewRoute, arguments: {
//     'url': url,
//     'language': selectedLanguage,
//   });
// }


void _generateWebPage() async {
  String url = _textController.urlController.text.trim().toLowerCase(); // Convert URL to lowercase

  if (url.isEmpty) {
    showDefaultSnackbar(
        message: "URL can't be empty. Please enter a valid URL");
    return;
  }

  RegExp urlPattern = RegExp(
      r'^(https?|ftp)://[^\s/$.?#].[^\s]*$');

  if (!urlPattern.hasMatch(url)) {
    RegExp domainPattern = RegExp(
        r'^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$');
    if (!domainPattern.hasMatch(url)) {
      showDefaultSnackbar(
          message: "Invalid URL format. Please enter a valid URL");
      return;
    } else {
      url = 'https://$url';
    }
  }

  Get.toNamed(AppRoutes.webViewRoute, arguments: {
    'url': url,
    'language': selectedLanguage,
  });
}

}