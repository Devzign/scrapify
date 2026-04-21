# Scrapify — Full App Functionality & API Integration Reference

## Overview

Scrapify is a scrap pickup management platform with four user roles, each with a dedicated dashboard and feature set. All API calls go through `DioClient` (auto-attaches Bearer token, handles 401 → forced logout).

**Base URLs:**
- Dev: `http://127.0.0.1:8000/api`
- Staging / Production: `https://floralwhite-spoonbill-935004.hostingersite.com/api`

---

## Architecture

```
lib/
├── core/
│   ├── config/app_config.dart          — Flavor config (baseUrl, appName)
│   ├── network/dio_client.dart         — HTTP wrapper w/ Bearer token
│   ├── network/api_response.dart       — ApiResponse<T> typed wrapper
│   ├── session/session_controller.dart — Forced logout signaling
│   └── storage/app_preferences.dart   — SharedPreferences wrapper
├── features/
│   ├── auth/                           — OTP login, profile, session
│   ├── pickup/                         — Customer pickup requests & categories
│   ├── pickup_boy/                     — Pickup boy dashboard & assignments
│   ├── warehouse/                      — Warehouse admin dashboard
│   ├── channel_partner/                — Dealer/partner dashboard
│   ├── profile/                        — Profile, address, KYC, payment
│   ├── notifications/                  — Push notification inbox
│   └── settings/                       — Language & app settings
```

State management: **Riverpod** (`StateNotifierProvider`). Navigation: **GoRouter** with `AppRoutes.*` constants.

---

## Roles & Routes

| Role string (app) | API role | Login redirect |
|---|---|---|
| `customer` | `customer` | `/dashboard/customer` |
| `pickup_partner` | `pickup_boy` | `/dashboard/pickup` |
| `warehouse` | `admin` | `/dashboard/warehouse` |
| `dealer` | `channel_partner` | `/dashboard/partner` |

`ApiRoleMapper` handles bidirectional translation. `RoleRouteResolver.resolve(role)` returns the route after login.

---

## 1. Authentication Flow

**Provider:** `authProvider` (`StateNotifierProvider<AuthNotifier, User?>`)  
**Repository:** `AuthRepository` via `dioClientProvider`

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/send-otp` | Send OTP to phone number |
| `POST` | `/auth/verify-otp` | Verify OTP → returns token + user |
| `GET` | `/auth/profile` | Fetch current user profile |
| `POST` | `/auth/logout` | Logout (clears token) |

### Flow

1. User enters phone → `AuthRepository.sendOtp(phone)` → `POST /auth/send-otp`
2. User enters OTP → `AuthRepository.verifyOtp(phone, otp)` → `POST /auth/verify-otp`
3. Token + User saved in `AppPreferences`
4. `authProvider` state set to `User`
5. `RoleRouteResolver.resolve(user.role)` → navigates to role dashboard
6. On app restart: token loaded from prefs → `GET /auth/profile` to validate
7. 401 response anywhere → `SessionController` signals forced logout → `authProvider` clears state → redirects to login

---

## 2. Customer Flow

**Provider:** `pickupProvider` (`StateNotifierProvider<PickupNotifier, PickupState>`)  
**Repository:** `PickupRepository`, `CategoryRepository`

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/categories` | List scrap categories |
| `GET` | `/subcategories?category_id={id}` | Subcategories for a category |
| `GET` | `/items?subcategory_id={id}` | Items for a subcategory |
| `GET` | `/home-appliances/details?category_id={id}` | Home appliance pricing details |
| `POST` | `/pickup-request` | Create a scrap pickup request |
| `POST` | `/pickup-request` (donation flag) | Create a donation pickup request |
| `GET` | `/pickup-requests` | List all customer pickup requests |
| `GET` | `/pickup-requests?status={status}` | Filter requests by status |
| `GET` | `/pickup-requests/{id}` | Get single request details |
| `GET` | `/pickup-requests/{id}/tracking` | Get real-time tracking timeline |
| `POST` | `/pickup-requests/{id}/review` | Submit review after completion |
| `POST` | `/pickup-requests/{id}/cancel` | Cancel a pending request |

### Profile / Address / KYC / Payment Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/auth/profile/update` | Update name/email/profile fields |
| `GET` | `/auth/profile/addresses` | List saved addresses |
| `POST` | `/auth/profile/addresses` | Add new address |
| `PUT` | `/auth/profile/addresses/{id}` | Update address |
| `DELETE` | `/auth/profile/addresses/{id}` | Delete address |
| `GET` | `/auth/profile/payment-methods` | List payment methods |
| `POST` | `/auth/profile/payment-methods` | Add payment method |
| `DELETE` | `/auth/profile/payment-methods/{id}` | Remove payment method |
| `GET` | `/auth/profile/kyc` | Get KYC status |
| `POST` | `/auth/profile/kyc` | Submit KYC documents |

