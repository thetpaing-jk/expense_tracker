class BudgetModel {
  final int? id;
  final String name;
  final double amount;

  const BudgetModel({this.id, required this.name, required this.amount});

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int?,
      name: (json['name'] as String?) ?? 'Budget',
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'name': name, 'amount': amount};
  }
}
