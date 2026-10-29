
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/repository/perpus_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final PerpusRepository _repository;

  HomeViewModel({required PerpusRepository repository})
  : _repository = repository {
  _repository.addListener(_onRepositoryChanged);
}

    @override
  void dispose() {
    _repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  List<Book> _books = [];
  List<Book> get books => _books;

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
    } catch (error) {
      _errorMessage = 'Gagal memuat katalog buku.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
      void _onRepositoryChanged() {
      _books = _repository.cachedBooks;
      notifyListeners();
    }
}
