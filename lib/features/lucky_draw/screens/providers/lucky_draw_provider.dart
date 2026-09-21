import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lucky_draw_model.dart';
import '../../domain/providers/lucky_draw_repository_provider.dart';
import '../../domain/usecases/lucky_draw_usecase.dart';
import 'lucky_draw_provider_state.dart';

typedef LuckyDrawNotifierProvider =
    NotifierProvider<LuckyDrawProvider, LuckyDrawState>;

final luckyDrawProvider = LuckyDrawNotifierProvider(() => LuckyDrawProvider());

class LuckyDrawProvider extends Notifier<LuckyDrawState> {
  LuckyDrawUsecase get usecase => ref.read(luckyDrawUsecase);

  @override
  LuckyDrawState build() => LuckyDrawInitialState();

  Future<void> createDraw(LuckyDrawModel draw) async {
    try {
      state = LuckyDrawLoadingState();
      await usecase.createDraw(draw);
      final createdDraw = await usecase.getCurrentDraw();
      if (createdDraw == null) {
        throw StateError('Lucky Draw could not be loaded after creation');
      }
      state = LuckyDrawReadyState(draw: createdDraw);
    } catch (error) {
      state = LuckyDrawErrorState(
        errorMessage: _friendlyMessage(error),
        systemErrorMessage: error.toString(),
      );
    }
  }

  Future<void> getCurrentDraw() async {
    try {
      state = LuckyDrawLoadingState();
      final draw = await usecase.getCurrentDraw();
      state = draw == null
          ? LuckyDrawInitialState()
          : LuckyDrawReadyState(draw: draw);
    } catch (error) {
      state = LuckyDrawErrorState(
        errorMessage: _friendlyMessage(error),
        systemErrorMessage: error.toString(),
      );
    }
  }

  Future<void> drawTicket(int ticketId) async {
    try {
      state = LuckyDrawLoadingState();
      await usecase.drawTicket(ticketId);
      final draw = await usecase.getCurrentDraw();
      if (draw == null) {
        throw StateError('Lucky Draw could not be refreshed');
      }
      state = LuckyDrawReadyState(draw: draw);
    } catch (error) {
      state = LuckyDrawErrorState(
        errorMessage: _friendlyMessage(error),
        systemErrorMessage: error.toString(),
      );
    }
  }

  Future<void> deleteDraw(int drawId) async {
    try {
      state = LuckyDrawLoadingState();
      await usecase.deleteDraw(drawId);
      state = LuckyDrawInitialState();
    } catch (error) {
      state = LuckyDrawErrorState(
        errorMessage: _friendlyMessage(error),
        systemErrorMessage: error.toString(),
      );
    }
  }
}

String _friendlyMessage(Object error) {
  return error
      .toString()
      .replaceFirst('Bad state: ', '')
      .replaceFirst('Exception: ', '');
}