### Flow

1. Customer opens app → sees pickup history (GET `/pickup-requests`)
2. "New Pickup" → browse categories → subcategories → select items → enter address + schedule
3. `POST /pickup-request` creates request
4. Tracking screen polls `GET /pickup-requests/{id}/tracking` for real-time status
5. On completion → submit review via `POST /pickup-requests/{id}/review`
6. Customer can cancel pending requests via `POST /pickup-requests/{id}/cancel`
7. Donation flow: clone existing request as donation or create new donation pickup

---

## 3. Pickup Boy Flow

**Provider:** `pickupBoyProvider` (`StateNotifierProvider<PickupBoyNotifier, PickupBoyState>`)  
**Repository:** `PickupBoyRepository`

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/pickup-boy/dashboard` | Dashboard stats + today's assignments |
| `GET` | `/pickup-boy/assignments` | All assignments (filterable by status) |
| `GET` | `/pickup-boy/assignments?status={status}` | Filter assignments |
| `GET` | `/pickup-boy/pickups/{id}` | Single pickup details |
| `POST` | `/pickup-boy/pickups/{id}/accept` | Accept assigned pickup |
| `POST` | `/pickup-boy/pickups/{id}/reject` | Reject assigned pickup |
| `POST` | `/pickup-boy/pickups/{id}/status` | Update pickup status (en_route, arrived, collecting, completed) |
| `POST` | `/pickup-boy/pickups/{id}/verify` | Upload verification photo + confirm weight |
| `POST` | `/pickup-boy/pickups/{id}/reschedule-request` | Request reschedule with reason |
| `POST` | `/pickup-boy/status` | Toggle online/offline status |
| `POST` | `/pickup-boy/location` | Update GPS coordinates |

### Dashboard Data (`PickupBoyDashboard` model)

- `todayAssignments` — list of today's assignments
- `completedToday` — int
- `pendingCount` — int
- `totalEarnings` — double
- `rating` — double

### Assignment Data (`PickupAssignment` model)

- `id`, `orderCode`, `status`
- `customerName`, `customerPhone`
- `address`, `latitude`, `longitude`
- `scheduledAt`, `itemCount`, `estimatedWeight`

### Flow

1. Pickup boy opens app → dashboard loads via `GET /pickup-boy/dashboard`
2. Toggle online/offline → `POST /pickup-boy/status`
3. Periodic location update → `POST /pickup-boy/location`
4. Assignment card: Call button → `tel:{customerPhone}` (url_launcher)
5. Map button → `google.com/maps` with lat/lng or address (url_launcher)
6. Accept/Reject assignment → respective POST endpoints
7. Status progression: `assigned` → `accepted` → `en_route` → `arrived` → `collecting` → `completed`
8. Verification: upload photo via `image_picker` → multipart POST to `/verify`
9. Reschedule: POST with reason → goes to warehouse for approval

---

## 4. Warehouse Flow

**Provider:** `warehouseProvider` (`StateNotifierProvider<WarehouseNotifier, WarehouseState>`)  
**Repository:** `WarehouseRepository`

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/warehouse/dashboard` | Dashboard stats + recent requests |
| `GET` | `/warehouse/requests` | All pickup requests |
| `GET` | `/warehouse/requests?status={status}` | Filter by status |
| `GET` | `/warehouse/requests/{id}` | Request details |
| `GET` | `/warehouse/requests/{id}/assignable-pickup-boys` | Available boys for this request |
| `POST` | `/warehouse/requests/{id}/assign` | Assign pickup boy |
| `POST` | `/warehouse/requests/{id}/reassign` | Reassign with reason |
| `GET` | `/warehouse/pickup-boys` | All pickup boys under warehouse |
| `GET` | `/warehouse/profile` | Warehouse profile |

### Dashboard Data (`WarehouseDashboard` model)

- `totalRequests`, `unassignedRequests`, `assignedRequests`
- `activePickups`, `completedPickups`, `rescheduledRequests`
- `totalPickupBoys`, `availablePickupBoys`
- `warehouse` (nested: name, location)
- `recentRequests` — `List<dynamic>` parsed via `WarehouseRequest.fromJson()`

### Pickup Boy Data (`WarehousePickupBoy` model)

