import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../localization/localization_keys.dart';
import '../../../models/home_menu_model.dart';
import '../../../utils/constants/app_constants.dart';

class HomeData {
  static final List<HomeMenuModel> menuItems = [
    HomeMenuModel(
        name: text.tr, imageWidget: Image.asset(imgText), isDisabled: false),
    HomeMenuModel(
        name: converse.tr,
        imageWidget: Image.asset(imgVoiceSpeaking),
        isDisabled: false),
    HomeMenuModel(
        name: voice.tr, imageWidget: Image.asset(imgMic), isDisabled: false),
    HomeMenuModel(name: link.tr, imageWidget: Image.asset(linkImage), isDisabled: false),
    // HomeMenuModel(name: video.tr, preCachedImage: Image.asset(imgVideo), isDisabled: true),
    // HomeMenuModel(
    //     name: documents.tr, preCachedImage: Image.asset(imgDocuments), isDisabled: true),
    // HomeMenuModel(name: images.tr, preCachedImage: Image.asset(imgImages), isDisabled: true),
  ];
}
