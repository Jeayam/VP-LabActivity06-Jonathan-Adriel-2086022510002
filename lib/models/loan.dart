
class Loan {
  final String loanId;
  final String bookId;
  final String studentId;
  final DateTime borrowingDate;
  final DateTime dueDate;
  final DateTime? returnDate;

  Loan({
    required this.loanId,
    required this.bookId,
    required this.studentId,
    required this.borrowingDate,
    required this.dueDate,
    this.returnDate,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      loanId: json['loanId'],
      bookId: json['bookId'],
      studentId: json['studentId'],
      borrowingDate: DateTime.parse(json['borrowingDate']),
      dueDate: DateTime.parse(json['dueDate']),
      returnDate: json['returnDate'] == null
          ? null
          : DateTime.parse(json['returnDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loanId': loanId,
      'bookId': bookId,
      'studentId': studentId,
      'borrowingDate': borrowingDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
    };
  }
}
