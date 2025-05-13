import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:almalhy_store/models/cinfirmed_cart_model.dart';
import 'package:almalhy_store/theme/app_theme.dart';

/// A bottom-sheet popup showing the details of a confirmed cart/order
class InvoiceDetailSheet extends StatelessWidget {
  final ConfirmedCart cart;
  const InvoiceDetailSheet({required this.cart, super.key});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd(
      context.locale.languageCode,
    ).add_jm().format(cart.date);
    final items = cart.items;
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
    final total = subtotal + cart.deliveryFee;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '${tr('order')} #${cart.id}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(dateStr, style: const TextStyle(color: Colors.grey)),
          const Divider(height: 24),

          Text(
            tr('customer_info'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text('${tr('name')}: ${cart.user.name}'),
          const SizedBox(height: 4),
          Text('${tr('phone')}: ${cart.user.phone}'),
          const SizedBox(height: 4),
          Text('${tr('address')}: ${cart.user.address}'),

          const Divider(height: 32),
          Text(
            tr('order_summary'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} x${item.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${(item.product.price * item.quantity).toStringAsFixed(2)} JOD',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          _buildTotalsRow(tr('subtotal'), subtotal),
          _buildTotalsRow(tr('delivery_fee'), cart.deliveryFee),
          const Divider(height: 24),
          _buildTotalsRow(tr('total'), total, isBold: true, fontSize: 18),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                tr('close'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTotalsRow(
    String label,
    double value, {
    bool isBold = false,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} JOD',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
