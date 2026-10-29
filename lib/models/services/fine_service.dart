import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lab06/models/fine.dart';

class FineService {
  Future<Fine> getFine() async {
    final data = await rootBundle.loadString('local/fineData.json');

    final json = jsonDecode(data) as Map<String, dynamic>;

    return Fine.fromJson(json);
  }
}
