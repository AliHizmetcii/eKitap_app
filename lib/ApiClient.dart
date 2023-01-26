import 'dart:convert';
import 'package:ekitap/userModel.dart';
import 'package:http/http.dart' as http;

class ApiClient{
  static String basePath = "https://api.cansel.com.tr";

  static Future<http.Response> get(String path) async {
    var response= await http.get(
      Uri.parse('$basePath$path'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'cookie': appCacheData.value.cookie,
      },
    );
    return response;
  }

static Future<http.Response> post(String path,dynamic body) async {
    var response= await http.post(
      Uri.parse('$basePath$path'),
      headers: appCacheData.value.cookie!=""?
      <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'cookie': appCacheData.value.cookie,
      }:
      <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(body),
    );
    if(response.headers.containsKey("set-cookie")) {
      appCacheData.value.cookie = response.headers["set-cookie"].toString();
      await save();
    }
    return response;
  }
}
