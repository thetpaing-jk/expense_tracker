import 'dart:math';

import 'package:expense_tracker/features/lucky_draw/data/models/lucky_draw_model.dart';
import 'package:expense_tracker/features/lucky_draw/data/providers/lucky_draw_data_provider.dart';
import 'package:expense_tracker/features/lucky_draw/domain/repositories/lucky_draw_repository.dart';
import 'package:expense_tracker/features/lucky_draw/domain/usecases/lucky_draw_generator.dart';
import 'package:expense_tracker/features/lucky_draw/screens/providers/lucky_draw_provider.dart';
import 'package:expense_tracker/features/lucky_draw/screens/providers/lucky_draw_provider_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLuckyDrawRepository implements LuckyDrawRepository {
  LuckyDrawModel? currentDraw;

  @override
  Future<void> createDraw(LuckyDrawModel draw) async {
    currentDraw = LuckyDrawModel(
      id: 1,
      totalBudget: draw.totalBudget,
      period: draw.period,
      days: draw.days,
      minBudget: draw.minBudget,
      maxBudget: draw.maxBudget,
      savedMoney: draw.savedMoney,
      tickets: [
        for (var index = 0; index < draw.tickets.length; index++)
          draw.tickets[index].copyWith(id: index + 1, drawId: 1),
      ],
      createdAt: draw.createdAt,
    );
  }

  @override
  Future<void> deleteDraw(int drawId) async {
    currentDraw = null;
  }

  @override
  Future<void> drawTicket(int ticketId) async {
    final draw = currentDraw!;
    currentDraw = draw.copyWith(
      tickets: draw.tickets.map((ticket) {
        return ticket.id == ticketId
            ? ticket.copyWith(drawn: true, drawnAt: DateTime.now())
            : ticket;
      }).toList(),
    );
  }

  @override
  Future<LuckyDrawModel?> getCurrentDraw() async => currentDraw;
}

void main() {
  test(
    'generator creates one valid ticket per day within the total budget',
    () {
      final amounts = LuckyDrawGenerator.generate(
        totalBudget: 4000,
        days: 30,
        minBudget: 30,
        maxBudget: 100,
        random: Random(7),
      );

      expect(amounts, hasLength(30));
      expect(amounts.every((amount) => amount >= 30 && amount <= 100), isTrue);
      expect(
        amounts.fold<double>(0, (sum, amount) => sum + amount),
        lessThanOrEqualTo(4000),
      );
      expect(
        LuckyDrawGenerator.savedMoney(4000, amounts),
        closeTo(
          4000 - amounts.fold<double>(0, (sum, amount) => sum + amount),
          0.01,
        ),
      );
    },
  );

  test('generator rejects a minimum greater than the maximum', () {
    expect(
      () => LuckyDrawGenerator.generate(
        totalBudget: 100,
        days: 2,
        minBudget: 51,
        maxBudget: 50,
      ),
      throwsArgumentError,
    );
  });

  test('generator reserves the minimum budget for every remaining ticket', () {
    final amounts = LuckyDrawGenerator.generate(
      totalBudget: 10,
      days: 4,
      minBudget: 2,
      maxBudget: 2.5,
      random: Random(3),
    );

    expect(amounts, hasLength(4));
    expect(amounts.every((amount) => amount >= 2 && amount <= 2.5), isTrue);
    expect(
      amounts.fold<double>(0, (sum, amount) => sum + amount),
      lessThanOrEqualTo(10),
    );
  });

  test('provider creates and draws a ticket through the usecase', () async {
    final repository = _FakeLuckyDrawRepository();
    final container = ProviderContainer(
      overrides: [luckyDrawRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    const tickets = [
      LuckyDrawTicket(id: 0, drawId: 0, ticketNo: 1, amount: 25),
    ];
    final draw = LuckyDrawModel(
      id: 0,
      totalBudget: 100,
      period: 'custom',
      days: 1,
      maxBudget: 25,
      savedMoney: 75,
      tickets: tickets,
      createdAt: DateTime(2026),
    );

    await container.read(luckyDrawProvider.notifier).createDraw(draw);
    expect(container.read(luckyDrawProvider), isA<LuckyDrawReadyState>());

    await container.read(luckyDrawProvider.notifier).drawTicket(1);
    final state = container.read(luckyDrawProvider) as LuckyDrawReadyState;
    expect(state.draw.tickets.single.drawn, isTrue);
    expect(state.draw.todayTicket?.amount, 25);
  });

  test('ticketDrawnOn returns only the ticket drawn on the requested day', () {
    final draw = LuckyDrawModel(
      id: 1,
      totalBudget: 100,
      period: 'custom',
      days: 2,
      maxBudget: 50,
      savedMoney: 0,
      tickets: [
        LuckyDrawTicket(
          id: 1,
          drawId: 1,
          ticketNo: 1,
          amount: 40,
          drawn: true,
          drawnAt: DateTime(2026, 9, 20, 10),
        ),
        const LuckyDrawTicket(id: 2, drawId: 1, ticketNo: 2, amount: 60),
      ],
      createdAt: DateTime(2026, 9, 20),
    );

    expect(draw.ticketDrawnOn(DateTime(2026, 9, 20))?.amount, 40);
    expect(draw.ticketDrawnOn(DateTime(2026, 9, 21)), isNull);
  });
}
