import 'dart:convert';

import 'package:almalhy_store/models/user_model.dart';
import 'package:almalhy_store/models/city_model.dart';
import 'package:almalhy_store/screens/auth/location_picker_screen.dart';
import 'package:almalhy_store/services/local_storgae_service.dart';
import 'package:almalhy_store/theme/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  //late TextEditingController _phoneCtrl;

  String? _address;
  double? _lat, _lng;

  List<CityModel> _cities = [];
  CityModel? _selectedCity;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authResp = await LocalStorageService.getAuthResponse();
    final user = authResp?.user;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('KEY_CITIES') ?? '[]';
    final list = jsonDecode(raw) as List<dynamic>;
    _cities =
        list.map((e) => CityModel.fromJson(e as Map<String, dynamic>)).toList();

    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    // _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _address = user?.address;

    _selectedCity =
        _cities.isNotEmpty
            ? _cities.firstWhere(
              (c) => c.id == (user?.city_id ?? -1),
              orElse: () => _cities.first,
            )
            : null;

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    //_phoneCtrl.dispose();
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
        _address = '$street, building $building\n$notes';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authResp = await LocalStorageService.getAuthResponse();
    final user = authResp?.user;
    final token = authResp?.token;
    if (user == null || token == null) return;

    final url =
        'https://store-api.almalhy.com/public/api/v1/ar/update-profile/${user.id}';
    final body = {
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': user.phone, //_phoneCtrl.text.trim(),
      'address': _address ?? '',
      'city_id': _selectedCity?.id.toString() ?? '',
      if (_lat != null) 'lat': _lat.toString(),
      if (_lng != null) 'lng': _lng.toString(),
    };

    setState(() => _loading = true);
    try {
      final resp = await Dio().post(
        url,
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (resp.statusCode == 200) {
        final dataMap =
            (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        final updatedUser = UserModel.fromJson(dataMap);

        // helper to replace only the `user` in AuthResponse:
        await LocalStorageService.updateStoredUser(updatedUser);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('profile_updated'.tr())));
        Get.back(result: true);
      } else {
        throw Exception('Unexpected status: ${resp.statusCode}');
      }
    } on DioError catch (e) {
      final msg =
          e.response?.statusCode == 405
              ? 'wrong_method'.tr()
              : e.response?.data['message'] ?? e.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('edit_profile'.tr())),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'name'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'required'.tr();
                  final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return pattern.hasMatch(v) ? null : 'invalid_email'.tr();
                },
              ),
              const SizedBox(height: 12),

              // // Phone
              // TextFormField(
              //   controller: _phoneCtrl,
              //   decoration: InputDecoration(
              //     labelText: 'Phone'.tr(),
              //     border: const OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.phone,
              //   validator:
              //       (v) => v == null || v.isEmpty ? 'required'.tr() : null,
              // ),
              // const SizedBox(height: 12),

              // City dropdown
              DropdownButtonFormField<CityModel>(
                value: _selectedCity,
                items:
                    _cities.map((c) {
                      final name = c.localizedName(context.locale.languageCode);
                      return DropdownMenuItem(value: c, child: Text(name));
                    }).toList(),
                decoration: InputDecoration(
                  labelText: 'city'.tr(),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (c) => setState(() => _selectedCity = c),
                validator:
                    (_) => _selectedCity == null ? 'required'.tr() : null,
              ),
              const SizedBox(height: 12),

              // Address picker
              InkWell(
                onTap: _pickAddress,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'address'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    _address ?? 'tap_to_select'.tr(),
                    style: TextStyle(
                      color: _address == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text('save'.tr()),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
