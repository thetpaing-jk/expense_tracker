import '../../../../core/database/database_service.dart';
import '../models/lucky_draw_model.dart';

const String luckyDrawTable = 'luckyDrawTable';
const String luckyDrawTicketTable = 'luckyDrawTicketTable';

abstract class LuckyDrawDatasource {
  Future<int> createDraw(LuckyDrawModel draw, List<double> amounts);
  Future<LuckyDrawModel?> getCurrentDraw();
  Future<List<LuckyDrawModel>> getDrawHistory();
  Future<void> drawTicket(int ticketId);
  Future<void> deleteDraw(int drawId);
}

class LuckyDrawDatasourceImpl implements LuckyDrawDatasource {
  final DatabaseService _databaseService;

  LuckyDrawDatasourceImpl({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService.instance;

  @override
  Future<int> createDraw(LuckyDrawModel draw, List<double> amounts) async {
    if (amounts.length != draw.days) {
      throw StateError('A ticket amount is required for every day');
    }

    final db = await _databaseService.database;
    return db.transaction((transaction) async {
      final activeDraws = await transaction.rawQuery(
        'SELECT d.id FROM $luckyDrawTable AS d '
        'WHERE EXISTS ('
        'SELECT 1 FROM $luckyDrawTicketTable AS t '
        'WHERE t.drawId = d.id AND t.drawn = 0'
        ') LIMIT 1',
      );
      if (activeDraws.isNotEmpty) {
        throw StateError('An active Lucky Draw already exists');
      }

      final drawId = await transaction.insert(luckyDrawTable, draw.toMap());
      for (var index = 0; index < amounts.length; index++) {
        await transaction.insert(luckyDrawTicketTable, {
          'drawId': drawId,
          'ticketNo': index + 1,
          'amount': amounts[index],
          'drawn': 0,
          'drawnAt': null,
        });
      }
      return drawId;
    });
  }

  @override
  Future<LuckyDrawModel?> getCurrentDraw() async {
    final db = await _databaseService.database;
    final draws = await db.query(
      luckyDrawTable,
      orderBy: 'createdAt DESC',
      limit: 1,
    );
    if (draws.isEmpty) return null;

    final drawId = draws.first['id'] as int;
    final ticketMaps = await db.query(
      luckyDrawTicketTable,
      where: 'drawId = ?',
      whereArgs: [drawId],
      orderBy: 'ticketNo ASC',
    );
    final tickets = ticketMaps.map(LuckyDrawTicket.fromMap).toList();
    return LuckyDrawModel.fromMap(draws.first, tickets: tickets);
  }

  @override
  Future<List<LuckyDrawModel>> getDrawHistory() async {
    final db = await _databaseService.database;
    final drawMaps = await db.query(luckyDrawTable, orderBy: 'createdAt DESC');
    final draws = <LuckyDrawModel>[];
    for (final drawMap in drawMaps) {
      final drawId = drawMap['id'] as int;
      final ticketMaps = await db.query(
        luckyDrawTicketTable,
        where: 'drawId = ? AND drawn = 1',
        whereArgs: [drawId],
        orderBy: 'drawnAt DESC',
      );
      draws.add(
        LuckyDrawModel.fromMap(
          drawMap,
          tickets: ticketMaps.map(LuckyDrawTicket.fromMap).toList(),
        ),
      );
    }
    return draws;
  }

  @override
  Future<void> drawTicket(int ticketId) async {
    final db = await _databaseService.database;
    await db.transaction((transaction) async {
      final ticketMaps = await transaction.query(
        luckyDrawTicketTable,
        where: 'id = ?',
        whereArgs: [ticketId],
        limit: 1,
      );
      if (ticketMaps.isEmpty) {
        throw StateError('Ticket was not found');
      }

      final selectedTicket = LuckyDrawTicket.fromMap(ticketMaps.first);
      if (selectedTicket.drawn) {
        throw StateError('This ticket has already been drawn');
      }

      final drawnTickets = await transaction.query(
        luckyDrawTicketTable,
        columns: ['drawnAt'],
        where: 'drawn = 1',
      );
      final today = DateTime.now();
      final alreadyDrewToday = drawnTickets.any((map) {
        final value = map['drawnAt'] as String?;
        final drawnAt = value == null
            ? null
            : DateTime.tryParse(value)?.toLocal();
        return drawnAt != null &&
            drawnAt.year == today.year &&
            drawnAt.month == today.month &&
            drawnAt.day == today.day;
      });
      if (alreadyDrewToday) {
        throw StateError('Already drew today!');
      }

      await transaction.update(
        luckyDrawTicketTable,
        {'drawn': 1, 'drawnAt': today.toIso8601String()},
        where: 'id = ?',
        whereArgs: [ticketId],
      );
    });
  }

  @override
  Future<void> deleteDraw(int drawId) async {
    final db = await _databaseService.database;
    await db.delete(luckyDrawTable, where: 'id = ?', whereArgs: [drawId]);
  }
}
