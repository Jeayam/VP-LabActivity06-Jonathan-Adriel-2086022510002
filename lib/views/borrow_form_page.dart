
import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/repository/perpus_repository.dart';
import '../viewmodels/borrowform_view_model.dart';

class BorrowFormPage extends StatefulWidget {
  const BorrowFormPage({
    super.key,
    required this.repository,
    required this.book,
  });

  final PerpusRepository repository;
  final Book book;

  @override
  State<BorrowFormPage> createState() => _BorrowFormPageState();
}

class _BorrowFormPageState extends State<BorrowFormPage> {
  late final BorrowFormViewModel _viewModel;

  final TextEditingController _studentIdController =
      TextEditingController();

  DateTime _selectedBorrowingDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _viewModel = BorrowFormViewModel(
      repository: widget.repository,
    );

    _viewModel.loadData();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Future<void> _selectBorrowingDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBorrowingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _selectedBorrowingDate = selectedDate;
      });
    }
  }

  void _borrowBook() {
    final message = _viewModel.borrowBook(
      widget.book.bookId,
      _studentIdController.text,
      borrowingDate: _selectedBorrowingDate,
    );

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buku berhasil dipinjam!'),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime(
      _selectedBorrowingDate.year,
      _selectedBorrowingDate.month,
      _selectedBorrowingDate.day,
    ).add(const Duration(days: 7));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Peminjaman'),
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
              child: Text(_viewModel.errorMessage!),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Borrow a Book',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202747),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan Student ID dan tanggal peminjaman.',
              ),
              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 36,
                        color: Color(0xFF4055A8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.book.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Penulis: ${widget.book.author}'),
                      const SizedBox(height: 6),
                      Text(
                        'Stok tersedia: ${widget.book.stockAvailable}',
                      ),
                      const SizedBox(height: 6),
                      const Text('Durasi peminjaman: 7 hari'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  hintText: 'Masukkan Student ID',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Tanggal peminjaman',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: _selectBorrowingDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(_formatDate(_selectedBorrowingDate)),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4055A8).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_available_outlined,
                      color: Color(0xFF4055A8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tanggal jatuh tempo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_formatDate(dueDate)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _viewModel.isLoading
                      ? null
                      : _borrowBook,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Pinjam Buku'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
