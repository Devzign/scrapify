import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  LatLng? _currentCenter = const LatLng(28.6139, 77.2090);

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
        final place = placemarks[0];
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
          _pincodeController.text = (place.postalCode ?? '').replaceAll(
            RegExp(r'[^0-9]'),
            '',
          );
          _resolvedState = place.administrativeArea;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String? _validatePincode(String? value) => Validators.pinCode(value);

  String? _validateHouse(String? value) {
    final err = Validators.required(value, fieldName: 'House/Flat No.');
    if (err != null) return err;
    final trimmed = value!.trim();
    if (trimmed.length > 30) return 'House/Flat No. is too long';
    return null;
  }

  String? _validateStreet(String? value) {
    final err = Validators.required(value, fieldName: 'Street/Area');
    if (err != null) return err;
    final trimmed = value!.trim();
    if (trimmed.length < 3) return 'Street/Area looks too short';
    if (trimmed.length > 120) return 'Street/Area is too long';
    return null;
  }

  String? _validateLandmark(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 80) return 'Landmark is too long';
    return null;
  }

  Future<void> _saveAddress(bool isSaving) async {
    if (isSaving) {
      return;
    }

    setState(() => _hasSubmitted = true);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = GoRouter.of(context);
    final house = _houseController.text.trim();
    final street = _streetController.text.trim();
    final landmark = _landmarkController.text.trim();
    final pincode = _pincodeController.text.trim();

    final newAddress = AddressModel(
      id: 0,
      title: _selectedAddressType,
      addressLine1: '$house, $street',
      addressLine2: landmark,
      pincode: pincode,
      cityId: 1,
      state: _resolvedState,
      isDefault: false,
      latitude: _currentCenter?.latitude,
      longitude: _currentCenter?.longitude,
    );

    final success = await ref
        .read(addressProvider.notifier)
        .addAddress(newAddress);
    if (!mounted) {
      return;
    }
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final addressState = ref.watch(addressProvider);
    final isSaving = addressState is AsyncLoading;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102213) : AppTheme.hairline,
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF1A331F).withValues(alpha: 0.95)
            : AppTheme.hairline.withValues(alpha: 0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppTheme.textPrimary, // slate-900
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'address_book.add.title'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
                                ? AppTheme.textPrimary
                                : AppTheme.surfaceColor,
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.textPrimary
                                  : AppTheme.outline,
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
                                      color: AppTheme.primaryColor,
                                      size: 48,
                                    ),
                                    Container(
                                      width: 12,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
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
                                      : AppTheme.surfaceColor,
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
                                              color: AppTheme.primaryColor,
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
                              ? AppTheme.textMuted
                              : AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
                        controller: _houseController,
                        isDark: isDark,
                        validator: _validateHouse,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context,
                        label: 'address_book.add.street'.tr(),
                        hintText: 'address_book.add.street_hint'.tr(),
                        controller: _streetController,
                        isDark: isDark,
                        validator: _validateStreet,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context,
                        label: 'Pincode'.tr(),
                        hintText: 'Enter 6-digit pincode'.tr(),
                        controller: _pincodeController,
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: _validatePincode,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        context,
                        label: 'address_book.add.landmark'.tr(),
                        hintText: 'address_book.add.landmark_hint'.tr(),
                        controller: _landmarkController,
                        isOptional: true,
                        isDark: isDark,
                        validator: _validateLandmark,
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
                                  : AppTheme.textPrimary,
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
                  color: isDark ? const Color(0xFF1A331F) : AppTheme.hairline,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.hairline,
                    ),
                  ),
                ),
                child: CustomButton(
                  onPressed: () => _saveAddress(isSaving),
                  isLoading: isSaving,
                  text: 'address_book.add.save_btn'.tr(),
                  borderRadius: 12,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
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
                color: isDark ? Colors.white : AppTheme.textPrimary,
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
                    color: AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textPrimary,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark
                  ? AppTheme.textMuted
                  : AppTheme.textMuted, // slate-400
            ),
            filled: true,
            fillColor: isDark
                ? AppTheme.textPrimary.withValues(alpha: 0.8)
                : AppTheme.surfaceColor, // swapped for light mode
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
                    : AppTheme.outline, // ring slate-700/200
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryColor, // primary
                width: 2,
              ),
            ),
          ),
          validator: validator,
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
              ? AppTheme.primaryColor.withValues(alpha: 0.2) // primary/20
              : (isDark
                    ? const Color(0xFF1A331F)
                    : Colors.white), // surface-dark or white
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppTheme
                      .primaryColor // primary
                : (isDark
                      ? const Color(0xFF334155)
                      : AppTheme.outline), // slate-700 or slate-200
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
                        ? AppTheme.textMuted
                        : AppTheme.textSecondary), // slate-400/500
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (isDark
                          ? Colors.white
                          : AppTheme.textPrimary) // text primary active
                    : (isDark
                          ? AppTheme.outline
                          : AppTheme.textSecondary), // slate-200/600 default
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
