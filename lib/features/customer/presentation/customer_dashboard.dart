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
import '../../../core/theme/app_color.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_skeletons.dart';
import '../../settings/domain/models/app_settings_model.dart';
import '../../settings/providers/settings_provider.dart';
import 'widgets/customer_dashboard_bottom_bar.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/services/location_service.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  const CustomerDashboard({super.key});

  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  int _currentIndex = 0;
  int _ordersTypeTab = 0; // 0: scrap, 1: donation, 2: corporate
  DateTime _lastScrollInteraction = DateTime.fromMillisecondsSinceEpoch(0);

  bool get _isTapAllowed =>
      DateTime.now().difference(_lastScrollInteraction) >
      const Duration(milliseconds: 250);

  void _markScrollInteraction() {
    _lastScrollInteraction = DateTime.now();
  }

  void _guardedTap(VoidCallback onTap) {
    if (!_isTapAllowed) return;
    onTap();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppSettings();
      _reloadHomeData();
    });
  }

  Future<void> _reloadHomeData() async {
    ref.invalidate(pickupsProvider);
  }

  Future<void> _initAppSettings() async {
    try {
      await FcmService.instance.ensurePermission();
      final fcmToken = await FcmService.instance.getToken();

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
            fcmToken: fcmToken,
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

  Future<void> _checkCoverageAvailability() async {
    final isHindi = context.locale.languageCode == 'hi';
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      String? locationName;

      if (position != null) {
        locationName = await locationService.getLocationName(
          position.latitude,
          position.longitude,
        );
      }

      await ref
          .read(settingsProvider.notifier)
          .syncSettings(
            latitude: position?.latitude,
            longitude: position?.longitude,
            locationName: locationName,
          );

      if (!mounted) return;
      final latest = ref.read(settingsProvider).serviceAvailability;
      _showServiceUnavailableSnackBar(
        latest.isServiceable
            ? (isHindi
                  ? 'आपके क्षेत्र में सेवा उपलब्ध है।'
                  : 'Service is available in your area.')
            : (latest.message.isNotEmpty
                  ? latest.message
                  : (isHindi
                        ? 'सेवा अभी आपके क्षेत्र में उपलब्ध नहीं है।'
                        : 'Service is not available in your area yet.')),
      );
    } catch (_) {
      if (!mounted) return;
      _showServiceUnavailableSnackBar(
        isHindi
            ? 'कवरेज जांचने में समस्या हुई। कृपया पुनः प्रयास करें।'
            : 'Unable to check coverage right now. Please try again.',
      );
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
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primary.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
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
            color: AppColor.deepNavy,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                InkWell(
                  onTap: () => context.push('/notifications'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColor.cardBorder),
                      boxShadow: AppTheme.e1,
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: AppColor.deepNavy,
                      size: 22,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColor.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
              onDashboardTap: () {
                setState(() => _currentIndex = 0);
                _reloadHomeData();
              },
              onOrdersTap: () {
                setState(() => _currentIndex = 1);
                ref.invalidate(pickupsProvider);
              },
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

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification ||
            notification is ScrollUpdateNotification ||
            notification is OverscrollNotification ||
            notification is ScrollEndNotification) {
          _markScrollInteraction();
        }
        return false;
      },
      child: SingleChildScrollView(
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
              InkWell(
                onTap: _handleMoneyTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppTheme.sageHeader,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.32),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.36),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.36),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.leaf,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'dashboard.eco_badge'.tr(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'dashboard.book_pickup'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'dashboard.book_pickup_desc'.tr(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.90),
                                fontSize: 12,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Center(
                              child: FaIcon(
                                FontAwesomeIcons.truckFast,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.14),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── Section header: Categories ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'dashboard.what_to_sell'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColor.deepNavy,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap a category to see rates',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () =>
                        _guardedTap(() => context.push('/pickup/category')),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColor.primarySurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'dashboard.view_all'.tr(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColor.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Consumer(
                builder: (context, ref, child) {
                  return ref.watch(categoriesProvider).when(
                        data: (categories) {
                          if (categories.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final limited = categories.take(5).toList();
                          return SizedBox(
                            height: 176,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(right: 4),
                              itemCount: limited.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final category = limited[index];
                                return _buildMaterialCard(
                                  title: category.getName(context),
                                  subtitle: category.pricingType ?? '',
                                  imageUrl: category.imageUrl,
                                  iconData:
                                      _getIconForCategory(category.slug),
                                  isDark: false,
                                  onTap: () => _guardedTap(
                                    () => context.push(
                                      '${AppRoutes.subCategorySelection}/${category.id}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          height: 176,
                          child: Center(child: DashboardLoadingSkeleton()),
                        ),
                        error: (error, stack) => const SizedBox.shrink(),
                      );
                },
              ),
              const SizedBox(height: 16),
              _buildCorporateCard(context),
              const SizedBox(height: 16),
              if (appSettings.features.donationEnabled) ...[
                _buildDonationCard(context),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              Text(
                'dashboard.active_request'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColor.deepNavy,
                  letterSpacing: -0.3,
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
              const SizedBox(height: 130), // Padding for FAB/bottom nav
            ],
          ),
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
                borderRadius: AppTheme.cardBorderRadius,
                border: AppTheme.cardBorder,
                boxShadow: AppTheme.cardShadow,
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
                                color: AppColor.errorTint,
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
              onPressed: _checkCoverageAvailability,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColor.outline),
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
                borderRadius: AppTheme.cardBorderRadius,
                border: AppTheme.cardBorder,
                boxShadow: AppTheme.cardShadow,
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _buildOrdersTypeTabs(),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(pickupsProvider.future),
            child: pickupsAsync.when(
              data: (pickups) {
                final filtered = pickups.where(_matchesOrdersTypeTab).toList();
                if (filtered.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildEmptyOrdersCard(
                        title: context.locale.languageCode == 'hi'
                            ? 'कोई ऑर्डर नहीं मिला'
                            : 'No orders found',
                        subtitle: context.locale.languageCode == 'hi'
                            ? 'चुने गए टैब में अभी कोई ऑर्डर नहीं है'
                            : 'No orders available in selected tab',
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) =>
                      _buildOrderHistoryCard(context, filtered[index]),
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
          ),
        ),
      ],
    );
  }

  bool _matchesOrdersTypeTab(PickupRequestModel pickup) {
    switch (_ordersTypeTab) {
      case 0:
        return pickup.requestType == 'scrap';
      case 1:
        return pickup.requestType == 'donation';
      case 2:
        return pickup.requestType == 'corporate';
      default:
        return true;
    }
  }

  Widget _buildOrdersTypeTabs() {
    final isHindi = context.locale.languageCode == 'hi';
    final tabs = [
      isHindi ? 'स्क्रैप बेचें' : 'Sell Scrap',
      isHindi ? 'डोनेशन' : 'Donation',
      isHindi ? 'कॉर्पोरेट' : 'Corporate',
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = _ordersTypeTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _ordersTypeTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveRequestCard(
    BuildContext context,
    PickupRequestModel pickup,
  ) {
    return InkWell(
      onTap: () => _guardedTap(
        () => context.push('${AppRoutes.pickupTracking}/${pickup.id}'),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: AppTheme.cardBorder,
          boxShadow: AppTheme.cardShadow,
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
            const Divider(color: AppColor.hairline),
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
                  onTap: () => _guardedTap(
                    () => context.push(
                      '${AppRoutes.pickupTracking}/${pickup.id}',
                    ),
                  ),
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
      onTap: () =>
          _guardedTap(() => context.push(AppRoutes.donationCategorySelection)),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: Border.all(color: AppTheme.cardBorderColor),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColor.roseTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColor.rose,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'समुदाय को वापस दें' : 'Give Back to Community',
                    style: const TextStyle(
                      color: AppColor.rose,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
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
                      Text(
                        isHindi ? 'वस्तुएं दान करें' : 'Donate Items',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHindi
                            ? 'पुनः उपयोगी वस्तुएं दान करें'
                            : 'Donate reusable goods',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isHindi
                            ? 'कपड़े और पुराने फर्नीचर जैसी वस्तुएं दान करके समाज की मदद करें।'
                            : 'Support social causes by donating clothes and old furniture.',
                        style: const TextStyle(
                          fontSize: 12,
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
                        color: AppColor.roseTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        color: AppColor.rose,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColor.rose,
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

  Widget _buildCorporateCard(BuildContext context) {
    final isHindi = context.locale.languageCode == 'hi';

    return InkWell(
      onTap: () => _guardedTap(() => context.push(AppRoutes.corporateCategory)),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: Border.all(color: AppTheme.cardBorderColor),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColor.alertBlue,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.business_rounded,
                    color: AppColor.info,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'कॉर्पोरेट कोटेशन' : 'Corporate Quotation',
                    style: const TextStyle(
                      color: AppColor.info,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
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
                      Text(
                        isHindi ? 'कॉर्पोरेट पिकअप' : 'Corporate Pickup',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHindi
                            ? 'कोटेशन के लिए जानकारी भेजें'
                            : 'Share details for quotation',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isHindi
                            ? 'थोक स्क्रैप/ऑफिस कचरे के लिए शेड्यूल करें। हमारी टीम निरीक्षण के बाद कोटेशन देगी।'
                            : 'Schedule bulk scrap or office waste pickup. Our team will quote after assessment.',
                        style: const TextStyle(
                          fontSize: 12,
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
                        color: AppColor.alertBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: AppColor.info,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColor.info,
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
      onTap: () => _guardedTap(
        () => context.push('${AppRoutes.pickupTracking}/${pickup.id}'),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.cardBorderRadius,
          border: AppTheme.cardBorder,
          boxShadow: AppTheme.cardShadow,
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
        borderRadius: AppTheme.cardBorderRadius,
        border: AppTheme.cardBorder,
        boxShadow: AppTheme.cardShadow,
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
      case 'rescheduled':
        return 'Rescheduled';
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
        return AppTheme.infoColor;
      case 'rescheduled':
        return const Color(0xFF7C3AED);
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

  /// Website-matching rectangular category card used in the horizontal scroll.
  Widget _buildMaterialCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required bool isDark,
    required VoidCallback onTap,
    String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () => _guardedTap(onTap),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColor.cardBorder),
          boxShadow: AppTheme.e1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image panel — warm cream like website cards
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _imagePanelColor(title),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => Center(
                            child: FaIcon(
                              iconData,
                              color: AppColor.primary,
                              size: 32,
                            ),
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColor.primary,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: FaIcon(
                          iconData,
                          color: AppColor.primary,
                          size: 32,
                        ),
                      ),
              ),
            ),
            // Label
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.deepNavy,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.arrow_forward_rounded,
                          size: 11, color: AppColor.primary),
                      const SizedBox(width: 3),
                      const Text(
                        'Explore',
                        style: TextStyle(
                          color: AppColor.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _imagePanelColor(String seed) {
    const palette = <Color>[
      Color(0xFFEAF4EC),
      Color(0xFFF1EFE7),
      Color(0xFFF2F3F7),
      Color(0xFFEEF5F2),
      Color(0xFFF6F1E8),
      Color(0xFFE9F0EB),
    ];
    final index = seed.trim().isEmpty
        ? 0
        : seed.codeUnits.fold<int>(0, (a, b) => a + b) % palette.length;
    return palette[index];
  }
}
