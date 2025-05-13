import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/route_manager.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  String _pickedAddress = "";

  final TextEditingController _streetCtrl = TextEditingController();
  final TextEditingController _buildingCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    // 1) permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return;
    }

    // 2) get current position
    final pos = await Geolocator.getCurrentPosition();
    final latLng = LatLng(pos.latitude, pos.longitude);

    // 3) reverse‐geocode
    final pms = await geocoding.placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    final pm = pms.first;

    // 4) update state
    setState(() {
      _pickedLocation = latLng;
      _pickedAddress = "${pm.street} - ${pm.subLocality}";
      _streetCtrl.text = pm.street ?? "";
    });

    // 5) move camera to current loc
    _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  Future<void> _onMapTap(LatLng pos) async {
    final pms = await geocoding.placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    final pm = pms.first;

    setState(() {
      _pickedLocation = pos;
      _pickedAddress = "${pm.street} - ${pm.subLocality}";
      _streetCtrl.text = pm.street ?? "";
    });
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _buildingCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("delivery_info".tr())),
      body: Column(
        children: [
          // ————————————————
          // 1) The Map
          Expanded(
            child: GoogleMap(
              onMapCreated: (ctrl) => _mapController = ctrl,
              initialCameraPosition: const CameraPosition(
                target: LatLng(31.9539, 35.9106), // fallback center
                zoom: 15,
              ),
              onTap: _onMapTap,
              markers:
                  _pickedLocation != null
                      ? {
                        Marker(
                          markerId: const MarkerId("picked"),
                          position: _pickedLocation!,
                        ),
                      }
                      : {},
            ),
          ),

          // ————————————————
          // 2) The form fields
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "map_instruction".tr(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                // Street name
                TextField(
                  controller: _streetCtrl,
                  decoration: InputDecoration(
                    labelText: "street_name".tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Building number
                TextField(
                  controller: _buildingCtrl,
                  decoration: InputDecoration(
                    labelText: "building_number".tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Notes
                TextField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(
                    labelText: "notes".tr(),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _pickedLocation == null
                            ? null
                            : () {
                              Get.back(
                                result: {
                                  'lat': _pickedLocation!.latitude,
                                  'lng': _pickedLocation!.longitude,
                                  'street': _streetCtrl.text,
                                  'building': _buildingCtrl.text,
                                  'notes': _notesCtrl.text,
                                },
                              );
                            },
                    child: Text("save".tr()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
