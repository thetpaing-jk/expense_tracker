class BudgetModel {
  final int? id;
  final double amount;

  const BudgetModel({this.id, required this.amount});

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'amount': amount};
  }
}
