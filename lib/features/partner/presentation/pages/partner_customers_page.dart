import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_color.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../channel_partner/providers/channel_partner_provider.dart';

class PartnerCustomersPage extends ConsumerStatefulWidget {
  const PartnerCustomersPage({super.key});

  @override
  ConsumerState<PartnerCustomersPage> createState() => _PartnerCustomersPageState();
}

class _PartnerCustomersPageState extends ConsumerState<PartnerCustomersPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(channelPartnerProvider.notifier).loadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(channelPartnerProvider);
    final customers = state.customers.whereType<Map<String, dynamic>>().toList();
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Customer Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCustomerForm(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Customer'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (v) {
                _query = v.trim();
                ref.read(channelPartnerProvider.notifier).loadCustomers(q: _query);
              },
              decoration: InputDecoration(
                hintText: 'Search by name or mobile',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _query = '';
                    ref.read(channelPartnerProvider.notifier).loadCustomers();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                state.error!,
                style: const TextStyle(color: AppColor.error),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(channelPartnerProvider.notifier).loadCustomers(q: _query),
              child: state.isLoading && customers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : customers.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 220),
                        Center(child: Text('No customers found')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                      itemBuilder: (_, i) {
                        final c = customers[i];
                        return InkWell(
                          onTap: () => _showCustomerDetail(c),
                          borderRadius: AppTheme.cardBorderRadius,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppTheme.cardBorderRadius,
                              border: AppTheme.cardBorder,
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppTheme.primarySurface,
                                  child: Text(
                                    (c['name']?.toString().isNotEmpty ?? false)
                                        ? c['name'].toString()[0].toUpperCase()
                                        : 'C',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c['name']?.toString() ?? 'Customer',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c['mobile']?.toString() ?? c['phone']?.toString() ?? '-',
                                        style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        c['address']?.toString() ?? '-',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _openCustomerForm(context, customer: c),
                                  icon: const Icon(Icons.edit_rounded),
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: customers.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomerDetail(Map<String, dynamic> customer) async {
    final id = int.tryParse('${customer['id'] ?? ''}');
    Map<String, dynamic> detail = customer;
    if (id != null) {
      final fetched = await ref.read(channelPartnerProvider.notifier).getCustomerDetail(id);
      if (fetched != null) {
        detail = fetched;
      }
    }
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer Detail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 14),
            _row('Name', detail['name']),
            _row('Mobile', detail['mobile'] ?? detail['phone']),
            _row('Address', detail['address'] ?? detail['address_line']),
            _row('City', detail['city'] ?? detail['city_name']),
            _row('Pincode', detail['pincode']),
            _row('Landmark', detail['landmark']),
            _row('Latitude', detail['latitude']),
            _row('Longitude', detail['longitude']),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: (value?.toString().isNotEmpty ?? false) ? value.toString() : '-'),
          ],
        ),
      ),
    );
  }

  Future<void> _openCustomerForm(
    BuildContext context, {
    Map<String, dynamic>? customer,
  }) async {
    final parentContext = context;
    final isEdit = customer != null;
    final name = TextEditingController(text: customer?['name']?.toString() ?? '');
    final mobile = TextEditingController(
      text: customer?['mobile']?.toString() ?? customer?['phone']?.toString() ?? '',
    );
    final address = TextEditingController(
      text: customer?['address']?.toString() ?? customer?['address_line']?.toString() ?? '',
    );
    final city = TextEditingController(
      text: customer?['city']?.toString() ?? customer?['city_name']?.toString() ?? '',
    );
    final pincode = TextEditingController(text: customer?['pincode']?.toString() ?? '');
    final landmark = TextEditingController(text: customer?['landmark']?.toString() ?? '');
    final latitude = TextEditingController(text: customer?['latitude']?.toString() ?? '');
    final longitude = TextEditingController(text: customer?['longitude']?.toString() ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? 'Edit Customer' : 'Add Customer',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _field(name, 'Name', maxLength: 50, capitalize: true),
              _field(
                mobile,
                'Mobile',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
              ),
              _field(address, 'Address', maxLength: 200, maxLines: 2),
              _field(city, 'City', maxLength: 60, capitalize: true),
              _field(
                pincode,
                'Pincode',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              _field(landmark, 'Landmark', maxLength: 80),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await Navigator.of(parentContext).push<_PickedLocation>(
                          MaterialPageRoute(
                            builder: (_) => _PartnerMapPickerPage(
                              initialLat: double.tryParse(latitude.text.trim()),
                              initialLng: double.tryParse(longitude.text.trim()),
                            ),
                          ),
                        );
                        if (picked == null) return;
                        address.text = picked.address;
                        city.text = picked.city;
                        pincode.text = picked.pincode;
                        latitude.text = picked.latitude.toStringAsFixed(6);
                        longitude.text = picked.longitude.toStringAsFixed(6);
                      },
                      icon: const Icon(Icons.map_rounded),
                      label: const Text('Pick on Google Map'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                (latitude.text.trim().isNotEmpty && longitude.text.trim().isNotEmpty)
                    ? 'Lat: ${latitude.text}, Lng: ${longitude.text}'
                    : 'No location selected yet',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate before building the payload.
                    final nameErr = Validators.name(
                      name.text,
                      fieldName: 'Customer name',
                    );
                    if (nameErr != null) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text(nameErr)),
                      );
                      return;
                    }
                    final mobileErr = Validators.indianMobile(mobile.text);
                    if (mobileErr != null) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text(mobileErr)),
                      );
                      return;
                    }
                    final addressErr = Validators.address(address.text);
                    if (addressErr != null) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text(addressErr)),
                      );
                      return;
                    }
                    final cityErr = Validators.cityOrArea(city.text);
                    if (cityErr != null) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text(cityErr)),
                      );
                      return;
                    }
                    final pinErr = Validators.pinCode(pincode.text);
                    if (pinErr != null) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text(pinErr)),
                      );
                      return;
                    }
                    if (landmark.text.trim().length > 80) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        const SnackBar(content: Text('Landmark is too long.')),
                      );
                      return;
                    }

                    final payload = <String, dynamic>{
                      'name': name.text.trim(),
                      'mobile': mobile.text.trim(),
                      'address': address.text.trim(),
                      'city': city.text.trim(),
                      'pincode': pincode.text.trim(),
                      'landmark': landmark.text.trim(),
                      if (latitude.text.trim().isNotEmpty) 'latitude': latitude.text.trim(),
                      if (longitude.text.trim().isNotEmpty) 'longitude': longitude.text.trim(),
                    };
                    if (isEdit) {
                      final id = int.tryParse('${customer['id'] ?? ''}');
                      if (id != null) {
                        await ref.read(channelPartnerProvider.notifier).updateCustomer(id, payload);
                      }
                    } else {
                      await ref.read(channelPartnerProvider.notifier).createCustomer(payload);
                    }
                    if (!parentContext.mounted) return;
                    Navigator.pop(parentContext);
                    await ref.read(channelPartnerProvider.notifier).loadCustomers(q: _query);
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Create Customer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String hint, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    int maxLines = 1,
    bool capitalize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        maxLines: maxLines,
        textCapitalization:
            capitalize ? TextCapitalization.words : TextCapitalization.none,
        decoration: InputDecoration(
          hintText: hint,
          // Hide the default 'n/m' counter — keeps the form tidy.
          counterText: '',
        ),
      ),
    );
  }
}

