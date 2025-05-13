import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/services/auth_service.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('forgot_password'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('enter_registered_phone'.tr()),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'phone'.tr(),
                  border: const OutlineInputBorder(),
                ),
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

              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final phone = phoneController.text.trim();
                  final lang =
                      context.locale.languageCode; // or hard-code 'en'/'ar'

                  try {
                    var result = await AuthService().forgotPasswordPhone(
                      phone: phone,
                      lang: lang,
                    );

                    if (!context.mounted) return;

                    Get.snackbar(
                      "Messagme".tr(), // title
                      result['message'], // message
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColors.secondery.withOpacity(0.9),
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
                      icon: const Icon(Icons.location_on, color: Colors.white),
                      snackStyle: SnackStyle.FLOATING,
                      // optional blur behind
                      overlayBlur: 2,
                      overlayColor: Colors.black38,
                      duration: const Duration(seconds: 3),
                      forwardAnimationCurve: Curves.easeOutBack,
                    );

                    Get.toNamed(
                      AppRoutes.resetPassword,
                      arguments: {
                        "phone": phone,
                        "otp": result['otp'].toString(),
                      },
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text("error".tr()),
                            content: Text("unregistered_phone".tr()),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text("close".tr()),
                              ),
                            ],
                          ),
                    );
                  }
                },

                child: Text("next".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
