import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/lucky_draw_repository.dart';
import '../datasource/lucky_draw_datasource.dart';
import '../repositories/lucky_draw_repository_impl.dart';

final luckyDrawDatasourceProvider = Provider<LuckyDrawDatasource>((ref) {
  return LuckyDrawDatasourceImpl();
});

final luckyDrawRepositoryProvider = Provider<LuckyDrawRepository>((ref) {
  final datasource = ref.read(luckyDrawDatasourceProvider);
  return LuckyDrawRepositoryImpl(datasource: datasource);
});
