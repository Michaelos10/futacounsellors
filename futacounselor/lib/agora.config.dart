import 'package:agora_rtc_engine_example/components/config_override.dart';

/// Get your own App ID at https://dashboard.agora.io/
String get appId {
  // You can directly edit this code to return the appId you want.
  return "7c5d049ea75a48c8a9a0d2d44efbe0a3";
}

/// Please refer to https://docs.agora.io/en/Agora%20Platform/token
String get token {
  // You can directly edit this code to return the token you want.
  return ""; //"007eJxTYKhOvPT32XypyhS/PaYLHjQYL4uYXCaQkRJpvnjm/2vW39wVGCxSDMyNUlNTEs1M0kySzI0tDdNSjU0MDSwSTZMsjS1M88/bpTcEMjKUPA9gYWSAQBCfhaEktbiEgQEAodQgbg==";
}

/// Your channel ID
// String get channelId {
//   // You can directly edit this code to return the channel ID you want.
//   return "test";
// }

/// Your int user ID
const int uid = 0;

/// Your user ID for the screen sharing
const int screenSharingUid = 10;

/// Your string user ID
const String stringUid = '0';

String get musicCenterAppId {
  // Allow pass a `token` as an environment variable with name `TEST_TOKEN` by using --dart-define
  return const String.fromEnvironment('MUSIC_CENTER_APPID',
      defaultValue: '<MUSIC_CENTER_APPID>');
}
