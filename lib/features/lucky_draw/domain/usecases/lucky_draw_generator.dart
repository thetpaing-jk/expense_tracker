import 'dart:math';

class LuckyDrawGenerator {
  LuckyDrawGenerator._();

  static List<double> generate({
    required double totalBudget,
    required int days,
    required double maxBudget,
    Random? random,
  }) {
    if (totalBudget <= 0 || days <= 0 || maxBudget <= 0) {
      throw ArgumentError('Budget, days, and max budget must be positive');
    }

    final maxAllowed = (totalBudget * 100 ~/ days) / 100;
    if (maxBudget > maxAllowed) {
      throw ArgumentError('Max budget cannot exceed $maxAllowed');
    }

    final rng = random ?? Random();
    var remaining = totalBudget;
    final amounts = <double>[];

    for (var index = 0; index < days; index++) {
      final isLast = index == days - 1;
      late final double amount;
      if (isLast) {
        amount = min(remaining, maxBudget);
      } else {
        final cap = min(maxBudget, remaining - (days - index - 1) * 0.01);
        if (cap < 0.01) break;
        amount = double.parse(
          (0.01 + rng.nextDouble() * (cap - 0.01)).toStringAsFixed(2),
        );
      }

      if (amount <= 0) break;
      amounts.add(amount);
      remaining = double.parse((remaining - amount).toStringAsFixed(2));
    }

    return amounts;
  }

  static double savedMoney(double totalBudget, List<double> amounts) {
    final prizePool = amounts.fold<double>(0, (sum, amount) => sum + amount);
    return max(0, double.parse((totalBudget - prizePool).toStringAsFixed(2)));
  }
}
