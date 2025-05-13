import 'dart:async';
import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../routes/app_pages.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () async {
      // You can later check login status from local storage
      final token = await LocalStorageService.getToken();

      if (token == null || token.isEmpty) {
        // no token saved → not logged in
        Get.offAllNamed(AppRoutes.login);
      } else {
        // token exists → logged in
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo2.jpg'),
            const SizedBox(height: 24),
            LoadingAnimationWidget.inkDrop(color: AppColors.primary, size: 50),
          ],
        ),
      ),
    );
  }
}
