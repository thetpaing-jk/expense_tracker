import '../../data/models/lucky_draw_model.dart';

sealed class LuckyDrawState {}

class LuckyDrawInitialState extends LuckyDrawState {}

class LuckyDrawLoadingState extends LuckyDrawState {}

class LuckyDrawReadyState extends LuckyDrawState {
  final LuckyDrawModel draw;

  LuckyDrawReadyState({required this.draw});
}

class LuckyDrawErrorState extends LuckyDrawState {
  final String errorMessage;
  final String systemErrorMessage;

  LuckyDrawErrorState({
    required this.errorMessage,
    required this.systemErrorMessage,
  });
}
