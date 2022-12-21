import 'dart:convert';
import 'package:ekitap/SaveCookie.dart';
import 'package:ekitap/userModel.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

class appCacheData {
  static appCacheData value = appCacheData(username: "", cookie: "");

  late String username;
  late String cookie;

  appCacheData({required this.username, required this.cookie});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> user = Map<String, dynamic>();
    user["username"] = this.username;
    user["cookie"] = this.cookie;
    return user;
  }

  appCacheData fromJson(Map<String, dynamic> json) =>
      appCacheData(username: json["username"], cookie: json["cookie"]);
}

void save() {
  FileOperations().writeToFile(jsonEncode(appCacheData.value.toJson()));
}

Future<appCacheData> load() async {
  return appCacheData.value.fromJson(await FileOperations().readFromFile());
}
