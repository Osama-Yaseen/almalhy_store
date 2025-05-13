import 'dart:convert';

import 'package:almalhy_store/models/cinfirmed_cart_model.dart';
import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:almalhy_store/screens/auth/location_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:almalhy_store/cubit/cart/cart_cubit.dart';
import 'package:almalhy_store/cubit/cart/cart_state.dart';
import 'package:almalhy_store/models/user_model.dart';
import 'package:almalhy_store/theme/app_theme.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});
  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late UserModel _user;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _notesCtrl;
  List<CartItem> _items = [];
  double? _lat;
  double? _lng;
  static const double _deliveryFee = 2.50;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    LocalStorageService.loadUser().then((user) {
      _user = user!;
      _phoneCtrl = TextEditingController(text: _user.phone);
      _addressCtrl = TextEditingController(text: _user.address);
      final state = context.read<CartCubit>().state;
      _items = state is CartLoaded ? state.items : [];
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAddress() async {
    final result = await Get.to<Map<String, dynamic>>(
      () => const LocationPickerScreen(),
    );
    if (result != null) {
      setState(() {
        _lat = result['lat'] as double;
        _lng = result['lng'] as double;
        final street = result['street'] as String;
        final building = result['building'] as String;
        final notes = result['notes'] as String;
        _addressCtrl.text = '$street, building $building\n$notes';
      });
    }
  }

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  double get _total => _subtotal + _deliveryFee;

  void _confirmPurchase() async {
    final updatedUser = _user.copyWith(
      phone: _phoneCtrl.text,
      address: _addressCtrl.text,
    );
    await LocalStorageService.updateStoredUser(updatedUser);

    final confirmed = ConfirmedCart(
      id: DateTime.now().millisecondsSinceEpoch,
      user: updatedUser,
      items: _items,
      notes: _notesCtrl.text,
      deliveryFee: _deliveryFee,
      date: DateTime.now(),
      status: 'pending',
    );
    await LocalStorageService.saveConfirmedCart(confirmed);

    context.read<CartCubit>().clear();

    // Show pending-order notification
    Get.snackbar(
      tr('order_pending_title'),
      tr('order_pending_message'),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 8,
      duration: const Duration(seconds: 4),
    );

    // Navigate back home
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(tr('invoice'))),
        body: Center(child: Text(tr('no_items'))),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(tr('invoice'))),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('customer_info'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _buildLabeledField(
              label: tr('phone'),
              controller: _phoneCtrl,
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: 8),
            // —————————————————————
            // Address picker row (clickable, same look)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('address'),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _pickAddress,
                  borderRadius: BorderRadius.circular(8),
                  child: AbsorbPointer(
                    // AbsorbPointer lets the field look normal but prevents text selection
                    child: TextField(
                      controller: _addressCtrl,
                      readOnly: true,
                      showCursor: false,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            _buildLabeledField(
              label: tr('notes'),
              controller: _notesCtrl,
              prefixIcon: Icons.note,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              tr('order_summary'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            ..._items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.name} x${item.quantity}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Text(
                      '${(item.product.price * item.quantity).toStringAsFixed(2)} JOD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            _buildTotalsRow(tr('subtotal'), _subtotal),
            _buildTotalsRow(tr('delivery_fee'), _deliveryFee),
            const Divider(height: 32),
            _buildTotalsRow(tr('total'), _total, isBold: true, fontSize: 22),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondery,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  tr('confirm_purchase'),
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap, // added onTap
  }) {
    final field = TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        if (onTap != null)
          GestureDetector(onTap: onTap, child: field)
        else
          field,
      ],
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
