class ExpenseModel {
  final int? id;
  final String title;
  final double amount;
  final int type;
  final String date;
  final String note;
  final bool deductFromLuckyBudget;
  ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.note,
    this.deductFromLuckyBudget = false,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      date: json['date'],
      note: json['note'],
      deductFromLuckyBudget: (json['deductFromLuckyBudget'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "amount": amount,
      "type": type,
      "date": date,
      "note": note,
      "deductFromLuckyBudget": deductFromLuckyBudget ? 1 : 0,
    };
  }
}
