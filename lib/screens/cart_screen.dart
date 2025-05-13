// lib/presentation/screens/cart_screen.dart

import 'package:almalhy_store/cubit/cart/cart_cubit.dart';
import 'package:almalhy_store/cubit/cart/cart_state.dart';
import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const double _deliveryFee = 2.50;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final isEmpty =
            state is CartEmpty || (state is CartLoaded && state.items.isEmpty);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(tr('cart')),
            backgroundColor: AppColors.primary,
            elevation: 1,
          ),
          body:
              isEmpty
                  ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: AppColors.secondery,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tr('cart_empty'),
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.secondery,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: (state as CartLoaded).items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final item = state.items[i];
                      final p = item.product;
                      final qty = item.quantity;
                      final lineTotal = p.price * qty;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child:
                                      p.picture != null
                                          ? Image.network(
                                            p.picture!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) => const Icon(
                                                  Icons.broken_image,
                                                ),
                                          )
                                          : const Icon(
                                            Icons.image_not_supported,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${p.price.toStringAsFixed(2)} JOD × $qty',
                                      style: textTheme.bodySmall,
                                    ),
                                    Text(
                                      '${lineTotal.toStringAsFixed(2)} JOD',
                                      style: textTheme.titleSmall?.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.secondery.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      color: AppColors.secondery,
                                      onPressed:
                                          () => context
                                              .read<CartCubit>()
                                              .decrement(p),
                                    ),
                                    Text('$qty', style: textTheme.titleMedium),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      color: AppColors.secondery,
                                      onPressed:
                                          qty < p.quantity
                                              ? () => context
                                                  .read<CartCubit>()
                                                  .increment(p)
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          bottomNavigationBar:
              isEmpty
                  ? null
                  : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Subtotal & Delivery Fee
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr('subtotal'),
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(state as CartLoaded).totalPrice.toStringAsFixed(2)} JOD',
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr('delivery_fee'),
                                  style: textTheme.bodySmall,
                                ),
                                Text(
                                  '${_deliveryFee.toStringAsFixed(2)} JOD',
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // Grand Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tr('total'),
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${((state).totalPrice + _deliveryFee).toStringAsFixed(2)} JOD',
                                  style: textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.payment),
                                label: Text(tr('proceed_payment')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondery,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                onPressed: () => Get.toNamed(AppRoutes.invoice),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
