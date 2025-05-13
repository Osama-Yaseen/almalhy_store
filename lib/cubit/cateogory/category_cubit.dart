import 'package:almalhy_store/cubit/cateogory/category_state.dart';
import 'package:almalhy_store/services/home_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final HomeService api;
  CategoryCubit(this.api) : super(CategoryInitial());

  Future<void> loadSubCategories(int parentId) async {
    emit(CategoryLoading());
    try {
      final subs = await api.getSubCategories(parentId, 'ar');
      emit(CategoryLoaded(subs));
    } catch (e) {
      emit(CategoryError('failed_to_load_sub_categories'.tr()));
    }
  }
}
