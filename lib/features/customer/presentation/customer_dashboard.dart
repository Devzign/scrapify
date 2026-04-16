import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pickup/providers/category_provider.dart';
import '../../pickup/providers/basket_provider.dart';
import '../../pickup/providers/booking_provider.dart';
import '../../pickup/providers/pickup_provider.dart';
import '../../pickup/domain/models/pickup_request_model.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../../settings/domain/models/app_settings_model.dart';
import '../../settings/providers/settings_provider.dart';
import 'widgets/customer_dashboard_bottom_bar.dart';
import '../../../core/services/location_service.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppSettings();
    });
  }

  Future<void> _initAppSettings() async {
    try {
      // 1. Get location
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      String? locationName;
      if (position != null) {
        locationName = await locationService.getLocationName(
          position.latitude,
          position.longitude,
        );
      }

      // 2. Sync Settings with Backend
      await ref
          .read(settingsProvider.notifier)
          .syncSettings(
            latitude: position?.latitude,
            longitude: position?.longitude,
            locationName: locationName,
          );

      // 3. Check for language restoration
      if (mounted) {
        final syncedLanguage = ref.read(settingsProvider).language;
        if (syncedLanguage != context.locale.languageCode) {
          context.setLocale(Locale(syncedLanguage));
        }
      }
    } catch (e) {
      debugPrint('Error initializing app settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final basketItems = ref.watch(basketProvider);
    final appSettings = ref.watch(settingsProvider);
    final isSettingsLoading = appSettings.isLoading || !appSettings.hasLoaded;
    final isServiceable =
        !isSettingsLoading && appSettings.serviceAvailability.isServiceable;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBody: isServiceable,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: isServiceable ? 72 : 0,
        leading: isServiceable
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.profile),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppTheme.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              )
            : null,
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppTheme.textPrimary,
                  size: 26,
                ),
                onPressed: () => context.push('/notifications'),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: isServiceable
          ? CustomerDashboardBottomBar(
              currentIndex: _currentIndex,
              basketItemCount: basketItems.length,
              scrapPickupEnabled: appSettings.features.scrapPickupEnabled,
              isServiceable: appSettings.serviceAvailability.isServiceable,
              serviceMessage: appSettings.serviceAvailability.message,
              onDashboardTap: () => setState(() => _currentIndex = 0),
              onOrdersTap: () => setState(() => _currentIndex = 1),
              onMoneyTap: _handleMoneyTap,
            )
          : null,
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'login.app_name'.tr();
      case 1:
        return context.locale.languageCode == 'hi' ? 'ऑर्डर्स' : 'Orders';
      default:
        return 'login.app_name'.tr();
    }
  }

  Widget _buildBody() {
    final appSettings = ref.watch(settingsProvider);
    if (appSettings.isLoading || !appSettings.hasLoaded) {
      return const SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: DashboardLoadingSkeleton(),
        ),
      );
    }

    if (!appSettings.serviceAvailability.isServiceable) {
      return _buildServiceUnavailableDashboard(appSettings);
    }

    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildOrdersTab();
      default:
        return _buildHomeTab();
    }
  }

  void _handleMoneyTap() {
    final settings = ref.read(settingsProvider);
    if (!settings.features.scrapPickupEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scrap pickup is temporarily disabled')),
      );
      return;
    }
    if (!settings.serviceAvailability.isServiceable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(settings.serviceAvailability.message)),
      );
      return;
    }
    ref.read(bookingProvider.notifier).startScrapFlow();
    context.push(AppRoutes.categorySelection);
  }

  Widget _buildHomeTab() {
    final pickupsAsync = ref.watch(pickupsProvider);
    final appSettings = ref.watch(settingsProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Serviceability Banner
            if (!appSettings.serviceAvailability.isServiceable)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber.shade800,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appSettings.serviceAvailability.message,
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Top Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Eco-friendly badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.leaf,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'dashboard.eco_badge'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'dashboard.book_pickup'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          context.locale.languageCode == 'hi'
                              ? 'पिकअप बुक करें'
                              : 'Schedule your pickup',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'dashboard.book_pickup_desc'.tr(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.truckFast,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.arrowRight,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 32),
            // Categories Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'dashboard.what_to_sell'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                InkWell(
                  onTap: () => context.push('/pickup/category'),
                  child: Text(
                    'dashboard.view_all'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal scroll categories
            Consumer(
              builder: (context, ref, child) {
                return ref
                    .watch(categoriesProvider)
                    .when(
                      data: (categories) {
                        if (categories.isEmpty) {
                          return const Center(
                            child: Text('No categories available'),
                          );
                        }
                        final limitedCategories = categories.take(3).toList();
                        return SizedBox(
                          height: 160,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: limitedCategories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final category = limitedCategories[index];
                              return _buildMaterialCard(
                                title: category.getName(context),
                                subtitle: category.pricingType ?? '',
                                imageUrl: category.imageUrl,
                                iconData: _getIconForCategory(category.slug),
                                isDark: true,
                                onTap: () => context.push(
                                  '${AppRoutes.subCategorySelection}/${category.id}',
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () =>
                          const Center(child: DashboardLoadingSkeleton()),
                      error: (error, stack) => Center(
                        child: Text(
                          'Error loading categories',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    );
              },
            ),
            const SizedBox(height: 16),

            if (appSettings.features.donationEnabled) ...[
              _buildDonationCard(context),
              const SizedBox(height: 32),
            ],

            // We can add more dynamic content here if needed
            const SizedBox(height: 32),

            // Active Request
            Text(
              'dashboard.active_request'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            pickupsAsync.when(
              data: (pickups) {
                if (pickups.isEmpty) {
                  return _buildEmptyOrdersCard(
                    title: context.locale.languageCode == 'hi'
                        ? 'अभी कोई सक्रिय रिक्वेस्ट नहीं है'
                        : 'No active request yet',
                    subtitle: context.locale.languageCode == 'hi'
                        ? 'नई पिकअप बुक करने के बाद वह यहां दिखाई देगी'
                        : 'Your latest pickup request will appear here',
                  );
                }
                return _buildActiveRequestCard(context, pickups.first);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildEmptyOrdersCard(
                title: 'Failed to load requests',
                subtitle: error.toString(),
              ),
            ),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildServiceUnavailableDashboard(AppSettingsModel appSettings) {
    final isHindi = context.locale.languageCode == 'hi';
    final locationName = appSettings.serviceAvailability.locationName.trim();

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppTheme.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/map_banner.png',
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.14),
                            Colors.black.withValues(alpha: 0.62),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F1),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.location_off_rounded,
                                size: 16,
                                color: AppTheme.errorColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isHindi
                                  ? 'लोकेशन समर्थित नहीं है'
                                  : 'Location Not Supported',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              isHindi
                  ? 'आपके शहर में जल्द आ रहा है!'
                  : 'Coming Soon to your City!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isHindi
                  ? 'हम अभी आपके एरिया में लॉन्च नहीं हुए हैं, लेकिन तेजी से विस्तार कर रहे हैं। जैसे ही सेवा शुरू होगी, हम आपको बताएंगे।'
                  : "We haven't launched in your area yet, but we're expanding fast. Join the waitlist to get notified when we arrive.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.6,
              ),
            ),
            if (locationName.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                locationName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => _showServiceUnavailableSnackBar(
                isHindi
                    ? 'आपको वेटलिस्ट में शामिल कर दिया जाएगा जब यह फीचर उपलब्ध होगा।'
                    : 'You will be notified when Scrapify launches in your area.',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isHindi ? 'वेटलिस्ट जॉइन करें' : 'Join Waitlist',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => _showServiceUnavailableSnackBar(
                appSettings.serviceAvailability.message,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      isHindi ? 'कवरेज एरिया देखें' : 'Check Coverage Areas',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'तेजी से विस्तार' : 'Fast Expansion',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isHindi
                              ? 'हम भारत के नए शहरों में सेवा शुरू कर रहे हैं।'
                              : 'We are actively expanding service into new cities across India.',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServiceUnavailableSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildOrdersTab() {
    final pickupsAsync = ref.watch(pickupsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(pickupsProvider.future),
      child: pickupsAsync.when(
        data: (pickups) {
          if (pickups.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                _buildEmptyOrdersCard(
                  title: context.locale.languageCode == 'hi'
                      ? 'कोई ऑर्डर नहीं मिला'
                      : 'No orders found',
                  subtitle: context.locale.languageCode == 'hi'
                      ? 'जब आप पिकअप बुक करेंगे, आपकी हिस्ट्री यहां दिखाई देगी'
                      : 'Your pickup history will appear here after booking',
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
            itemCount: pickups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
                _buildOrderHistoryCard(context, pickups[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            _buildEmptyOrdersCard(
              title: 'Failed to load orders',
              subtitle: error.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRequestCard(
    BuildContext context,
    PickupRequestModel pickup,
  ) {
    return InkWell(
      onTap: () => context.push('${AppRoutes.pickupTracking}/${pickup.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _statusColor(pickup.status).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.boxOpen,
                    color: _statusColor(pickup.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pickup.pickupCode.isEmpty
                            ? 'Request #${pickup.id}'
                            : pickup.pickupCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatScheduled(pickup.scheduledAt, context),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(pickup.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(pickup.status),
                    style: TextStyle(
                      color: _statusColor(pickup.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pickup.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () =>
                      context.push('${AppRoutes.pickupTracking}/${pickup.id}'),
                  child: Text(
                    'dashboard.track'.tr(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';

    return InkWell(
      onTap: () => context.push(AppRoutes.donationCategorySelection),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE6EBF2)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFF43F5E),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Give Back to Community',
                    style: TextStyle(
                      color: Color(0xFFF43F5E),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Donate Items',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHindi ? 'वस्तुएं दान करें' : 'Donate reusable goods',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isHindi
                            ? 'कपड़े और पुराने फर्नीचर जैसी वस्तुएं दान करके समाज की मदद करें।'
                            : 'Support social causes by donating clothes and old furniture.',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF2F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        color: Color(0xFFF43F5E),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistoryCard(
    BuildContext context,
    PickupRequestModel pickup,
  ) {
    final totalWeight = pickup.items.fold<double>(
      0,
      (sum, item) => sum + item.weight,
    );

    return InkWell(
      onTap: () => context.push('${AppRoutes.pickupTracking}/${pickup.id}'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pickup.pickupCode.isEmpty
                        ? 'Pickup #${pickup.id}'
                        : pickup.pickupCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(pickup.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(pickup.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(pickup.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatScheduled(pickup.scheduledAt, context),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              pickup.address,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildOrderMeta(
                  icon: FontAwesomeIcons.layerGroup,
                  text: '${pickup.items.length} items',
                ),
                const SizedBox(width: 16),
                _buildOrderMeta(
                  icon: FontAwesomeIcons.weightHanging,
                  text: '${totalWeight.toStringAsFixed(0)} kg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderMeta({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 12, color: AppTheme.primaryColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrdersCard({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          const FaIcon(
            FontAwesomeIcons.clipboardList,
            size: 36,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScheduled(DateTime dateTime, BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final local = dateTime.toLocal();
    final date = localizations.formatMediumDate(local);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: false,
    );
    return '$date, $time';
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppTheme.primaryColor;
      case 'assigned':
        return const Color(0xFF2563EB);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'pending':
      default:
        return const Color(0xFFD97706);
    }
  }

  IconData _getIconForCategory(String slug) {
    switch (slug.toLowerCase()) {
      case 'metal':
      case 'iron-steel':
        return FontAwesomeIcons.screwdriverWrench;
      case 'plastic':
        return FontAwesomeIcons.recycle;
      case 'e-waste':
        return FontAwesomeIcons.microchip;
      case 'appliances':
        return FontAwesomeIcons.kitchenSet;
      case 'paper':
        return FontAwesomeIcons.boxArchive;
      default:
        return FontAwesomeIcons.box;
    }
  }

  Widget _buildMaterialCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required bool isDark,
    required VoidCallback onTap,
    String? imageUrl,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.black87,
          image: imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.4),
                    BlendMode.darken,
                  ),
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: FaIcon(iconData, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
