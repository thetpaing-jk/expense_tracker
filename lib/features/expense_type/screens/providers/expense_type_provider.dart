import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../expense/screens/providers/expense_provider.dart';
import '../../data/models/expense_type_model.dart';
import '../../domain/providers/expense_repository_provider.dart';
import '../../domain/usecases/expense_type_usecase.dart';
import 'expense_type_provider_state.dart';

final expneseIconProvider = StateProvider<String>((ref) => "bus");

final expenseTypeChooseProvider = StateProvider<ExpenseTypeModel?>(
  (ref) => null,
);

final expneseIconColor = StateProvider<MaterialColor>((ref) => Colors.yellow);

final expenseTypeByIdProvider = FutureProvider.family<ExpenseTypeModel?, int>((
  ref,
  typeId,
) {
  final usecase = ref.read(expenseTypeUsecaseProvider);
  return usecase.getTypebyId(typeId);
});

final expenseTypeListProvider = FutureProvider<List<ExpenseTypeModel>>((ref) {
  return ref.read(expenseTypeUsecaseProvider).getAllType();
});

final expenseTypeProvider = ExpenseTypeNotifierProvider(() {
  return ExpenseTypeNotifier();
});

typedef ExpenseTypeNotifierProvider =
    NotifierProvider<ExpenseTypeNotifier, ExpenseTypeProviderState>;

class ExpenseTypeNotifier extends Notifier<ExpenseTypeProviderState> {
  ExpenseTypeUsecase get usecase => ref.read(expenseTypeUsecaseProvider);
  @override
  ExpenseTypeProviderState build() {
    return ExpenseTypeFormState();
  }

  Future<void> createType(ExpenseTypeModel type) async {
    try {
      state = ExpenseTypeLoadingState(type: "create");
      await usecase.createType(type);
      List<ExpenseTypeModel> expenseList = await usecase.getAllType();
      ref.invalidate(expenseTypeListProvider);
      state = ExpenseTypeReadyState(
        expenseList: expenseList,
        message: "Successfully Created",
      );
    } catch (e) {
      state = ExpenseTypeErrorState(
        errorMessage: e.toString().replaceAll("Exception ", ""),
      );
    }
  }

  Future<void> getAllType() async {
    try {
      state = ExpenseTypeLoadingState(type: "getAllType");
      List<ExpenseTypeModel> expenseTypeList = await usecase.getAllType();
      state = ExpenseTypeReadyState(
        expenseList: expenseTypeList,
        message: "Successfully Fetched",
      );
    } catch (e) {
      state = ExpenseTypeErrorState(
        errorMessage: e.toString().replaceAll("Exception ", ""),
      );
    }
  }

  Future<void> editType(ExpenseTypeModel type) async {
    try {
      state = ExpenseTypeLoadingState(type: "edit");
      await usecase.editType(type);
      List<ExpenseTypeModel> expenseList = await usecase.getAllType();
      ref.invalidate(expenseTypeListProvider);
      state = ExpenseTypeReadyState(
        expenseList: expenseList,
        message: "Successfully Edited",
      );
    } catch (e) {
      state = ExpenseTypeErrorState(
        errorMessage: e.toString().replaceAll("Exception ", ""),
      );
    }
  }

  Future<void> deleteType(int id) async {
    final previousState = state;
    try {
      if (previousState is ExpenseTypeReadyState) {
        state = ExpenseTypeReadyState(
          expenseList: previousState.expenseList
              .where((expenseType) => expenseType.id != id)
              .toList(),
          message: "Successfully Deleted",
        );
      }
      await usecase.deleteType(id);
      ref.invalidate(expenseTypeListProvider);
      ref.invalidate(expenseListProvider);
      await ref.read(expenseProvider.notifier).getAllExpense();
    } catch (e) {
      state = previousState;
      state = ExpenseTypeErrorState(
        errorMessage: e.toString().replaceAll("Exception ", ""),
      );
    }
  }

  Future<void> getTypebyId(int typeId) async {
    try {
      state = ExpenseTypeLoadingState(type: "getTypeById");
      ExpenseTypeModel? expenseTypeModel = await usecase.getTypebyId(typeId);
      if (expenseTypeModel != null) {
        state = ExpenseTypeReadyState(
          expenseList: [expenseTypeModel],
          message: "",
        );
      }
    } catch (e) {
      state = ExpenseTypeErrorState(
        errorMessage: e.toString().replaceAll("Exception", ""),
      );
    }
  }
}
