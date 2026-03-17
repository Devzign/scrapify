import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String _selectedAddressType = 'home';
  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(28.6139, 77.2090), // Default to New Delhi
    zoom: 14.4746,
  );

  bool _isLoadingLocation = false;
  LatLng? _currentCenter;

  final TextEditingController _streetController = TextEditingController();

  @override
  void dispose() {
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
      }

      Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );

      _currentCenter = latLng;
      _getAddressFromLatLng(latLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Build address string
        List<String> addressParts = [];
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        setState(() {
          _streetController.text = addressParts.join(', ');
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF102213)
          : const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1A331F).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF0F172A), // slate-900
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'address_book.add.title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              bottom: 100,
            ), // space for sticky button
            children: [
              // Map Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: _initialPosition,
                              myLocationEnabled: false,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              onCameraMove: (CameraPosition position) {
                                _currentCenter = position.target;
                              },
                              onCameraIdle: () {
                                if (_currentCenter != null) {
                                  _getAddressFromLatLng(_currentCenter!);
                                }
                              },
                            ),
                            // Always-centered Pin
                            IgnorePointer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF13EC30),
                                    size: 48,
                                  ),
                                  Container(
                                    width: 12,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // My Location Button
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Material(
                                color: isDark
                                    ? const Color(0xFF1A331F)
                                    : Colors.white,
                                shape: const CircleBorder(),
                                elevation: 2,
                                child: InkWell(
                                  onTap: _getCurrentLocation,
                                  customBorder: const CircleBorder(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: _isLoadingLocation
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.my_location,
                                            color: Color(0xFF13EC30),
                                            size: 24,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'address_book.add.map_hint'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              // Form Fields
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      context,
                      label: 'address_book.add.house_no'.tr(),
                      hintText: 'address_book.add.house_no_hint'.tr(),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      context,
                      label: 'address_book.add.street'.tr(),
                      hintText: 'address_book.add.street_hint'.tr(),
                      controller: _streetController,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      context,
                      label: 'address_book.add.landmark'.tr(),
                      hintText: 'address_book.add.landmark_hint'.tr(),
                      isOptional: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 24),

                    // Address Type Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'address_book.add.save_as'.tr(),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildAddressTypeChip(
                          value: 'home',
                          label: 'address_book.home'.tr(),
                          icon: Icons.home,
                          isDark: isDark,
                        ),
                        _buildAddressTypeChip(
                          value: 'work',
                          label: 'address_book.work'.tr(),
                          icon: Icons.work,
                          isDark: isDark,
                        ),
                        _buildAddressTypeChip(
                          value: 'other',
                          label: 'edit_profile.other'.tr(),
                          icon: Icons.location_on,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sticky Footer Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A331F) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13EC30), // primary
                  foregroundColor: Colors.black, // Active tap color effect base
                  elevation: 4,
                  shadowColor: const Color(0xFF13EC30).withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: Text(
                  'address_book.add.save_btn'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String hintText,
    TextEditingController? controller,
    bool isOptional = false,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOptional)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'address_book.add.optional'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF94A3B8), // slate-400
            ),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : const Color(0xFFF1F5F9), // slate-800/80 or slate-100
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0), // ring slate-700/200
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF13EC30), // primary
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeChip({
    required String value,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedAddressType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF13EC30).withValues(alpha: 0.2) // primary/20
              : (isDark
                    ? const Color(0xFF1A331F)
                    : Colors.white), // surface-dark or white
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF13EC30) // primary
                : (isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0)), // slate-700 or slate-200
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF0EB524) // primary-dark
                  : (isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B)), // slate-400/500
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark
                          ? Colors.white
                          : const Color(0xFF0F172A)) // text primary active
                    : (isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF475569)), // slate-200/600 default
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
