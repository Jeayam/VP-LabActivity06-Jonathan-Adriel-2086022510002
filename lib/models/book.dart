class Book {
  final String bookId;
  final String title;
  final String author;
  final double replacementPrice;
  final String status;
  final int stockAvailable;
  final int totalStock;

  Book({
    required this.bookId,
    required this.title,
    required this.author,
    required this.replacementPrice,
    required this.status,
    required this.stockAvailable,
    required this.totalStock,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['bookId'],
      title: json['title'],
      author: json['author'],
      replacementPrice:
          (json['replacementPrice'] as num).toDouble(),
      status: json['status'],
      stockAvailable: json['stockAvailable'],
      totalStock: json['totalStock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'replacementPrice': replacementPrice,
      'status': status,
      'stockAvailable': stockAvailable,
      'totalStock': totalStock,
    };
  }
}
