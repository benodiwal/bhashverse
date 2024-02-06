# Bhashaverse

A Speech to Speech Application build using Flutter which leverages the Indian Languages AI/ML models offered by Government of India under the ambitious project called [Bhashini](www.bhashini.gov.in).

## Getting Started
Follow the below steps to successfully run this Flutter application:

- Create a new Flutter project using command

```shell-script
 	flutter create --org com.xxxx <<folder_name>> --project-name <<project_name>>
```

- Download the `assets` and `lib` folder and paste them in the project root

## Edit `pubspec.yaml` file
Add following dependencies/properties in _pubspec.yaml_ file:

* Project Name:
```yaml
name: bhashaverse
```

* Dependencies:
```yaml
 cupertino_icons: ^1.0.2
  get: ^4.6.5
  dio: ^4.0.6
  provider: ^6.0.5
  permission_handler: ^10.2.0
  path_provider: ^2.0.12
  connectivity_plus: ^3.0.5
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  freezed: ^2.3.2
  freezed_annotation: ^2.2.0
  json_serializable: ^6.5.4
  flutter_svg: ^1.1.6
  google_fonts: ^4.0.4
  avatar_glow: ^2.0.2
  http: ^1.1.0
  lottie: ^2.1.0
  webview_flutter: ^4.4.2
  share_plus: ^6.3.0
  audio_waveforms: ^1.0.0
  socket_io_client: ^2.0.1
  record: ^4.4.4
  auto_size_text: ^3.0.0
  vibration: ^1.7.6
  stop_watch_timer: ^2.0.0
  custom_rating_bar: ^2.0.5
  flutter_screenutil: ^5.8.4
  sound_stream:
     git:
      url: https://github.com/JHM69/flutter-sound-stream.git
  html: ^0.15.4
  uno: ^1.1.9
  rename_app: ^1.3.1
```

* Dev Dependencies:
```yaml
  build_runner: ^2.3.3
  flutter_launcher_icons: ^0.11.0
```

* App icon:
```yaml
flutter_icons:
  android: "launcher_icon"
  ios: true
  remove_alpha_ios: true
  image_path: "assets/images/img_app_logo_full.png"
  web:
    generate: true
    image_path: "assets/images/img_app_logo_full.png"
  windows:
    generate: true
    image_path: "assets/images/img_app_logo_full.png"
    icon_size: 48 # min:48, max:256, default: 48
  macos:
    generate: true
    image_path: "assets/images/img_app_logo_full.png"
```

* Assets path:
```yaml
  assets:
    - assets/google_fonts/
    - assets/images/
    - assets/images/app_language_img/
    - assets/images/common_icon/
    - assets/images/onboarding_image/
    - assets/images/menu_images/
    - assets/animation/lottie_animation/
```

- Enter the terminal and execute following commands:

    - flutter clean
    - flutter pub get
    - flutter pub run build_runner build --delete-conflicting-outputs
    - flutter pub run flutter_launcher_icons:main
    
------------

### Steps for Android

- Set minimum SDK version to 21 or higher in `android/app/build.gradle`

- Set target SDK version and compile SDK version to 33 or higher in `android/app/build.gradle`

- Open the `android/app/src/main/AndroidManifest.xml` file and add following permissions:

```xml
     <uses-permission android:name="android.permission.INTERNET"/>
     <uses-permission android:name="android.permission.RECORD_AUDIO" />
     <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
     <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
     <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
     <uses-permission android:name="android.permission.VIBRATE"/>
```

### Steps for iOS

- Open `Info.plist` and add following permission:

```xml
     <key>NSMicrophoneUsageDescription</key>
     <string>App need Microphone permission to enable Speech translation</string>
```
- Open `ios/Podfile`  and update post_install code as shown below this:


```ruby
   post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_additional_ios_build_settings(target)
      target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
          '$(inherited)',

          ## dart: PermissionGroup.calendar
          'PERMISSION_EVENTS=0',

          ## dart: PermissionGroup.reminders
          'PERMISSION_REMINDERS=0',

          ## dart: PermissionGroup.contacts
          'PERMISSION_CONTACTS=0',

          ## dart: PermissionGroup.camera
          'PERMISSION_CAMERA=0',
            
          ## dart: PermissionGroup.microphone
          'PERMISSION_MICROPHONE=1',
          
          ## dart: PermissionGroup.speech
          'PERMISSION_SPEECH_RECOGNIZER=0',

          ## dart: PermissionGroup.photos
          'PERMISSION_PHOTOS=0',

          ## dart: [PermissionGroup.location, PermissionGroup.locationAlways, PermissionGroup.locationWhenInUse]
          'PERMISSION_LOCATION=0',
        
          ## dart: PermissionGroup.notification
          'PERMISSION_NOTIFICATIONS=0',

          ## dart: PermissionGroup.mediaLibrary
          'PERMISSION_MEDIA_LIBRARY=0',

          ## dart: PermissionGroup.sensors
          'PERMISSION_SENSORS=0',

          ## dart: PermissionGroup.bluetooth
          'PERMISSION_BLUETOOTH=0',

          ## dart: PermissionGroup.appTrackingTransparency
          'PERMISSION_APP_TRACKING_TRANSPARENCY=0',

          ## dart: PermissionGroup.criticalAlerts
          'PERMISSION_CRITICAL_ALERTS=0',

            ]
        end
    end
end
```

- Enter the following commands in terminal:

    - cd ios
    - pod update

------------

- Run the project on emulator or physical device with following command (replace placeholders with appropriate values) :

```shell-script
flutter run --debug --dart-define userID=<ADD_USER_ID> --dart-define ulcaApiKey=<ADD_ULCA_API_KEY> --dart-define authorization=<ADD_AUTHORIZATION_KEY>
```

- You can also build apk/appbundle/ipa file with following command:

```shell-script
flutter build apk/appbundle/ipa --release --obfuscate --split-debug-info=<PATH_WHERE_DEBUG_INFO_CAN_BE_SAVED> --dart-define userID=<ADD_USER_ID> --dart-define ulcaApiKey=<ADD_ULCA_API_KEY> --dart-define authorization=<ADD_AUTHORIZATION_KEY>
```

------------

### launch.json file for VS Code (Optional)

If you don't want to supply dart-define parameters every time when building the project, Add launch.json file.
To do that, create .vscode folder inside root directory of the project. Then create launch.json file and paste below details inside it. Please replace userID and other required keys which you have obtained for authorization.

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "bhashaverse",
            "request": "launch",
            "type": "dart",
            "args": [
                "--dart-define",
                "userID=<ADD_USER_ID>",
                "--dart-define",
                "ulcaApiKey=<ADD_ULCA_API_KEY>",
                "--dart-define",
                "authorization=<ADD_AUTHORIZATION_KEY>",
            ]
        },
        {
            "name": "bhashaverse (profile mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "profile",
            "args": [
                "--dart-define",
                "userID=<ADD_USER_ID>",
                "--dart-define",
                "ulcaApiKey=<ADD_ULCA_API_KEY>",
                "--dart-define",
                "authorization=<ADD_AUTHORIZATION_KEY>",
            ]
        },
        {
            "name": "bhashaverse (release mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "release",
            "args": [
                "--dart-define",
                "userID=<ADD_USER_ID>",
                "--dart-define",
                "ulcaApiKey=<ADD_ULCA_API_KEY>",
                "--dart-define",
                "authorization=<ADD_AUTHORIZATION_KEY>",
            ]
        }
    ]
}
```