- `id`, `name`, `phone`, `isOnline`, `isAvailable`
- `completedCount`, `currentAssignmentCount`

### Flow

1. Warehouse admin opens app → `GET /warehouse/dashboard` loads all metrics
2. Requests tab → `GET /warehouse/requests` with filter chips:
   - All / Unassigned / Assigned / In Progress / Completed / Rescheduled
3. Tap request → bottom sheet shows assignable boys (`GET assignable-pickup-boys`)
4. Select boy → `POST /assign` → success → reload requests
5. Reassign: shows reason text field → `POST /reassign`
6. Pickup Boys tab → `GET /warehouse/pickup-boys`
   - Status derived: `isOnline && isAvailable` → Available, `isOnline && !isAvailable` → On Route, `!isOnline` → Offline
   - Bento stats: onRoute count, daily completions, availability %

---

## 5. Channel Partner (Dealer) Flow

**Provider:** `channelPartnerProvider` (`StateNotifierProvider<ChannelPartnerNotifier, ChannelPartnerState>`)  
**Repository:** `ChannelPartnerRepository`

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/channel-partner/dashboard` | Dashboard stats + recent orders |
| `GET` | `/channel-partner/orders` | All orders under network |
| `GET` | `/channel-partner/orders?status={status}` | Filter orders by status |
| `GET` | `/channel-partner/orders/{id}` | Order detail |
| `GET` | `/channel-partner/pickup-boys` | All pickup boys in network |
| `GET` | `/channel-partner/warehouses` | All warehouses in network |
| `GET` | `/channel-partner/approval-requests` | Approval request inbox |
| `GET` | `/channel-partner/approval-requests?status={status}` | Filter approvals |
| `POST` | `/channel-partner/status-request` | Approve/reject a request |
| `GET` | `/channel-partner/profile` | Partner profile |

### Dashboard Data (`ChannelPartnerDashboard` model)

- `totalOrders`, `activeOrders`, `completedOrders`
- `activeWarehouses`, `pendingWarehouseApprovals`
- `totalPickupBoys`, `availablePickupBoys`, `activePickupBoys`
- `pendingPickupBoyApprovals`
- `cancelledOrders`, `rescheduledOrders`
- `recentOrders` — `List<dynamic>` parsed as `Map<String, dynamic>`

### Tabs

| Tab | Data source | Key action |
|---|---|---|
| Dashboard | `loadDashboard()` | Metrics bento, order health bar chart, recent orders |
| Orders | `loadOrders(status?)` | Filter chips, order cards with assign info |
| Team | `loadPickupBoys()` | Agent cards with call button, team efficiency stats |
| Warehouses | `loadWarehouses()` | Hub cards with pickup boy count + order count |
| Approvals | `loadApprovalRequests()` | Approve/reject buttons → `submitStatusRequest()` |

### Flow

1. Partner opens app → `GET /channel-partner/dashboard`
2. Order Health card: bar chart heights proportional to `cancelledOrders / rescheduledOrders`
3. Orders tab → filter by status → order cards show customer, schedule, assigned pickup boy
4. Team tab → pickup boy status: `is_online + is_available` → Available, `is_online + !is_available` → Busy, `!is_active` → Inactive
5. Warehouses tab → card grid with live count from API
6. Approvals tab → pending requests show Approve/Reject → `POST /channel-partner/status-request {request_id, status}` → reload list

---

## 6. Notifications

**Provider:** `notificationsProvider`  
**Repository:** `NotificationRepository`

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/notifications` | Inbox (all roles) |
| `POST` | `/notifications/{id}/read` | Mark single as read |
| `POST` | `/notifications/read-all` | Mark all as read |

---

## 7. Settings

