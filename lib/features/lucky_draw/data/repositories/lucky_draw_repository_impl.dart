import '../../domain/repositories/lucky_draw_repository.dart';
import '../datasource/lucky_draw_datasource.dart';
import '../models/lucky_draw_model.dart';

class LuckyDrawRepositoryImpl implements LuckyDrawRepository {
  final LuckyDrawDatasource datasource;

  LuckyDrawRepositoryImpl({required this.datasource});

  @override
  Future<void> createDraw(LuckyDrawModel draw) async {
    final amounts = draw.tickets.map((ticket) => ticket.amount).toList();
    await datasource.createDraw(draw, amounts);
  }

  @override
  Future<LuckyDrawModel?> getCurrentDraw() {
    return datasource.getCurrentDraw();
  }

  @override
  Future<List<LuckyDrawModel>> getDrawHistory() {
    return datasource.getDrawHistory();
  }

  @override
  Future<void> drawTicket(int ticketId) {
    return datasource.drawTicket(ticketId);
  }

  @override
  Future<void> deleteDraw(int drawId) {
    return datasource.deleteDraw(drawId);
  }
}
