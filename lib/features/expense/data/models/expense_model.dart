class ExpenseModel {
  final int? id;
  final String title;
  final double amount;
  final int type;
  final String date;
  final String note;
  ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.note,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      type: json['type'],
      date: json['date'],
      note: json['note'],
    );
  }
  
  Map<String,dynamic> toJson() {
    return {
      "title" : title,
      "amount" : amount,
      "type" : type,
      "date" : date,
      "note" : note
    };
  }
}
