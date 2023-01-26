import 'dart:convert';
import 'dart:io';
import 'package:ekitap/userModel.dart';
import 'package:path_provider/path_provider.dart';

bool isEmpty = false;

class FileOperations {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    if (!(await File('$path/userData.json').exists())) {
      await File('$path/userData.json').create();
      await writeToFile(jsonEncode(appCacheData.value));
    }
    return File('$path/userData.json');
  }

  Future<File> writeToFile(String statics) async {
    final file = await _localFile;
    return file.writeAsString(statics.toString());
  }

  Future<Map<String, dynamic>> readFromFile() async {
    final file = await _localFile;
    final contents = await file.readAsString();
    var mapObject = jsonDecode(contents);
    return mapObject;
  }

  Future<void> deleteFile() async {
    final file = await _localFile;
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }
}
