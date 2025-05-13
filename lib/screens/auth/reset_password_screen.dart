import 'package:almalhy_store/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final phone = Get.arguments['phone'];
    final otp = Get.arguments['otp'];
    final otpController = TextEditingController(text: otp);
    final newPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("reset_password".tr())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text("enter_otp_sent_to".tr(args: [phone])),
              const SizedBox(height: 16),

              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "otp".tr(),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "required_field".tr()
                            : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "new_password".tr(),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.length < 6
                            ? "password_too_short".tr()
                            : null,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final newPassword = newPasswordController.text;
                  final lang =
                      context.locale.languageCode; // or hard-code 'en'/'ar'
                  try {
                    await AuthService().resetPassword(
                      phone: phone,
                      password: newPassword,
                      lang: lang,
                    );

                    if (!context.mounted) return;
                    Get.offAllNamed('/login');
                  } catch (e) {
                    if (!context.mounted) return;

                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text("error".tr()),
                            content: Text("invalid_otp_or_password".tr()),
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
                child: Text("reset_password_btn".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
