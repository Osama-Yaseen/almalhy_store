import 'package:almalhy_store/cubit/static_page/static_page_state.dart';
import 'package:almalhy_store/services/static_page_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaticPageCubit extends Cubit<StaticPageState> {
  final StaticPageService service;

  StaticPageCubit(this.service) : super(StaticPageInitial());

  Future<void> loadPage(String endpoint) async {
    emit(StaticPageLoading());
    try {
      final data = await service.fetchPage(endpoint);
      emit(StaticPageLoaded(title: data['title'], content: data['content']));
    } catch (e) {
      emit(StaticPageError('فشل تحميل البيانات'));
    }
  }
}
