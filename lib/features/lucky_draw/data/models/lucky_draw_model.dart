class LuckyDrawTicket {
  final int id;
  final int drawId;
  final int ticketNo;
  final double amount;
  final bool drawn;
  final DateTime? drawnAt;

  const LuckyDrawTicket({
    required this.id,
    required this.drawId,
    required this.ticketNo,
    required this.amount,
    this.drawn = false,
    this.drawnAt,
  });

  factory LuckyDrawTicket.fromMap(Map<String, dynamic> map) {
    return LuckyDrawTicket(
      id: map['id'] as int,
      drawId: map['drawId'] as int,
      ticketNo: map['ticketNo'] as int,
      amount: (map['amount'] as num).toDouble(),
      drawn: (map['drawn'] as int) == 1,
      drawnAt: map['drawnAt'] == null
          ? null
          : DateTime.tryParse(map['drawnAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'drawId': drawId,
      'ticketNo': ticketNo,
      'amount': amount,
      'drawn': drawn ? 1 : 0,
      'drawnAt': drawnAt?.toIso8601String(),
    };
  }

  LuckyDrawTicket copyWith({
    int? id,
    int? drawId,
    bool? drawn,
    DateTime? drawnAt,
  }) {
    return LuckyDrawTicket(
      id: id ?? this.id,
      drawId: drawId ?? this.drawId,
      ticketNo: ticketNo,
      amount: amount,
      drawn: drawn ?? this.drawn,
      drawnAt: drawnAt ?? this.drawnAt,
    );
  }
}

class LuckyDrawModel {
  final int id;
  final double totalBudget;
  final String period;
  final int days;
  final double minBudget;
  final double maxBudget;
  final double savedMoney;
  final List<LuckyDrawTicket> tickets;
  final DateTime createdAt;

  const LuckyDrawModel({
    required this.id,
    required this.totalBudget,
    required this.period,
    required this.days,
    this.minBudget = 0.01,
    required this.maxBudget,
    required this.savedMoney,
    required this.tickets,
    required this.createdAt,
  });

  factory LuckyDrawModel.fromMap(
    Map<String, dynamic> map, {
    List<LuckyDrawTicket> tickets = const [],
  }) {
    return LuckyDrawModel(
      id: map['id'] as int,
      totalBudget: (map['totalBudget'] as num).toDouble(),
      period: map['period'] as String,
      days: map['days'] as int,
      minBudget: (map['minBudget'] as num?)?.toDouble() ?? 0.01,
      maxBudget: (map['maxBudget'] as num).toDouble(),
      savedMoney: (map['savedMoney'] as num).toDouble(),
      tickets: tickets,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'totalBudget': totalBudget,
      'period': period,
      'days': days,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'savedMoney': savedMoney,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  double get prizePool => tickets.fold(0, (sum, ticket) => sum + ticket.amount);

  double get drawnAmount => tickets
      .where((ticket) => ticket.drawn)
      .fold(0, (sum, ticket) => sum + ticket.amount);

  int get drawnCount => tickets.where((ticket) => ticket.drawn).length;

  List<LuckyDrawTicket> get undrawnTickets =>
      tickets.where((ticket) => !ticket.drawn).toList(growable: false);

  LuckyDrawTicket? ticketDrawnOn(DateTime date) {
    for (final ticket in tickets) {
      final drawnAt = ticket.drawnAt?.toLocal();
      if (drawnAt != null &&
          drawnAt.year == date.year &&
          drawnAt.month == date.month &&
          drawnAt.day == date.day) {
        return ticket;
      }
    }
    return null;
  }

  LuckyDrawTicket? get todayTicket => ticketDrawnOn(DateTime.now());

  bool get hasDrawnToday => todayTicket != null;

  LuckyDrawModel copyWith({List<LuckyDrawTicket>? tickets}) {
    return LuckyDrawModel(
      id: id,
      totalBudget: totalBudget,
      period: period,
      days: days,
      minBudget: minBudget,
      maxBudget: maxBudget,
      savedMoney: savedMoney,
      tickets: tickets ?? this.tickets,
      createdAt: createdAt,
    );
  }
}
