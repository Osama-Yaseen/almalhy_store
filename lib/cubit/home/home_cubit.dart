import 'package:almalhy_store/services/home_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService homeService;

  HomeCubit(this.homeService) : super(HomeInitial());

  void loadData(String lang) async {
    emit(HomeLoading());
    try {
      final categories = await homeService.getMainCategories();
      final allCategories = await homeService.getAllCategories();
      final brands = await homeService.getBrands();
      final banners = await homeService.getBanners(lang);
      emit(
        HomeLoaded(
          allCategories: allCategories,
          categories: categories,
          brands: brands,
          banners: banners,
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load home data'));
    }
  }
}
