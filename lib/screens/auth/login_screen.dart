import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_theme.dart';
import 'package:get/route_manager.dart'; // ✅ Only routing
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../routes/app_pages.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // ✅ Add this
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final showPassword = ValueNotifier(false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo2.jpg'),

                  _buildInputField(
                    controller: phoneController,
                    hint: 'phone'.tr(),
                    keyboardType: TextInputType.phone,
                    icon: Icons.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'required_field'.tr();
                      }
                      // if (!RegExp(r'^07[789][0-9]{7}$').hasMatch(value)) {
                      //   return 'invalid_phone'.tr();
                      // }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  ValueListenableBuilder(
                    valueListenable: showPassword,
                    builder:
                        (_, value, __) => _buildInputField(
                          controller: passwordController,
                          hint: 'password'.tr(),
                          icon: Icons.lock,
                          isPassword: !value,
                          suffix: IconButton(
                            icon: Icon(
                              value ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => showPassword.value = !value,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'required_field'.tr();
                            }
                            if (value.length < 6) {
                              return 'password_too_short'.tr();
                            }
                            return null;
                          },
                        ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.forGotPassword),
                      child: Text('forgot_password'.tr()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthLoginSuccess) {
                        Get.offAllNamed(AppRoutes.home);
                      } else if (state is AuthLoginFailure) {
                        Get.snackbar("error".tr(), state.error);
                      }
                    },
                    builder: (context, state) {
                      return state is AuthLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;

                              final phone = phoneController.text.trim();
                              final password = passwordController.text.trim();
                              final lang =
                                  context.locale.languageCode; // 'en' or 'ar'

                              context.read<AuthCubit>().loginUser(
                                phone: phone,
                                password: password,
                                language: lang,
                              );
                            },
                            child: Text('login'.tr()),
                          );
                    },
                  ),

                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: Text("login_as_guest".tr()),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    child: Text("create_account".tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixIconColor: AppColors.primary,
        suffixIcon: suffix,
      ),
    );
  }
}
