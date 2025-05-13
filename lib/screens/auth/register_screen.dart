import 'package:almalhy_store/cubit/auth/auth_cubit.dart';
import 'package:almalhy_store/cubit/auth/auth_state.dart';
import 'package:almalhy_store/cubit/cities/cities_cubit.dart';
import 'package:almalhy_store/cubit/cities/cities_state.dart';
import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart' show GetUtils;
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _salesCodeCtrl = TextEditingController();

  int? _selectedCityId;
  String? _selectedAddress;
  LatLng? _selectedLatLng;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _salesCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('create_account'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'welcome_message'.tr(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text('register_instruction'.tr()),
              const SizedBox(height: 24),

              // Phone
              _buildInput(
                controller: _phoneCtrl,
                label: 'phone'.tr(),
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator:
                    (v) =>
                        v == null || v.isEmpty ? 'required_field'.tr() : null,
              ),
              const SizedBox(height: 12),

              // Username
              _buildInput(
                controller: _nameCtrl,
                label: 'username'.tr(),
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'required_field'.tr() : null,
              ),
              const SizedBox(height: 12),

              // Email (required)
              _buildInput(
                controller: _emailCtrl,
                label: 'email'.tr(), // use the normal “Email” label
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    // now require non-empty
                    return 'required'.tr();
                  }
                  if (!GetUtils.isEmail(v)) {
                    // still validate format
                    return 'invalid_email'.tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Password
              _buildInput(
                controller: _passwordCtrl,
                label: 'password'.tr(),
                icon: Icons.lock,
                isPassword: true,
                validator:
                    (v) => v!.length < 6 ? 'password_too_short'.tr() : null,
              ),
              const SizedBox(height: 12),

              // Confirm Password
              _buildInput(
                controller: _confirmPasswordCtrl,
                label: 'confirm_password'.tr(),
                icon: Icons.lock_outline,
                isPassword: true,
                validator:
                    (v) =>
                        v != _passwordCtrl.text
                            ? 'passwords_not_match'.tr()
                            : null,
              ),
              const SizedBox(height: 12),

              // Sales Code
              _buildInput(
                controller: _salesCodeCtrl,
                label: 'sales_code'.tr(),
                icon: Icons.code,
              ),
              const SizedBox(height: 12),

              // City dropdown
              BlocBuilder<CitiesCubit, CitiesState>(
                builder: (context, state) {
                  if (state is CitiesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CitiesLoaded) {
                    final lang = context.locale.languageCode;
                    return DropdownButtonFormField<int>(
                      value: _selectedCityId,
                      decoration: InputDecoration(
                        labelText: 'select_area'.tr(),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                          state.cities
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.localizedName(lang)),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (id) => setState(() {
                            _selectedCityId = id;
                          }),
                      validator:
                          (v) => v == null ? 'required_field'.tr() : null,
                    );
                  } else if (state is CitiesError) {
                    return Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),

              // Location picker
              Row(
                children: [
                  const Icon(Icons.edit_location_alt, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('choose_delivery_location'.tr()),
                  TextButton(
                    onPressed: () async {
                      final result = await Get.toNamed(
                        AppRoutes.locationPicker,
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        // Combine street, building & notes
                        final street = (result['street'] as String?) ?? '';
                        final building = (result['building'] as String?) ?? '';
                        final notes = (result['notes'] as String?) ?? '';
                        final parts = <String>[];
                        if (street.isNotEmpty) parts.add(street);
                        if (building.isNotEmpty) {
                          parts.add('Building: $building');
                        }
                        if (notes.isNotEmpty) parts.add('Notes: $notes');

                        setState(() {
                          _selectedAddress = parts.join(', ');
                          _selectedLatLng = LatLng(
                            (result['lat'] as num).toDouble(),
                            (result['lng'] as num).toDouble(),
                          );
                        });
                      }
                    },
                    child: Text(
                      'tap_here'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Show picked address
              if (_selectedAddress != null && _selectedAddress!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '📍 $_selectedAddress',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),

              const SizedBox(height: 12),

              // Submit
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthRegisterSuccess) {
                    Get.toNamed(
                      AppRoutes.verifyOtp,
                      arguments: {
                        'phone': _phoneCtrl.text,
                        'otp': state.user.otp.toString(),
                      },
                    );
                  } else if (state is AuthRegisterFailure) {
                    Get.snackbar("error".tr(), state.error);
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 1) Location required
                        if (_selectedAddress == null) {
                          Get.snackbar(
                            'error'.tr(), // title
                            'please_select_location'.tr(), // message
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: AppColors.secondery.withOpacity(
                              0.9,
                            ),
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
                              Icons.location_on,
                              color: Colors.white,
                            ),
                            snackStyle: SnackStyle.FLOATING,
                            // optional blur behind
                            overlayBlur: 2,
                            overlayColor: Colors.black38,
                            duration: const Duration(seconds: 3),
                            forwardAnimationCurve: Curves.easeOutBack,
                          );
                          return;
                        }

                        // 2) Validate all other fields
                        if (!_formKey.currentState!.validate()) return;

                        // 3) Proceed with registration
                        context.read<AuthCubit>().registerUser(
                          name: _nameCtrl.text,
                          email: _emailCtrl.text,
                          phone: _phoneCtrl.text,
                          password: _passwordCtrl.text,
                          cityId: _selectedCityId!,
                          invitedByCode: _salesCodeCtrl.text,
                          address: _selectedAddress,
                          lat: _selectedLatLng?.latitude,
                          lng: _selectedLatLng?.longitude,
                        );
                      },
                      child: Text('create_account'.tr()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Icon(icon),
        prefixIconColor: AppColors.primary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
