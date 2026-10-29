class Fine {
  final int freeOverdueDays;
  final int dailyFine;
  final int missingAfterMonths;

  Fine({
    required this.freeOverdueDays,
    required this.dailyFine,
    required this.missingAfterMonths,
  });

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      freeOverdueDays: json['freeOverdueDays'] as int,
      dailyFine: json['dailyFine'] as int,
      missingAfterMonths: json['missingAfterMonths'] as int,
    );
  }
}
