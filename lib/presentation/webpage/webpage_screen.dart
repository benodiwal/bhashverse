import 'package:bhashverse/common/widgets/common_app_bar.dart';
import 'package:bhashverse/localization/localization_keys.dart';
import 'package:bhashverse/presentation/webpage/controller/webpage_controller.dart';
import 'package:bhashverse/routes/app_routes.dart';
import 'package:bhashverse/utils/constants/app_constants.dart';
import 'package:bhashverse/utils/theme/app_text_style.dart';
import 'package:bhashverse/utils/theme/app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    "Select a language in which you want to translate the WebPage: ".tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: context.appTheme.backgroundColor,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                      value: selectedLanguage,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
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

  void _generateWebPage() async {
    String url = _textController.urlController.text;
    if (url.isNotEmpty) {
      Get.toNamed(AppRoutes.webViewRoute, arguments: {
        'url': url,
        'language': selectedLanguage,
      });
    }
  }
}
