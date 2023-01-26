class Book {
  static List<Book> bookList = <Book>[];
  int ID = 0;
  String name = "";
  String downlaodCount = "";
  String pdfName = "";
  num? rate = null;
  String raterCount = "";
  String currentPage = "";

  Map<String, dynamic> toJson() => {
        'id': ID,
        'name': name,
        'downlaodCount': downlaodCount,
        'pdfName': pdfName,
        'rate': rate,
        'raterCount': raterCount,
        'currentPage': currentPage,
      };

  Book({
    this.ID = 0,
    this.name = "",
    this.downlaodCount = "",
    this.pdfName = "",
    this.rate = null,
    this.raterCount = "",
    this.currentPage = "",
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        ID: json["id"],
        name: json["name"],
        downlaodCount: json["downlaodCount"],
        pdfName: json["pdfName"],
        rate: json["rate"],
        raterCount: json["raterCount"],
        currentPage: json["currentPage"],
      );

  static Book getData(dynamic d) {
    var b = Book();
    b.ID = d["id"];
    b.name = d["name"].toString();
    b.downlaodCount = d["downlaodCount"].toString();
    b.pdfName = d["pdfName"].toString();
    b.rate = d["rate"] as num?;
    b.raterCount = d["raterCount"].toString();
    b.currentPage = d["currentPage"].toString();
    return b;
  }
}

class Chapter {
  static List<Chapter> chapterList = <Chapter>[];
  String ChapterName = "";
  int MinPage = 0;
  int MaxPage = 0;
  bool IsEditable = false;

  Map<String, dynamic> toJson() => {
        'ChapterName': ChapterName,
        'MinPage': MinPage,
        'MaxPage': MaxPage,
        'IsEditable': IsEditable,
      };

  Chapter({
    this.ChapterName = "",
    this.MinPage = 0,
    this.MaxPage = 0,
    this.IsEditable = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        ChapterName: json["ChapterName"],
        MinPage: json["MinPage"],
        MaxPage: json["MaxPage"],
        IsEditable: json["IsEditable"],
      );

  static Chapter getData(dynamic d) {
    var c = Chapter();
    c.ChapterName = d["ChapterName"].toString();
    c.MinPage = d["MinPage"];
    c.MaxPage = d["MaxPage"];
    c.IsEditable = d["IsEditable"];

    return c;
  }
}
