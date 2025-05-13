import 'dart:convert';

import 'package:almalhy_store/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:almalhy_store/models/user_model.dart';
import 'package:almalhy_store/models/city_model.dart';
import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = LocalStorageService.loadUser();
  }

  void _reload() {
    setState(() {
      _userFuture = LocalStorageService.loadUser();
    });
  }

  Future<String> _loadCityName(int cityId, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('KEY_CITIES');
    if (raw == null) return cityId.toString();
    final List<dynamic> list = jsonDecode(raw);
    final cities =
        list.map((e) => CityModel.fromJson(e as Map<String, dynamic>)).toList();
    final city = cities.firstWhere(
      (c) => c.id == cityId,
      orElse:
          () => CityModel(
            id: cityId,
            nameAr: cityId.toString(),
            nameEn: cityId.toString(),
          ),
    );
    return city.localizedName(context.locale.languageCode);
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('profile'.tr())),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('خطأ في تحميل الملف الشخصي'));
          }
          final user = snap.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoTile(Icons.phone, 'phone'.tr(), user.phone),
                const SizedBox(height: 12),
                _buildInfoTile(Icons.home, 'address'.tr(), user.address),
                const SizedBox(height: 12),
                FutureBuilder<String>(
                  future: _loadCityName(user.city_id, context),
                  builder: (ctx2, citySnap) {
                    final name =
                        citySnap.connectionState == ConnectionState.done
                            ? (citySnap.data ?? user.city_id.toString())
                            : '...';
                    return _buildInfoTile(
                      Icons.location_city,
                      'city'.tr(),
                      name,
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final updated =
                        await Get.toNamed(AppRoutes.editProfile) as bool?;
                    if (updated == true) _reload();
                  },
                  icon: const Icon(Icons.edit),
                  label: Text('edit_profile'.tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
