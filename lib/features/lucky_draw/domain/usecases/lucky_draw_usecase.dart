import '../../data/models/lucky_draw_model.dart';
import '../repositories/lucky_draw_repository.dart';

class LuckyDrawUsecase {
  final LuckyDrawRepository repository;

  LuckyDrawUsecase({required this.repository});

  Future<void> createDraw(LuckyDrawModel draw) {
    return repository.createDraw(draw);
  }

  Future<LuckyDrawModel?> getCurrentDraw() {
    return repository.getCurrentDraw();
  }

  Future<List<LuckyDrawModel>> getDrawHistory() {
    return repository.getDrawHistory();
  }

  Future<void> drawTicket(int ticketId) {
    return repository.drawTicket(ticketId);
  }

  Future<void> deleteDraw(int drawId) {
    return repository.deleteDraw(drawId);
  }
}
