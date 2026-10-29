
import '../book.dart';
import '../loan.dart';
import '../fine.dart';
import '../services/book_service.dart';
import '../services/loan_service.dart';
import '../services/fine_service.dart';
import 'package:flutter/foundation.dart';

class PerpusRepository extends ChangeNotifier {
  final BookService _bookService;
  final LoanService _loanService;
  final FineService _fineService;

  PerpusRepository({
    required BookService bookService,
    required LoanService loanService,
    required FineService fineService,
  })  : _bookService = bookService,
        _loanService = loanService,
        _fineService = fineService;

  List<Book>? _books;
  List<Loan>? _loans;
  Fine? _fine;

  Future<List<Book>> getBooks() async {
    if (_books != null) {
      return _books!;
    }

    final data = await _bookService.loadBookData();
    final List<dynamic> books = data['bookData'];

    _books = books
        .map(
          (book) => Book.fromJson(
            Map<String, dynamic>.from(book),
          ),
        )
        .toList();

    return _books!;
  }

  Future<List<Loan>> getLoans() async {
    if (_loans != null) {
      return _loans!;
    }

    final data = await _loanService.loadLoanData();
    final List<dynamic> loans = data['loanData'];

    _loans = loans
        .map(
          (loan) => Loan.fromJson(
            Map<String, dynamic>.from(loan),
          ),
        )
        .toList();

    return _loans!;
  }

  Future<Fine> getFine() async {
    if (_fine != null) {
      return _fine!;
    }

    _fine = await _fineService.getFine();
    return _fine!;
  }
  
    void updateBooks(List<Book> books) {
  _books = books;
  notifyListeners();
}

    void updateLoans(List<Loan> loans) {
      _loans = loans;
      notifyListeners();
    }
    
    List<Book> get cachedBooks => _books ?? [];
    List<Loan> get cachedLoans => _loans ?? [];
}
