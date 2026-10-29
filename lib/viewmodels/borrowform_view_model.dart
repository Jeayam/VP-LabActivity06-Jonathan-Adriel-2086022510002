
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/loan.dart';
import '../models/fine.dart';
import '../models/repository/perpus_repository.dart';

class BorrowFormViewModel extends ChangeNotifier {
  final PerpusRepository _repository;

  BorrowFormViewModel({
  required PerpusRepository repository,
  }) : _repository = repository {
  _repository.addListener(_onRepositoryChanged);
  }

  void _onRepositoryChanged() {
  _books = _repository.cachedBooks;
  _loans = _repository.cachedLoans;
  notifyListeners();
}

@override
void dispose() {
  _repository.removeListener(_onRepositoryChanged);
  super.dispose();
}

  List<Book> _books = [];
  List<Book> get books => _books;

  List<Loan> _loans = [];
  List<Loan> get loans => _loans;

  Fine? _fine;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _repository.getBooks();
      _loans = await _repository.getLoans();
      _fine = await _repository.getFine();
    } catch (error) {
      _errorMessage = 'Gagal memuat data peminjaman.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

    String? borrowBook(
    String bookId,
    String studentId, {
    DateTime? borrowingDate,
    }) {
    if (studentId.trim().isEmpty) {
      return 'Student ID tidak boleh kosong.';
    }

    final bookIndex = _books.indexWhere(
      (book) => book.bookId == bookId,
    );

    if (bookIndex == -1) {
      return 'Buku tidak ditemukan.';
    }

    final book = _books[bookIndex];

    if (book.stockAvailable <= 0) {
      return 'Stok buku sedang habis.';
    }

    final hasActiveLoan = _loans.any(
      (loan) =>
          loan.bookId == bookId &&
          loan.returnDate == null,
    );

    if (hasActiveLoan) {
      return 'Buku ini masih memiliki peminjaman aktif.';
    }

    final selectedBorrowingDate = borrowingDate ?? DateTime.now();

    final borrowingDay = DateTime(
      selectedBorrowingDate.year,
      selectedBorrowingDate.month,
      selectedBorrowingDate.day,
    );

    final loan = Loan(
      loanId: DateTime.now().microsecondsSinceEpoch.toString(),
      bookId: book.bookId,
      studentId: studentId.trim(),
      borrowingDate: borrowingDay,
      dueDate: borrowingDay.add(const Duration(days: 7)),
    );

    _loans = [..._loans, loan];

    _repository.updateLoans(_loans);

    _books[bookIndex] = Book(
      bookId: book.bookId,
      title: book.title,
      author: book.author,
      replacementPrice: book.replacementPrice,
      status: book.stockAvailable > 1
          ? 'available'
          : 'borrowed',
      stockAvailable: book.stockAvailable - 1,
      totalStock: book.totalStock,
    );

    _repository.updateBooks(_books);

    notifyListeners();
    return null;
  }

    String? returnBook(
      String loanId, {
      DateTime? returnDate,
    })  {
    final loanIndex = _loans.indexWhere(
      (loan) => loan.loanId == loanId,
    );

    if (loanIndex == -1) {
      return 'Data peminjaman tidak ditemukan.';
    }

    final loan = _loans[loanIndex];

    if (loan.returnDate != null) {
      return 'Buku ini sudah dikembalikan.';
    }

    final bookIndex = _books.indexWhere(
      (book) => book.bookId == loan.bookId,
    );

    if (bookIndex == -1) {
      return 'Data buku tidak ditemukan.';
    }

    final book = _books[bookIndex];

    _books[bookIndex] = Book(
      bookId: book.bookId,
      title: book.title,
      author: book.author,
      replacementPrice: book.replacementPrice,
      status: book.stockAvailable + 1 >= book.totalStock
          ? 'available'
          : 'borrowed',
      stockAvailable: (book.stockAvailable + 1)
          .clamp(0, book.totalStock),
      totalStock: book.totalStock,
    );

    _loans[loanIndex] = Loan(
      loanId: loan.loanId,
      bookId: loan.bookId,
      studentId: loan.studentId,
      borrowingDate: loan.borrowingDate,
      dueDate: loan.dueDate,
      returnDate: returnDate ?? DateTime.now(),
    );
    _repository.updateBooks(_books);
    _repository.updateLoans(_loans);

    notifyListeners();
    return null;
  }

    int calculateFine(
    Loan loan, {
   DateTime? asOfDate,
    }) {
    if (_fine == null) return 0;

    final dueDate = DateTime(
      loan.dueDate.year,
      loan.dueDate.month,
      loan.dueDate.day,
    );

    final checkDateRaw =
    loan.returnDate ?? asOfDate ?? DateTime.now();

    final checkDate = DateTime(
      checkDateRaw.year,
      checkDateRaw.month,
      checkDateRaw.day,
    );

    if (!checkDate.isAfter(dueDate)) {
      return 0;
    }

    final missingDate = _addCalendarMonths(
      dueDate,
      _fine!.missingAfterMonths,
    );

    final fineEndDate = checkDate.isBefore(missingDate)
        ? checkDate
        : missingDate;

    final overdueDays = fineEndDate.difference(dueDate).inDays;

    final fineDays = (overdueDays - _fine!.freeOverdueDays)
        .clamp(0, 100000);

    int fine = fineDays * _fine!.dailyFine;

    if (!checkDate.isBefore(missingDate)) {
      final bookIndex = _books.indexWhere(
        (book) => book.bookId == loan.bookId,
      );

      if (bookIndex != -1) {
        fine += _books[bookIndex].replacementPrice.toInt();
      }
    }

    return fine;
  }

  DateTime _addCalendarMonths(DateTime date, int months) {
    final totalMonths = date.year * 12 + date.month - 1 + months;
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;

    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;

    return DateTime(year, month, day);
  }
}
