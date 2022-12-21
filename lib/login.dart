import 'dart:convert';
import 'package:ekitap/ApiClient.dart';
import 'package:ekitap/bookList.dart';
import 'package:ekitap/bookModel.dart';
import 'package:ekitap/inputWidget.dart';
import 'package:ekitap/userModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyStatefulWidget(),
    );
  }
}

TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();



class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static final List<Widget> _widgetOptions = <Widget>[
    Builder(builder: (context) {
      return Container(
        alignment: Alignment.center,
        child: Expanded(
          flex: 1,
          child: FractionallySizedBox(
            widthFactor: 0.7,
            child: Expanded(
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
                        "Giriş Yap",
                        style: TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    inputWidget(username, "TC Kimlik Numarası", "Giriniz",
                        TextInputType.number),
                    inputWidget(password, "Şifre", "Giriniz",
                        TextInputType.visiblePassword,
                        optPassword: true),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          var result =await ApiClient.post("/Home/Login",<String,dynamic>{"Username":username.text,"Password":password.text});
                          if(result.statusCode==200){
                            appCacheData.value.username = jsonDecode(result.body.toString())['displayName'];
                            save();
                            var b = await ApiClient.get("/api/kitaplar/tumkitaplar");
                            if (b.statusCode == 200 && !(b.headers["content-type"]?.contains("html")??false)) {
                              List<dynamic> statsJson = jsonDecode(b.body.toString());
                              Book.bookList.clear();
                              for (int i = 0; i < statsJson.length; i++) {
                                Book.bookList.add(Book.getData(statsJson[i]));
                              }
                              runApp(const BookList());
                            }
                            else{
                              runApp(const Login());
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookList(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // <-- Radius
                          ),
                        ),
                        child: const Text('Giriş Yapın'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }),
    const Text(
      'Index 1: Business',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background.jpg"),
                fit: BoxFit.cover,
                alignment: Alignment.center),
          ),
          child: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: 'Giriş Yap',
              backgroundColor: Colors.red,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.key),
              label: 'Kaydol',
              backgroundColor: Colors.green,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
  }
}
