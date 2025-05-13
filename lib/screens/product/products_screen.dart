import 'package:almalhy_store/cubit/cart/cart_cubit.dart';
import 'package:almalhy_store/cubit/cart/cart_state.dart';
import 'package:almalhy_store/cubit/product/product_cubit.dart';
import 'package:almalhy_store/cubit/product/product_state.dart';
import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final int categoryId = args['categoryId'] as int;
    final String title = args['categoryTitle'] as String;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => ProductCubit(ctx.read())..loadProducts(categoryId),
        ),
      ],
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          final cartMap = <int, int>{};
          int badgeCount = 0;
          if (cartState is CartLoaded) {
            for (final item in cartState.items) {
              cartMap[item.product.id] = item.quantity;
              badgeCount += item.quantity;
            }
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () => Get.toNamed(AppRoutes.cart),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: BlocBuilder<ProductCubit, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductsLoaded) {
                  final products = state.products;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final inCartQty = cartMap[p.id] ?? 0;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Builder(
                                  builder: (ctx) {
                                    final url = p.picture;
                                    if (url == null || url.isEmpty) {
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      );
                                    }
                                    return Image.network(
                                      url,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (ctx, err, stack) {
                                        return const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${p.price.toStringAsFixed(2)} JOD',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (inCartQty == 0) ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final token =
                                          await LocalStorageService.getToken();
                                      if (token == null || token.isEmpty) {
                                        Get.snackbar(
                                          'error'.tr(),
                                          'please_sign_in_add_products'.tr(),
                                          snackPosition: SnackPosition.TOP,
                                          backgroundColor: AppColors.secondery
                                              .withOpacity(0.9),
                                          colorText: Colors.white,
                                          borderRadius: 12,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                          icon: const Icon(
                                            Icons.login,
                                            color: Colors.white,
                                          ),
                                          snackStyle: SnackStyle.FLOATING,
                                          duration: const Duration(seconds: 3),
                                        );
                                        Get.toNamed(AppRoutes.login);
                                        return;
                                      }
                                      context.read<CartCubit>().add(p);
                                    },
                                    child: Text(context.tr('add')),
                                  ),
                                ),
                              ] else ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed:
                                          () => context
                                              .read<CartCubit>()
                                              .decrement(p),
                                    ),
                                    Text('$inCartQty'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed:
                                          inCartQty < p.quantity
                                              ? () async {
                                                final token =
                                                    await LocalStorageService.getToken();
                                                if (token == null ||
                                                    token.isEmpty) {
                                                  Get.snackbar(
                                                    'error'.tr(),
                                                    'please_sign_in_add_products'
                                                        .tr(),
                                                    snackPosition:
                                                        SnackPosition.TOP,
                                                    backgroundColor: AppColors
                                                        .secondery
                                                        .withOpacity(0.9),
                                                    colorText: Colors.white,
                                                    borderRadius: 12,
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 24,
                                                          vertical: 16,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 16,
                                                        ),
                                                    icon: const Icon(
                                                      Icons.login,
                                                      color: Colors.white,
                                                    ),
                                                    snackStyle:
                                                        SnackStyle.FLOATING,
                                                    duration: const Duration(
                                                      seconds: 3,
                                                    ),
                                                  );
                                                  Get.toNamed(AppRoutes.login);
                                                  return;
                                                }
                                                context
                                                    .read<CartCubit>()
                                                    .increment(p);
                                              }
                                              : null,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ProductsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
