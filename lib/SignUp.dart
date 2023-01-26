import 'dart:async';
import 'dart:convert';
import 'package:ekitap/ApiClient.dart';
import 'package:ekitap/custom_animation.dart';
import 'package:ekitap/inputWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.cubeGrid
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.purple
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.purple
    ..textColor = Colors.purple
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();
TextEditingController tcId = TextEditingController();

Timer? _timer;

class _SignUpState extends State<SignUp> {
  List categoryItemlist = [];

  Future getAllCategory() async {
    var baseUrl = "http://192.168.1.106/api/kitaplar/returnClass";

    http.Response response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      setState(() {
        categoryItemlist = jsonData;
      });
    }
  }

  var dropdownvalue;

  @override
  void initState() {
    super.initState();
    getAllCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Container(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: const Text(
                    "Kaydol",
                    style: TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                inputWidget(username, "İsim ve Soy İsim", "Giriniz",
                    TextInputType.name),
                inputWidget(tcId, "T.C No", "Giriniz", TextInputType.number),
                inputWidget(
                    password, "Şifre", "Giriniz", TextInputType.visiblePassword,
                    optPassword: true),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                  width: (MediaQuery.of(context).size.width * 0.7),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                    ),
                    hint: Text('Sınıf Seçiniz'),
                    items: categoryItemlist.map((item) {
                      return DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text(item['title'].toString()),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      setState(() {
                        dropdownvalue = newVal;
                      });
                    },
                    value: dropdownvalue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _timer?.cancel();
                      await EasyLoading.show(
                        status: 'Yükleniyor...',
                        maskType: EasyLoadingMaskType.black,
                      );
                      var result = await ApiClient.post(
                          "/api/kitaplar/SaveNewStudent", <String, dynamic>{
                        "Name": username.text,
                        "Password": password.text,
                        "TcId": tcId.text,
                        "ClassRoomId": dropdownvalue,
                        "ApproveStatus": false,
                      });
                      EasyLoading.dismiss();
                      EasyLoading.showToast(
                        jsonDecode(result.body.toString())['message'],
                        toastPosition: EasyLoadingToastPosition.center,
                        maskType: EasyLoadingMaskType.black,
                        duration: Duration(milliseconds: 3000),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                    ),
                    child: const Text('Kaydol'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
