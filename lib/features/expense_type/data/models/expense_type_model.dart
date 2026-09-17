import 'package:flutter/cupertino.dart';

class ExpenseTypeModel {
  final int? id;
  final String title;
  final String subtitle;
  final int iconColor;
  final int icon;

  ExpenseTypeModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.icon,
  });
  factory ExpenseTypeModel.fromJson(Map<String, dynamic> json) {
    debugPrint("subtitle : ${json['subtitle'].runtimeType}");
    return ExpenseTypeModel(
      id: json['id'] ?? 0,
      title: json['title'],
      subtitle: json['subtitle'],
      iconColor: json['color'],
      icon: json['icon'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id" : id,
      "title": title,
      "subtitle": subtitle,
      "color": iconColor,
      "icon": icon,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseTypeModel && id != null && other.id == id;
  }

  @override
  int get hashCode => id?.hashCode ?? identityHashCode(this);
}
