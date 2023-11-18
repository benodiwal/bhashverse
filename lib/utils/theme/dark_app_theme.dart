part of app_theme;

class DarkAppTheme implements AppTheme {
  const DarkAppTheme();

  @override
  Color get backgroundColor => _AppColors.jaguarBlack;

  @override
  Color get buttonSelectedColor => _AppColors.tangerineOrangeColor;

  @override
  Color get containerColor => _AppColors.jaguarBlue;

  @override
  Color get disabledBGColor => _AppColors.americanSilver.withOpacity(0.1);

  @override
  Color get disabledTextColor => _AppColors.americanSilver;

  @override
  Color get errorColor => _AppColors.brickRed;

  @override
  Color get highlightedBGColor => _AppColors.japaneseLaurel;

  @override
  Color get textFieldBorderColor => _AppColors.magicMint.withOpacity(0.1);

  @override
  Color get highlightedTextColor => _AppColors.mischkaGrey;

  @override
  Color get hintTextColor => _AppColors.mischkaGrey;

  @override
  Color get lightBGColor => _AppColors.bastilleBlack;

  @override
  Color get orangeBGColor => _AppColors.bisqueOrangeColor;

  @override
  Color get primaryColor => _AppColors.primaryDarkColor;

  @override
  Color get primaryTextColor => _AppColors.ghostWhite;

  @override
  Color get readOnlyTextColor => _AppColors.lilyGrey;

  @override
  Color get secondaryTextColor => _AppColors.manateeGray;

  @override
  Color get titleTextColor => _AppColors.manateeGray;

  @override
  Color get transliterationTextColor => _AppColors.lilyWhite;

  @override
  Color get warningColor => _AppColors.frolyRed;

  @override
  Color get disabledOrangeColor => _AppColors.flushOrangeColor;

  @override
  Color get cardBGColor => _AppColors.bastilleBlack;

  @override
  Color get highlightedTextFieldColor => _AppColors.magicMint.withOpacity(0.1);

  @override
  Color get normalTextFieldColor => _AppColors.jaguarBlue;

  @override
  Color get iconOutlineColor => _AppColors.balticSea;

  @override
  Color get disabledIconOutlineColor => _AppColors.brightGrey;

  @override
  Color get highlightedBorderColor => _AppColors.primaryDarkColor;

  @override
  Color get listingScreenBGColor => _AppColors.jaguarBlack;

  @override
  Color get speakerColor => _AppColors.haitiBlack;

  @override
  Color get voiceAssistantBGColor => _AppColors.bastilleBlack;

  @override
  Color get splashScreenBGColor => _AppColors.jaguarBlack;

  @override
  Color get feedbackIconColor => _AppColors.seaGreen;

  @override
  Color get feedbackIconClosedColor => _AppColors.silverTree;

  @override
  Color get feedbackTextColor => _AppColors.darkSpringGreen;

  @override
  Color get feedbackBGColor => _AppColors.whiteIce;
}
