import 'dart:math';

class LuckyDrawGenerator {
  LuckyDrawGenerator._();

  static List<double> generate({
    required double totalBudget,
    required int days,
    required double minBudget,
    required double maxBudget,
    Random? random,
  }) {
    if (totalBudget <= 0 || days <= 0 || minBudget <= 0 || maxBudget <= 0) {
      throw ArgumentError(
        'Budget, days, min budget, and max budget must be positive',
      );
    }

    final totalCents = (totalBudget * 100).round();
    final minCents = (minBudget * 100).round();
    final maxCents = (maxBudget * 100).round();
    final maxAllowedCents = totalCents ~/ days;
    if (maxCents > maxAllowedCents) {
      throw ArgumentError('Max budget cannot exceed ${maxAllowedCents / 100}');
    }
    if (minCents > maxCents) {
      throw ArgumentError('Min budget cannot exceed max budget');
    }
    if (minCents * days > totalCents) {
      throw ArgumentError('Total budget cannot cover the daily minimum');
    }

    final rng = random ?? Random();
    var remainingCents = totalCents;
    final amounts = <double>[];

    for (var index = 0; index < days; index++) {
      final remainingTicketCount = days - index - 1;
      final reservedMinimum = remainingTicketCount * minCents;
      final capCents = min(maxCents, remainingCents - reservedMinimum);
      final amountCents = minCents + rng.nextInt(capCents - minCents + 1);
      amounts.add(amountCents / 100);
      remainingCents -= amountCents;
    }

    return amounts;
  }

  static double savedMoney(double totalBudget, List<double> amounts) {
    final prizePool = amounts.fold<double>(0, (sum, amount) => sum + amount);
    return max(0, double.parse((totalBudget - prizePool).toStringAsFixed(2)));
  }
}
