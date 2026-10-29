import 'package:flutter/material.dart';

import '../models/repository/perpus_repository.dart';
import '../viewmodels/borrowform_view_model.dart';

class LoanListPage extends StatefulWidget {
  const LoanListPage({
    super.key,
    required this.repository,
  });

  final PerpusRepository repository;

  @override
  State<LoanListPage> createState() => _LoanListPageState();
}

class _LoanListPageState extends State<LoanListPage> {
  late final BorrowFormViewModel _viewModel;

  DateTime _selectedReturnDate = DateTime.now();

  int _calculateOverdueDays(DateTime dueDate, DateTime returnDate) {
  final due = DateTime(
    dueDate.year,
    dueDate.month,
    dueDate.day,
  );

  final returned = DateTime(
    returnDate.year,
    returnDate.month,
    returnDate.day,
  );

  if (!returned.isAfter(due)) return 0;

  return returned.difference(due).inDays;
}

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
    _viewModel.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Peminjaman'),
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

          final loans = _viewModel.loans;

          if (loans.isEmpty) {
            return const Center(
              child: Text('Belum ada data peminjaman.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];

              final matchingBooks = _viewModel.books.where(
                (book) => book.bookId == loan.bookId,
              );

              final bookTitle = matchingBooks.isEmpty
                  ? 'Buku tidak ditemukan'
                  : matchingBooks.first.title;

              final isReturned = loan.returnDate != null;
              final fine = _viewModel.calculateFine(
              loan,
              asOfDate: _selectedReturnDate,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Student ID: ${loan.studentId}'),
                      const SizedBox(height: 6),
                      Text(
                        'Tanggal pinjam: '
                        '${_formatDate(loan.borrowingDate)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Jatuh tempo: ${_formatDate(loan.dueDate)}',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isReturned
                            ? 'Status: Dikembalikan'
                            : 'Status: Sedang dipinjam',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isReturned
                              ? Colors.green
                              : Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(height: 6),
                     
                      Text('Denda: ${_formatRupiah(fine)}'),
                      if (!isReturned) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Terlambat: ${_calculateOverdueDays(loan.dueDate, _selectedReturnDate)} hari',
                      ),
                    ],

                      if (!isReturned) ...[
                        const SizedBox(height: 12),

                        const Text(
                          'Tanggal pengembalian',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 8),

                        OutlinedButton.icon(
                          onPressed: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedReturnDate,
                              firstDate: DateTime(
                                loan.borrowingDate.year,
                                loan.borrowingDate.month,
                                loan.borrowingDate.day,
                              ),
                              lastDate: DateTime(2100),
                            );

                            if (selectedDate != null && mounted) {
                              setState(() {
                                _selectedReturnDate = selectedDate;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: Text(_formatDate(_selectedReturnDate)),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final message = _viewModel.returnBook(
                              loan.loanId,
                              returnDate: _selectedReturnDate,
                            );

                              if (message != null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                  ),
                                );
                                return;
                              }

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Buku berhasil dikembalikan.',
                                  ),
                                ),
                              );

                              await _viewModel.loadData();
                            },
                            icon: const Icon(
                              Icons.assignment_return_outlined,
                            ),
                            label: const Text('Kembalikan Buku'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