**Repository:** `SettingsRepository`

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/app-settings` | Save app preferences |
| `POST` | `/app-settings/language` | Change language (EN/HI) |

---

## Provider Wiring Summary

| Provider | Notifier | State fields |
|---|---|---|
| `authProvider` | `AuthNotifier` | `User?` |
| `pickupProvider` | `PickupNotifier` | `pickups`, `currentPickup`, `tracking`, `isLoading` |
| `pickupBoyProvider` | `PickupBoyNotifier` | `dashboard`, `assignments`, `isLoading` |
| `warehouseProvider` | `WarehouseNotifier` | `dashboard`, `requests`, `pickupBoys`, `assignablePickupBoys`, `isLoading`, `isActionLoading` |
| `channelPartnerProvider` | `ChannelPartnerNotifier` | `dashboard`, `orders`, `pickupBoys`, `warehouses`, `approvalRequests`, `isLoading`, `isActionLoading` |
| `notificationsProvider` | `NotificationsNotifier` | `notifications`, `unreadCount`, `isLoading` |

---

## Screen → Provider Mapping

| Screen | Provider(s) | Status |
|---|---|---|
| `LoginPage` (OTP) | `authProvider` | ✅ Wired |
| `CustomerDashboard` | `pickupProvider` | ✅ Wired |
| `PickupHistoryPage` | `pickupProvider` | ✅ Wired |
| `TrackingPage` | `pickupProvider` | ✅ Wired |
| `CategoriesPage` | `categoryProvider` | ✅ Wired |
| `DonationItemsScreen` | `pickupProvider` | ✅ Wired |
| `ProfilePage` | `authProvider`, `profileProvider` | ✅ Wired |
| `PickupBoyDashboard` | `pickupBoyProvider`, `authProvider` | ✅ Wired |
| `PickupBoyDetailScreen` | `pickupBoyProvider` | ✅ Wired |
| `WarehouseDashboard` | `warehouseProvider`, `authProvider` | ✅ Wired |
| `WhRequestsPage` | `warehouseProvider` | ✅ Wired |
| `WhPickupBoysPage` | `warehouseProvider` | ✅ Wired |
| `WhProfilePage` | `warehouseProvider`, `authProvider` | ✅ Wired |
| `WhRequestDetailPage` | `warehouseProvider` | ✅ Wired (nav from requests list) |
| `AgentRescheduleRequestScreen` | `pickupBoyProvider` | ✅ Wired (nav from detail + pickupId route param) |
| `UserReschedulePickupScreen` | `pickupProvider` | ✅ Wired (pickupId route param + `reschedulePickup`) |
| `PartnerDashboardPage` | `channelPartnerProvider`, `authProvider` | ✅ Wired |
| `PartnerOrdersPage` | `channelPartnerProvider` | ✅ Wired |
| `PartnerTeamPage` | `channelPartnerProvider`, `authProvider` | ✅ Wired |
| `PartnerWarehousesPage` | `channelPartnerProvider`, `authProvider` | ✅ Wired |
| `PartnerApprovalsPage` | `channelPartnerProvider`, `authProvider` | ✅ Wired |

---

## Missing / Pending API Endpoints

The following endpoints are in the BRD but **not yet implemented on the backend** (frontend calls exist but may get empty responses):

| Endpoint | Used by | Notes |
|---|---|---|
| `POST /pickup-requests/{id}/reschedule` | Customer (`UserReschedulePickupScreen`) | Frontend wired; backend endpoint pending |
| `GET /channel-partner/orders/{id}` | Partner orders detail | Order detail view not built yet |
| `GET /donations` | Customer | Donation history list |
| Create/update pickup boys (partner) | Partner team | No POST endpoint for partner to onboard pickup boys |
| Create/update warehouses (partner) | Partner warehouses | No POST endpoint for partner to add hubs |

---

## Key Patterns

- **Auth guard**: `GoRouter` redirect checks `authProvider.state != null`; 401 in `DioClient` → `SessionController` forced logout
- **Loading states**: All pages show `CircularProgressIndicator` while `state.isLoading == true`
- **Pull-to-refresh**: All list pages wrapped in `RefreshIndicator` calling the load method
- **Error handling**: `state.error != null` shows error text; `ApiResponse.isSuccess` checked before using `.data`
- **Empty states**: All list pages show fallback UI when list is empty
- **Status colors**: Consistent color mapping across all roles — unassigned/pending→amber, active→green, completed→indigo, cancelled→red, rescheduled→pink
- **Phone calls**: `url_launcher` with `tel:` scheme on all pickup boy phone fields
- **Maps**: `url_launcher` with Google Maps URL — lat/lng preferred, address fallback
- **Image upload**: `image_picker` with multipart form for pickup verification photos
- **Number formatting**: `_fmt(int n)` helper with `NumberFormat.decimalPattern()` for comma-separated large numbers
- **Avatar**: Initial-letter `CircleAvatar` (no external image URLs in production)

---

## Flavors

| Flavor | Entry point | Base URL |
|---|---|---|
| dev | `lib/main_dev.dart` | `http://127.0.0.1:8000/api` |
| staging | `lib/main_staging.dart` | `https://floralwhite-spoonbill-935004.hostingersite.com/api` |
| production | `lib/main_production.dart` | `https://floralwhite-spoonbill-935004.hostingersite.com/api` |

Run with: `flutter run -t lib/main_dev.dart`
