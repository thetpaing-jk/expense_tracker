import '../../data/models/lucky_draw_model.dart';

abstract class LuckyDrawRepository {
  Future<void> createDraw(LuckyDrawModel draw);
  Future<LuckyDrawModel?> getCurrentDraw();
  Future<void> drawTicket(int ticketId);
  Future<void> deleteDraw(int drawId);
}
