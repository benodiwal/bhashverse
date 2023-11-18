//common
const introShownAlreadyKey = 'is_intro_shown_already';
const errorRetrievingRecordingFile = 'Error Retrieving recording file';
const recordingFolderName = 'recordings';
const defaultAudioRecordingName = 'ASRAudio';
const defaultTTSPlayName = 'TTSAudio';
const tapAndHoldMinDuration = 600;
const keyboardHideDuration = Duration(milliseconds: 200);
const textCharMaxLength = 500;
const recordingMaxTimeLimit = 30000;
const defaultLangCode = 'en';
const defaultCountry = 'in';
const defaultAnimationTime = Duration(milliseconds: 300);
const feedbackButtonCloseTime = Duration(milliseconds: 450);

// Database name and keys
const hiveDBName = 'db_bhashini';
const preferredVoiceAssistantGender = 'preferred_voice_assistant_gender';
const enableTransliteration = 'enable_transliteration';
const preferredAppLocale = 'preferred_app_locale';
const preferredAppTheme = 'preferred_app_theme';
const isStreamingPreferred = 'is_streaming_preferred';
const preferredSourceLanguage = 'preferred_source_language';
const preferredTargetLanguage = 'preferred_target_language';

const preferredSourceLangTextScreen = 'preferred_source_lang_text_screen';
const preferredTargetLangTextScreen = 'preferred_target_lang_text_screen';

const configCacheKey = 'config_cache_key';
const configCacheLastUpdatedKey = 'config_cache_key_last_updated_key';

const transConfigCacheKey = 'trans_config_cache_key';
const transConfigCacheLastUpdatedKey =
    'trans_config_cache_key_last_updated_key';

const feedbackCacheKey = 'feedback_cache_key';
const feedbackCacheLastUpdatedKey = 'feedback_cache_key_last_updated_key';

// App Assets
const imgAppLogoSmall = 'assets/images/img_app_logo_small.webp';
const imgNoInternet = 'assets/images/common_icon/no_internet.svg';

// Select App Language Screen
const imgEnglish = 'assets/images/app_language_img/img_english.png';
const imgHindi = 'assets/images/app_language_img/img_hindi.png';
const imgMarathi = 'assets/images/app_language_img/img_marathi.png';
const imgPunjabi = 'assets/images/app_language_img/img_punjabi.png';
const imgBengali = 'assets/images/app_language_img/img_bengali.png';
const imgTamil = 'assets/images/app_language_img/img_tamil.png';
const imgKannada = 'assets/images/app_language_img/img_kannada.png';

// Onboarding screen
const imgOnboarding1 =
    'assets/images/onboarding_image/img_illustration_onboarding_1.webp';
const imgOnboarding2 =
    'assets/images/onboarding_image/img_illustration_onboarding_2.webp';
const imgOnboarding3 =
    'assets/images/onboarding_image/img_illustration_onboarding_3.webp';
const imgOnboarding4 =
    'assets/images/onboarding_image/img_illustration_onboarding_4.webp';
const iconPrevious = 'assets/images/common_icon/icon_arrow_left.svg';

// Voice Assistant Screen
const imgMaleAvatar = 'assets/images/img_male_avatar.webp';
const imgFemaleAvatar = 'assets/images/img_female_avatar.webp';

//Home Screen
const imgVoiceSpeaking = 'assets/images/menu_images/img_voice_speaking.webp';
const imgVideo = 'assets/images/menu_images/img_video.webp';
const linkImage = 'assets/images/menu_images/img_link.webp';
const imgText = 'assets/images/menu_images/img_text.webp';
const imgImages = 'assets/images/menu_images/img_images.webp';
const imgDocuments = 'assets/images/menu_images/img_documents.webp';
const imgMic = 'assets/images/menu_images/img_mic.webp';
const iconSettings = 'assets/images/common_icon/icon_settings.svg';

// Setting Screen
const iconArrowDown = 'assets/images/common_icon/icon_arrow_down.svg';
const iconSelectedRadio =
    'assets/images/common_icon/icon_selected_radio_button.svg';
const iconUnSelectedRadio =
    'assets/images/common_icon/icon_unselected_radio_button.svg';

// Translation Screen
const textFieldRadius = 16.0;
const iconArrowSwapHorizontal =
    'assets/images/common_icon/icon_arrow_swap_horizontal.svg';
const iconMicroPhone = 'assets/images/common_icon/icon_microphone.svg';
const iconListening = 'assets/images/common_icon/icon_listening.svg';
const iconClipBoardText = 'assets/images/common_icon/icon_clipboard_text.svg';
const iconCopy = 'assets/images/common_icon/icon_copy.svg';
const iconShare = 'assets/images/common_icon/icon_share.svg';
const iconSound = 'assets/images/common_icon/icon_sound.svg';
const iconStopPlayback = 'assets/images/common_icon/icon_stop_playback.svg';
const iconMicStop = 'assets/images/common_icon/icon_mic_stop.svg';
const iconDownArrow = 'assets/images/common_icon/icon_down_arrow.svg';
const iconLikeDislike = 'assets/images/common_icon/icon_like_dislike.svg';
const animationHomeLoading =
    'assets/animation/lottie_animation/animation_home_loading.json';
const animationLoadingLine =
    'assets/animation/lottie_animation/loading_line_animation.json';
const animationTranslationLoading =
    'assets/animation/lottie_animation/animation_translation_loading.json';
const animationStaticWaveForRecording =
    'assets/animation/lottie_animation/voice-line-wave-animation.json';
const kLanguageListRegular = 'language_list_regular';
const kLanguageListBeta = 'language_list_beta';
const kIsSourceLanguage = 'is_source_language';
const selectedLanguage = 'selectedLanguage';
