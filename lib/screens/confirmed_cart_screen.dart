import 'package:almalhy_store/screens/invoice_Details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:almalhy_store/models/cinfirmed_cart_model.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:almalhy_store/routes/app_pages.dart';

/// Possible statuses for orders
enum OrderStatus { pending, confirmed, delivered, canceled }

extension OrderStatusExtension on OrderStatus {
  /// Translation key for this status
  String get key => 'status_${name}';

  /// Create enum from raw string
  static OrderStatus fromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'delivered':
        return OrderStatus.delivered;
      case 'canceled':
        return OrderStatus.canceled;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}

/// Screen that displays a list of all confirmed carts/orders saved locally
class ConfirmedCartsScreen extends StatelessWidget {
  const ConfirmedCartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(tr('orders_history'))),
      body: FutureBuilder<List<ConfirmedCart>>(
        future: LocalStorageService.loadConfirmedCarts(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(tr('load_error')));
          }
          final carts = snap.data ?? [];
          if (carts.isEmpty) {
            return Center(child: Text(tr('no_orders')));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: carts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cart = carts[index];
              final dateStr = DateFormat.yMMMd(
                context.locale.languageCode,
              ).add_jm().format(cart.date);
              final statusEnum = OrderStatusExtension.fromString(cart.status);
              final total =
                  cart.items.fold<double>(
                    0,
                    (sum, item) => sum + item.product.price * item.quantity,
                  ) +
                  cart.deliveryFee;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => InvoiceDetailSheet(cart: cart),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${tr('order')} #${cart.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              '${total.toStringAsFixed(2)} JOD',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateStr,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(
                            tr(statusEnum.key),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _statusColor(statusEnum),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Choose a color for each status
  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return Colors.green;
      case OrderStatus.delivered:
        return Colors.blue;
      case OrderStatus.canceled:
        return Colors.red;
      case OrderStatus.pending:
      default:
        return Colors.orange;
    }
  }
}
