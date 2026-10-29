
import 'package:flutter/material.dart';

import 'models/book.dart';
import 'models/repository/perpus_repository.dart';
import 'models/services/book_service.dart';
import 'models/services/loan_service.dart';
import 'models/services/fine_service.dart';
import 'viewmodels/home_view_model.dart';
import 'views/borrow_form_page.dart';
import 'views/loan_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final PerpusRepository _repository = PerpusRepository(
    bookService: BookService(),
    loanService: LoanService(),
    fineService: FineService(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Library System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4055A8),
          brightness: Brightness.light,
          surface: const Color(0xFFF5F6FA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F6FA),
          foregroundColor: Color(0xFF202747),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFFE5E8F0),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4055A8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE0E4EE),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFE0E4EE),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4055A8),
              width: 2,
            ),
          ),
        ),
      ),
      home: HomePage(repository: _repository),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
  });

  final PerpusRepository repository;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = HomeViewModel(
      repository: widget.repository,
    );

    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
        appBar: AppBar(
          title: const Text(
            'University Library',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: 'Daftar Peminjaman',
              icon: const Icon(Icons.assignment_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoanListPage(
                      repository: widget.repository,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),

      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(_viewModel.errorMessage!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _viewModel.loadData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final books = _viewModel.books;

          if (books.isEmpty) {
            return const Center(
              child: Text('Belum ada buku di katalog.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Book Catalog',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202747),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${books.length} buku dalam katalog',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              ...books.map(_buildBookCard),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    final isAvailable = book.stockAvailable > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4055A8)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF4055A8),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202747),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        book.author,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFE5E8F0)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: Color(0xFF68708A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Stok: ${book.stockAvailable}/${book.totalStock}',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? const Color(0xFFE5F5EC)
                        : const Color(0xFFFCE8E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAvailable ? 'Tersedia' : 'Habis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAvailable
                          ? const Color(0xFF217346)
                          : const Color(0xFFB42318),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Harga penggantian: Rp '
              '${book.replacementPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: book.stockAvailable <= 0
                    ? null
                    : () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BorrowFormPage(
                              repository: widget.repository,
                              book: book,
                            ),
                          ),
                        );

                        if (result == true && mounted) {
                          await _viewModel.loadData();
                        }
                      },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Pinjam Buku'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
