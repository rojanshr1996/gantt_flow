import 'package:gantt_mobile/base/utilities.dart';

class ResultMap {
  final Map map;
  ResultMap(this.map);
  dynamic get(String key) => map[key];
  String getString(String key) => map[key]?.toString() ?? "";
  String getStringWithFallback(String key, String fallback) => map[key]?.toString() ?? fallback;
  List getList(String key) => map[key];
  double getDouble(String key) => double.parse(getStringWithFallback(key, "0"));
  int getInt(String key) => int.parse(getStringWithFallback(key, "0"));
  bool getBool(String key) => getString(key) == "1" || getString(key) == "true";
}

// JSON Parsing model for Authenticated google users
class AuthGoogleUser {
  final String id;
  final String displayName;
  final String email;
  final String photoUrl;

  AuthGoogleUser.fromResult(ResultMap item)
      : id = item.getString("id"),
        displayName = item.getString("display_name"),
        email = item.getString("email"),
        photoUrl = item.getString("photo_url");

  static AuthGoogleUser init() => AuthGoogleUser.fromJson({});
  static AuthGoogleUser fromJson(Map map) => AuthGoogleUser.fromResult(ResultMap(map));
  static AuthGoogleUser fromString(String jstr) => fromJson(Utilities.decodeJson(jstr));
  static List fromJsonArray(jarr) => (jarr as List).map((i) => fromJson(i)).toList();
  static List fromJsonString(String jstr) => fromJsonArray(Utilities.decodeJson(jstr));
}
