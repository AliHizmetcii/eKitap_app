import 'dart:convert';
import 'package:ekitap/ApiClient.dart';
import 'package:ekitap/FadeAnimation.dart';
import 'package:ekitap/bookModel.dart';
import 'package:ekitap/login.dart';
import 'package:ekitap/pdfViewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ekitap/userModel.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  appCacheData.value = await load();
  var b = await ApiClient.get("/api/kitaplar/tumkitaplar");
  if (b.statusCode == 200 &&
      !(b.headers["content-type"]?.contains("html") ?? false)) {
    List<dynamic> statsJson = jsonDecode(b.body.toString());
    Book.bookList.clear();
    for (int i = 0; i < statsJson.length; i++) {
      Book.bookList.add(Book.getData(statsJson[i]));
    }
    runApp(const BookList());
  } else {
    runApp(const Login());
  }
  FlutterNativeSplash.remove();
}

bool isOkey = false;
bool isEditingMode = false;

class BookList extends StatefulWidget {
  const BookList({Key? key}) : super(key: key);

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  Widget BookListFB() {
    return FutureBuilder(
      future: don(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        Widget retWidget;
        if (snapshot.hasData) {
          retWidget = snapshot.data!;
        } else {
          retWidget = Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Result: ${snapshot.data}'),
          );
        }
        return retWidget;
      },
    );
  }

  Widget bookItem(
      image, rate, raterCount, pdfStatus, bookName, pdfPath, currentPage,
      {isLeft}) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(right: 0),
        child: AspectRatio(
          aspectRatio: 1 / 1.414,
          child: Builder(builder: (context) {
            return GestureDetector(
              onTap: () async {
                if (pdfPath.isNotEmpty) {
                  if (!(await io.File(pdfPath).exists())) {
                    await createFileOfPdfUrl(pdfPath);
                  }
                  var dir = await getApplicationDocumentsDirectory();
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PDFScreen(path: "${dir.path}/$pdfPath")),
                  );
                  setState(() async {});
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.contain,
                    )),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient:
                          LinearGradient(begin: Alignment.bottomCenter, stops: [
                        .3,
                        .9
                      ], colors: [
                        Colors.black.withOpacity(.3),
                        Colors.black.withOpacity(.1),
                      ])),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rate != "null" ? rate.toString() : "",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 16,
                                ),
                                Text(
                                  "($raterCount)",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                            bookStatusIcon(pdfStatus, pdfPath),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(
                                bookName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    shadows: <Shadow>[
                                      Shadow(
                                          color: Colors.black38,
                                          offset: Offset(1, -1),
                                          blurRadius: 3),
                                      Shadow(
                                          color: Colors.black38,
                                          offset: Offset(-1, -1),
                                          blurRadius: 3),
                                      Shadow(
                                          color: Colors.black38,
                                          offset: Offset(-1, 1),
                                          blurRadius: 3),
                                      Shadow(
                                          color: Colors.black38,
                                          offset: Offset(1, 1),
                                          blurRadius: 3),
                                    ]),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }

  Future<Widget> don() async {
    List<Widget> widgetList = <Widget>[];
    var dir = await getApplicationDocumentsDirectory();
    for (int i = 0; i < Book.bookList.length; i++) {
      Widget widget = FadeAnimation(
        bookItem(
            'assets/images/kitap_resim.png',
            Book.bookList[i].rate,
            Book.bookList[i].raterCount,
            await isBookinCache("${dir.path}/${Book.bookList[i].pdfName}"),
            Book.bookList[i].name,
            Book.bookList[i].pdfName,
            Book.bookList[i].currentPage),
      );
      widgetList.add(widget);
    }
    return GridView.count(
      padding: const EdgeInsets.all(10),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 2,
      childAspectRatio: 1 / 1.414,
      children: widgetList,
    );
  }

  int getColorHexFromStr(String colorStr) {
    colorStr = "FF" + colorStr;
    colorStr = colorStr.replaceAll("#", "");
    int val = 0;
    int len = colorStr.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        // A..F
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        // a..f
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException("An error occurred when converting a color");
      }
    }
    return val;
  }

  Future<bool> isBookinCache(String pdfPath) async {
    return await io.File(pdfPath).exists();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Padding(
          padding: EdgeInsets.only(top: 0),
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background.jpg"),
                  fit: BoxFit.cover,
                  alignment: Alignment.center),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: 100.0,
                      width: double.infinity,
                      color: Color(getColorHexFromStr('#800080')),
                    ),
                    Positioned(
                      bottom: 10.0,
                      right: 100.0,
                      child: Container(
                        height: 400.0,
                        width: 400.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200.0),
                            color: Color(getColorHexFromStr('#a245a2'))
                                .withOpacity(0.4)),
                      ),
                    ),
                    Positioned(
                      bottom: 50.0,
                      left: 150.0,
                      child: Container(
                          height: 300.0,
                          width: 300.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(150.0),
                              color: Color(getColorHexFromStr('#a245a2'))
                                  .withOpacity(0.5))),
                    ),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Hoşgeldin , ${appCacheData.value.username}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  isEditingMode = !isEditingMode;
                                  setState(() {});
                                },
                                child: Icon(
                                  isEditingMode ? Icons.cancel : Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                    child: BookListFB(),
                  ),
                ),
                SizedBox(
                  height: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(filename,BuildContext c) async {
    return showDialog<void>(
      context: c,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kitabı Sil ?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Kitabı silmek istediğinize emin misiniz ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('SİL'),
              onPressed: () async {
                var dir = await getApplicationDocumentsDirectory();
                if (await io.File("${dir.path}/${filename}").exists())
                  io.File("${dir.path}/${filename}").delete();
                isEditingMode = false;
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
            TextButton(
              child: const Text('VAZGEÇ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget bookStatusIcon(bool pdfStatus, String filename) {
    if (isEditingMode) {
      if (pdfStatus)
        return Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () async {
                await _showMyDialog(filename,context);
              },
              child: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            );
          }
        );
      return Icon(Icons.cloud_download_rounded,
          color: Colors.white.withOpacity(.1));
    }
    return GestureDetector(
      onTap: () {
        print("buton basıldı");
      },
      child: Icon(
        pdfStatus ? Icons.cloud_done_rounded : Icons.cloud_download_rounded,
        color: Colors.white,
      ),
    );
  }
}
