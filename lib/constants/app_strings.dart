import 'strings_es.dart';
import 'strings_en.dart';
import 'strings_ca.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'es': stringsEs,
    'en': stringsEn,
    'ca': stringsCa,
  };

  static String get(String key, String lang) {
    return _strings[lang]?[key] ?? _strings['es']?[key] ?? key;
  }
}
