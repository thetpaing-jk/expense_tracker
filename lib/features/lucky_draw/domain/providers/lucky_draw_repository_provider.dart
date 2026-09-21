import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/lucky_draw_data_provider.dart';
import '../usecases/lucky_draw_usecase.dart';

final luckyDrawUsecase = Provider<LuckyDrawUsecase>((ref) {
  final repository = ref.read(luckyDrawRepositoryProvider);
  return LuckyDrawUsecase(repository: repository);
});
