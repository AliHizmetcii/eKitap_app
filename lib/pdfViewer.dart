import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ekitap/ApiClient.dart';
import 'package:ekitap/bookList.dart';
import 'package:ekitap/bookModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

late double InitialRating = 0;
String InitialComment = "";

class pdfViewer extends StatefulWidget {
  @override
  _pdfViewerState createState() => _pdfViewerState();
}

class _pdfViewerState extends State<pdfViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF View',
      debugShowCheckedModeBanner: false,
    );
  }
}

int? currentPage = 0;
class PDFScreen extends StatefulWidget {
  late final String? path;
  late final int? CurrentPage;
  final myController = TextEditingController();
  PDFScreen({Key? key, this.path, this.CurrentPage}) : super(key: key);

  _PDFScreenState createState() {
    currentPage=this.CurrentPage;
    return _PDFScreenState();
  }
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  bool isReady = false;
  String errorMessage = '';

  bool isChapterEditable = true;

  Future<bool> getChapterInform(int page) async {
    dynamic chapters;
    var b =
        await ApiClient.post("/api/kitaplar/SaveLastPage", <String, dynamic>{
      "Id": ID,
      "Page": page,
    });
    if (b.statusCode == 200) {
      chapters = jsonDecode(b.body.toString());
      var currentChapter;
      print(chapters);
      var jsonChapterList=jsonDecode(chapters["chapterName"]!=""?chapters["chapterName"]:"[]");
      for (int i = 0; i < jsonChapterList.length; i++) {
        if(currentChapter==null&&page >= jsonChapterList[i]["MinPage"] && page <= jsonChapterList[i]["MaxPage"]) {
          currentChapter = jsonChapterList[i];
          break;
        }
      }
      if (currentChapter?["IsEditable"] ?? true) {
      InitialComment = chapters["comment"];
      return true;
    } else {
      InitialComment = "Bu sayfaya yorum yapılamaz !";
      return false;
    }
    }
return false;

  }

  Future<bool> onWillPop() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookList(),
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            PDFView(
              filePath: widget.path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: true,
              pageSnap: true,
              defaultPage: currentPage!,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
              // if set to true the link is handled in flutter
              onRender: (_pages) {
                setState(() {
                  pages = _pages;
                  isReady = true;
                });
              },
              onError: (error) {
                setState(() {
                  errorMessage = error.toString();
                });
                print(error.toString());
              },

              onPageError: (page, error) {
                setState(() {
                  errorMessage = '$page: ${error.toString()}';
                });
                print('$page: ${error.toString()}');
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _controller.complete(pdfViewController);
              },
              onLinkHandler: (String? uri) {
                print('goto uri: $uri');
              },
              onPageChanged: (int? page, int? total) {
                var i = page??0;
                i++;
                print('page change: $i/$total');
                currentPage = i;
                setState(() {
                  print("test");
                });
                setState(() async {
                  isChapterEditable = await getChapterInform(i);
                  print(isChapterEditable);
                });
              },
            ),
            errorMessage.isEmpty
                ? !isReady
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container()
                : Center(
                    child: Text(errorMessage),
                  ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "${currentPage}/${pages}",
                  style: TextStyle(),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => showModalBottomSheet<void>(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      height: 200,
                      color: Colors.amber,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookList(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(
                                  context,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.0,
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Kitabı Değerlendir :"),
                                  RatingBar.builder(
                                      itemSize: 25,
                                      initialRating: InitialRating,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: false,
                                      itemCount: 5,
                                      itemPadding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.blue,
                                          ),
                                      onRatingUpdate: (_rating) {
                                        setState(() {
                                          InitialRating = _rating;
                                        });
                                        ApiClient.post(
                                            "/api/kitaplar/KitapPuanla",
                                            <String, dynamic>{
                                              "ID": ID,
                                              "rate": _rating.round(),
                                            });
                                      }),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Container(
                              height: 95,
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.0,
                                  color: Colors.black,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                  bottomRight: Radius.circular(22.0),
                                  bottomLeft: Radius.circular(22.0),
                                ),
                              ),
                              child: TextFormField(
                                enabled: isChapterEditable,
                                controller: PDFScreen().myController,
                                decoration: InputDecoration.collapsed(
                                    hintText: '$InitialComment'),
                                onFieldSubmitted: (text) {
                                  ApiClient.post(
                                      "/api/kitaplar/KitapYorumla",
                                      <String, dynamic>{
                                        "ID": ID,
                                        "UserComment": text,
                                        "pageNo": currentPage,
                                      });
                                  Navigator.pop(context);
                                  InitialComment = text;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<File> createFileOfPdfUrl(String pdfPath) async {
  Completer<File> completer = Completer();
  print("Start download file from internet!");
  try {
    final url = "${ApiClient.basePath}/Books/$pdfPath";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    var dir = await getApplicationDocumentsDirectory();
    File file = File("${dir.path}/$filename");

    await file.writeAsBytes(bytes, flush: true);
    completer.complete(file);
  } catch (e) {
    throw Exception('Error parsing asset file!');
  }

  return completer.future;
}