class _PickedLocation {
  const _PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.pincode,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String pincode;
}

class _PartnerMapPickerPage extends StatefulWidget {
  const _PartnerMapPickerPage({this.initialLat, this.initialLng});

  final double? initialLat;
  final double? initialLng;

  @override
  State<_PartnerMapPickerPage> createState() => _PartnerMapPickerPageState();
}

class _PartnerMapPickerPageState extends State<_PartnerMapPickerPage> {
  static const _fallback = LatLng(28.6139, 77.2090);
  GoogleMapController? _mapController;
  LatLng _center = _fallback;
  String _address = '';
  String _city = '';
  String _pincode = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = LatLng(widget.initialLat!, widget.initialLng!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.initialLat == null || widget.initialLng == null) {
        await _moveToCurrentLocation();
      } else {
        await _reverseGeocode(_center);
      }
    });
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final next = LatLng(pos.latitude, pos.longitude);
      _center = next;
      await _mapController?.animateCamera(CameraUpdate.newLatLngZoom(next, 16));
      await _reverseGeocode(next);
    } catch (_) {}
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() => _loading = true);
    try {
      final marks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (marks.isNotEmpty) {
        final p = marks.first;
        final line = <String>[
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality!,
          if ((p.locality ?? '').isNotEmpty) p.locality!,
          if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea!,
        ].join(', ');
        setState(() {
          _address = line;
          _city = p.locality ?? p.subAdministrativeArea ?? '';
          _pincode = p.postalCode?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          IconButton(
            onPressed: _moveToCurrentLocation,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _center, zoom: 15),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                  onCameraMove: (position) => _center = position.target,
                  onCameraIdle: () => _reverseGeocode(_center),
                ),
                const IgnorePointer(
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 44,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.outline)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_loading) const LinearProgressIndicator(),
                Text(
                  _address.isEmpty ? 'Move map to pick location' : _address,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat ${_center.latitude.toStringAsFixed(6)}, Lng ${_center.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        _PickedLocation(
                          latitude: _center.latitude,
                          longitude: _center.longitude,
                          address: _address,
                          city: _city,
                          pincode: _pincode,
                        ),
                      );
                    },
                    child: const Text('Use this location'),
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
