import '../../models/category_model.dart';
import '../../models/brand_model.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<CategoryModel> allCategories;
  final List<BrandModel> brands;
  final List<String> banners;

  HomeLoaded({
    required this.categories,
    required this.allCategories,
    required this.brands,
    required this.banners,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
