import 'package:almalhy_store/routes/app_pages.dart';
import 'package:almalhy_store/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/route_manager.dart';

class OtpScreen extends StatelessWidget {
  final String phone;

  final String? otp;

  const OtpScreen({super.key, required this.phone, this.otp});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: otp);

    return Scaffold(
      appBar: AppBar(title: Text("confirm_phone".tr())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("enter_otp_sent".tr()),
              Text(
                "+962$phone",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "otp_code".tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "required_field".tr();
                  }
                  if (value.length < 4) {
                    return "invalid_code".tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final code = codeController.text.trim();
                  final lang =
                      context.locale.languageCode; // or hard-code 'en'/'ar'

                  try {
                    // 1️⃣ call your service
                    final authResp = await AuthService().verifySignUpOtp(
                      phone: phone,
                      otp: code,
                      lang: lang,
                    );

                    Get.snackbar("Message".tr(), authResp);

                    // 3️⃣ navigate on success
                    Get.offAllNamed(AppRoutes.home);
                  } catch (e) {
                    // 4️⃣ handle errors (e.message or e.toString())
                    Get.snackbar(
                      "Error",
                      e.toString(),
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Text("confirm_btn".tr()),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // TODO: Resend logic
                },
                child: Text("resend_code".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
