import 'package:almalhy_store/services/products_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:almalhy_store/cubit/product/product_state.dart';

class ProductCubit extends Cubit<ProductsState> {
  final ProductService productService;
  ProductCubit(this.productService) : super(ProductsInitial());

  /// Load products for category
  Future<void> loadProducts(int categoryId) async {
    emit(ProductsLoading());
    try {
      final products = await productService.getProductsByCategory(
        categoryId,
        'ar',
      );
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError("products_not_found".tr()));
    }
  }
}
