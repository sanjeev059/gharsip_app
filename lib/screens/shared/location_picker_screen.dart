import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PickedAddress {
  final double lat;
  final double lng;
  final String streetAddress;
  final String city;
  final String state;
  final String pincode;
  final String flatNo;
  final String landmark;

  const PickedAddress({
    required this.lat,
    required this.lng,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.flatNo,
    required this.landmark,
  });

  String get display => [
    if (flatNo.isNotEmpty) flatNo,
    if (streetAddress.isNotEmpty) streetAddress,
    if (landmark.isNotEmpty) 'Near $landmark',
    if (city.isNotEmpty) city,
  ].join(', ');

  String get addressLine => [
    if (flatNo.isNotEmpty) flatNo,
    if (streetAddress.isNotEmpty) streetAddress,
  ].where((s) => s.isNotEmpty).join(', ');
}

class LocationPickerScreen extends StatefulWidget {
  final PickedAddress? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapCtrl = MapController();
  LatLng _center = const LatLng(12.9716, 77.5946);
  String _streetAddr = '';
  String _city = '';
  String _state = '';
  String _pincode = '';
  bool _geocoding = false;
  bool _locating = false;
  Timer? _debounce;
  final _flatCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  static const _green = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final i = widget.initial!;
      _center = LatLng(i.lat, i.lng);
      _streetAddr = i.streetAddress;
      _city = i.city;
      _state = i.state;
      _pincode = i.pincode;
      _flatCtrl.text = i.flatNo;
      _landmarkCtrl.text = i.landmark;
    } else {
      _goToCurrentLocation();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _flatCtrl.dispose();
    _landmarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() => _locating = false);
        await _reverseGeocode(_center);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapCtrl.move(ll, 16);
      setState(() { _center = ll; _locating = false; });
      await _reverseGeocode(ll);
    } catch (_) {
      setState(() => _locating = false);
      await _reverseGeocode(_center);
    }
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    setState(() => _geocoding = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${pos.latitude}&lon=${pos.longitude}&format=json&accept-language=en',
      );
      final res = await http.get(url, headers: {'User-Agent': 'GharsipApp/1.0 (gharsip.in)'});
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final addr = (data['address'] as Map<String, dynamic>?) ?? {};
        final road = (addr['road'] ?? addr['pedestrian'] ?? addr['footway'] ?? '') as String;
        final area = (addr['suburb'] ?? addr['neighbourhood'] ?? addr['village'] ?? addr['residential'] ?? '') as String;
        setState(() {
          _streetAddr = [road, area].where((s) => s.isNotEmpty).join(', ');
          if (_streetAddr.isEmpty) {
            final parts = ((data['display_name'] as String?) ?? '').split(',');
            _streetAddr = parts.take(2).join(',').trim();
          }
          _city = (addr['city'] ?? addr['town'] ?? addr['county'] ?? '') as String;
          _state = (addr['state'] ?? '') as String;
          _pincode = (addr['postcode'] ?? '') as String;
          _geocoding = false;
        });
      } else {
        if (mounted) setState(() => _geocoding = false);
      }
    } catch (_) {
      if (mounted) setState(() { _geocoding = false; _streetAddr = 'Move the map to detect your area'; });
    }
  }

  void _onMapMoved(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    setState(() => _center = camera.center);
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 700),
      () => _reverseGeocode(_center),
    );
  }

  void _confirm() {
    if (_flatCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter your flat / house number',
            style: TextStyle(fontFamily: 'Poppins')),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    Navigator.pop(
      context,
      PickedAddress(
        lat: _center.latitude,
        lng: _center.longitude,
        streetAddress: _streetAddr,
        city: _city,
        state: _state,
        pincode: _pincode,
        flatNo: _flatCtrl.text.trim(),
        landmark: _landmarkCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text('Select Location',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: Colors.black87, fontFamily: 'Poppins')),
      ),
      body: Column(
        children: [
          // ── Map ───────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 15.0,
                    onPositionChanged: _onMapMoved,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.gharsip.gharsipApp',
                    ),
                  ],
                ),
                // Fixed pin in center
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_pin, color: _green, size: 48),
                      SizedBox(height: 44), // offset for pin base
                    ],
                  ),
                ),
                // My location button
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.white,
                    elevation: 3,
                    heroTag: 'loc',
                    onPressed: _locating ? null : _goToCurrentLocation,
                    child: _locating
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _green))
                        : const Icon(Icons.my_location, color: _green),
                  ),
                ),
              ],
            ),
          ),

          // ── Address panel ──────────────────────────────
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detected area
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: _green, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _geocoding
                              ? const Text('Detecting area…',
                                  style: TextStyle(fontSize: 13, color: Colors.grey,
                                      fontFamily: 'Poppins'))
                              : Text(
                                  _streetAddr.isNotEmpty
                                      ? '$_streetAddr${_city.isNotEmpty ? ', $_city' : ''}'
                                      : 'Move the map to select your area',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                      color: Colors.black87, fontFamily: 'Poppins'),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text('Flat / House No, Building *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: Colors.black54, fontFamily: 'Poppins')),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _flatCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Flat 3A, Green Towers',
                      hintStyle: const TextStyle(color: Colors.black38,
                          fontFamily: 'Poppins', fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 12),

                  const Text('Landmark (optional)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: Colors.black54, fontFamily: 'Poppins')),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _landmarkCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Near Big Bazaar',
                      hintStyle: const TextStyle(color: Colors.black38,
                          fontFamily: 'Poppins', fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _geocoding ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Confirm this location',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins')),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
