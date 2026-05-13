import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../providers/address_provider.dart';
import '../domain/models/address_model.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAddressType = 'home';
  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14.4746,
  );

  bool _isLoadingLocation = false;
  // Null until the user explicitly drags the map or taps "My Location".
  // Prevents saving the default New-Delhi coordinates for non-Delhi addresses.
  LatLng? _currentCenter;
  bool _isMapReady = false;

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String? _resolvedState;
  bool _hasSubmitted = false;

  @override
  void dispose() {
    _streetController.dispose();
    _houseController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 16),
        ),
      );

      // User explicitly requested their location — mark as intentional.
      _currentCenter = latLng;
      _isMapReady = true;
      _getAddressFromLatLng(latLng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final parts = <String>[
          if (place.subLocality?.isNotEmpty == true) place.subLocality!,
          if (place.locality?.isNotEmpty == true) place.locality!,
          if (place.administrativeArea?.isNotEmpty == true)
            place.administrativeArea!,
        ];
        setState(() {
          _streetController.text = parts.join(', ');
          _pincodeController.text =
              (place.postalCode ?? '').replaceAll(RegExp(r'[^0-9]'), '');
          _resolvedState = place.administrativeArea;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String? _validatePincode(String? v) => Validators.pinCode(v);

  String? _validateHouse(String? v) {
    final err = Validators.required(v, fieldName: 'House/Flat No.');
    if (err != null) return err;
    if (v!.trim().length > 30) return 'House/Flat No. is too long';
    return null;
  }

  String? _validateStreet(String? v) {
    final err = Validators.required(v, fieldName: 'Street/Area');
    if (err != null) return err;
    final t = v!.trim();
    if (t.length < 3) return 'Street/Area looks too short';
    if (t.length > 120) return 'Street/Area is too long';
    return null;
  }

  String? _validateLandmark(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    if (v.trim().length > 80) return 'Landmark is too long';
    return null;
  }

  Future<void> _saveAddress(bool isSaving) async {
    if (isSaving) return;
    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = GoRouter.of(context);
    final newAddress = AddressModel(
      id: 0,
      title: _selectedAddressType,
      addressLine1: '${_houseController.text.trim()}, ${_streetController.text.trim()}',
      addressLine2: _landmarkController.text.trim(),
      pincode: _pincodeController.text.trim(),
      cityId: 1,
      state: _resolvedState,
      isDefault: false,
      latitude: _currentCenter?.latitude,
      longitude: _currentCenter?.longitude,
    );

    final success =
        await ref.read(addressProvider.notifier).addAddress(newAddress);
    if (!mounted) return;
    if (success) {
      navigator.pop();
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text('Failed to save address'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(addressProvider);
    final isSaving = addressState is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'address_book.add.title'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: _hasSubmitted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                // ── Map section ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel(label: 'Pin your location'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColor.outline),
                          boxShadow: AppTheme.e1,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          height: 200,
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
                                onMapCreated: (GoogleMapController c) {
                                  _controller.complete(c);
                                  // Ignore the initial camera-move that fires
                                  // during map load. Mark ready after a short
                                  // delay so only user drags update the pin.
                                  Future.delayed(
                                    const Duration(milliseconds: 400),
                                    () { if (mounted) setState(() => _isMapReady = true); },
                                  );
                                },
                                onCameraMove: (CameraPosition p) {
                                  if (_isMapReady) {
                                    _currentCenter = p.target;
                                  }
                                },
                                onCameraIdle: () {
                                  if (_isMapReady && _currentCenter != null) {
                                    _getAddressFromLatLng(_currentCenter!);
                                  }
                                },
                              ),
                              // Centre pin
                              IgnorePointer(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: AppColor.primary,
                                      size: 48,
                                    ),
                                    Container(
                                      width: 12,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.black
                                            .withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // My location button
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Material(
                                  color: AppColor.surface,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  shadowColor: AppColor.glassShadow,
                                  child: InkWell(
                                    onTap: _getCurrentLocation,
                                    customBorder: const CircleBorder(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: _isLoadingLocation
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColor.primary,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.my_location_rounded,
                                              color: AppColor.primary,
                                              size: 22,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Drag the map to pin your exact location',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── White card form ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColor.cardBorder),
                      boxShadow: AppTheme.e1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                          label: 'address_book.add.house_no'.tr(),
                          hint: 'address_book.add.house_no_hint'.tr(),
                          controller: _houseController,
                          icon: Icons.home_rounded,
                          validator: _validateHouse,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'address_book.add.street'.tr(),
                          hint: 'address_book.add.street_hint'.tr(),
                          controller: _streetController,
                          icon: Icons.location_city_rounded,
                          validator: _validateStreet,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Pincode',
                          hint: 'Enter 6-digit pincode',
                          controller: _pincodeController,
                          icon: Icons.pin_drop_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: _validatePincode,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'address_book.add.landmark'.tr(),
                          hint: 'address_book.add.landmark_hint'.tr(),
                          controller: _landmarkController,
                          icon: Icons.place_rounded,
                          isOptional: true,
                          validator: _validateLandmark,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Address type ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColor.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColor.cardBorder),
                      boxShadow: AppTheme.e1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'address_book.add.save_as'.tr(),
                          style: const TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _AddressTypeChip(
                              value: 'home',
                              label: 'address_book.home'.tr(),
                              icon: Icons.home_rounded,
                              selected: _selectedAddressType == 'home',
                              onTap: () => setState(
                                  () => _selectedAddressType = 'home'),
                            ),
                            _AddressTypeChip(
                              value: 'work',
                              label: 'address_book.work'.tr(),
                              icon: Icons.work_rounded,
                              selected: _selectedAddressType == 'work',
                              onTap: () => setState(
                                  () => _selectedAddressType = 'work'),
                            ),
                            _AddressTypeChip(
                              value: 'other',
                              label: 'edit_profile.other'.tr(),
                              icon: Icons.location_on_rounded,
                              selected: _selectedAddressType == 'other',
                              onTap: () => setState(
                                  () => _selectedAddressType = 'other'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Sticky save button ─────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.of(context).padding.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: AppColor.backgroundLight,
                  border: const Border(
                    top: BorderSide(color: AppColor.hairline),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.deepNavy.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: CustomButton(
                  onPressed: () => _saveAddress(isSaving),
                  isLoading: isSaving,
                  text: 'address_book.add.save_btn'.tr(),
                  borderRadius: 14,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isOptional = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isOptional) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColor.hairline,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'optional',
                style: TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            color: AppColor.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColor.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: AppColor.primary, size: 20),
            filled: true,
            fillColor: AppColor.backgroundLight,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColor.primary, width: 1.6),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColor.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColor.error, width: 1.6),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColor.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AddressTypeChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AddressTypeChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColor.primarySurface
              : AppColor.backgroundLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColor.primary : AppColor.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColor.primary : AppColor.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColor.primaryDark
                    : AppColor.textSecondary,
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
