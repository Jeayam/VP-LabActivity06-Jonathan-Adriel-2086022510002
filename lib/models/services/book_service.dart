import 'dart:convert';
import 'package:flutter/services.dart';

class BookService {
  Future<Map<String, dynamic>> loadBookData() async {
    final String response =
        await rootBundle.loadString('local/bookData.json');

    return jsonDecode(response) as Map<String, dynamic>;
  }
}
