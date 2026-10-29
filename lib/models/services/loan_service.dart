import 'dart:convert';
import 'package:flutter/services.dart';

class LoanService {
  Future<Map<String, dynamic>> loadLoanData() async {
    final String response =
        await rootBundle.loadString('local/loanData.json');

    return jsonDecode(response) as Map<String, dynamic>;
  }
}
