class Book {
  static List<Book> bookList = <Book>[];
  String name = "";
  String downlaodCount = "";
  String pdfName = "";
  String rate = "";
  String raterCount = "";
  String currentPage = "";

  Map<String, dynamic> toJson() => {
        'name': name,
        'downlaodCount': downlaodCount,
        'pdfName': pdfName,
        'rate': rate,
        'raterCount': raterCount,
        'currentPage': currentPage,
      };

  Book(
      {this.name = "",
      this.downlaodCount = "",
      this.pdfName = "",
      this.rate = "",
      this.raterCount = "",
      this.currentPage = ""});

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        name: json["name"],
        downlaodCount: json["downlaodCount"],
        pdfName: json["pdfName"],
        rate: json["rate"],
        raterCount: json["raterCount"],
        currentPage: json["currentPage"],
      );

  static Book getData(dynamic d) {
    var b = Book();
    b.name = d["name"].toString();
    b.downlaodCount = d["downlaodCount"].toString();
    b.pdfName = d["pdfName"].toString();
    b.rate = d["rate"].toString();
    b.raterCount = d["raterCount"].toString();
    b.currentPage = d["currentPage"].toString();
    return b;
  }
}
