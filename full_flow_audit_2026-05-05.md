# Scrapify Full Booking Flow Audit (All Roles, All Environments)

Date: 2026-05-05  
Scope: Flutter app + backend APIs  
Audit mode: Static end-to-end code audit + contract/path validation (no live backend execution in this pass)

## 1) Executive Summary (Pass/Fail)
**Overall Result: FAIL (Not production-safe yet)**

Reasons:
- P0 payload mismatch can show fake success data.
- P0 coupon is applied in UI but not transmitted to backend.
- P1 shared-device basket leakage risk.
- P1 no router-level auth/role guard.
- P1 backend-slot endpoint exists but UI uses hardcoded slots.
- P2 hardcoded Google Maps key in source.

---

## 2) Critical Blockers (P0)

### P0-1: Success screen receives wrong payload shape from payout flow
- Area: `Customer scrap booking`
- Type: `Frontend`
- User impact: `Single-user` (incorrect success/tracking context)
- Risk: User can land on success screen with fallback static booking code and fallback address, not real booking data.

Evidence:
- Success route expects map payload:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/core/utils/app_routes.dart` (route `/pickup/success`, expects `extra['pickup']`, `extra['isDonation']`)
- Payout flow sends raw object instead:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/pickup/presentation/payout_method_screen.dart` (`context.go(..., extra: createdPickup)`)
- Success screen fallback:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/pickup/presentation/success_confirmation_screen.dart` (`SCR-2026-001`, fallback address)

Reproduction steps:
1. Login as customer.
2. Complete scrap booking flow up to payout method.
3. Select UPI/Bank and submit.
4. Observe success screen shows fallback booking data when route extra map keys are absent.

Log/code snippet:
```dart
// payout_method_screen.dart (current)
context.go(AppRoutes.successConfirmation, extra: createdPickup);

// app_routes.dart expects
final extra = state.extra as Map<String, dynamic>?;
pickup: extra?['pickup']
```

Required fix:
- Change payout navigation to:
```dart
context.go(
  AppRoutes.successConfirmation,
  extra: {'pickup': createdPickup, 'isDonation': false},
);
```

---

### P0-2: `coupon_code` not sent in multipart pickup submit
- Area: `Customer scrap booking` (review/payout submit)
- Type: `Both` (Frontend serialization gap + Backend never receives field)
- User impact: `Single-user`, but pricing/accounting mismatch impacts reporting
- Risk: Coupon shown as applied in UI but ignored by backend final calculation.

Evidence:
- Coupon attached in booking payload:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/pickup/providers/booking_provider.dart` (`'coupon_code': state.appliedCouponCode`)
- Multipart builder omits coupon field:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/pickup/domain/repositories/pickup_repository.dart` (`_submitPickupForm` has no `coupon_code` add)

Reproduction steps:
1. Login as customer.
2. Build basket and apply valid coupon on review screen.
3. Submit pickup.
4. Inspect request body in API logs/proxy: `coupon_code` missing.

Log/code snippet:
```dart
// pickup_repository.dart _submitPickupForm(...)
_addFieldIfPresent(formData, 'payout_method', payload['payout_method']);
// missing coupon_code mapping here
```

Required fix:
```dart
_addFieldIfPresent(formData, 'coupon_code', payload['coupon_code']);
```

---

## 3) High Priority Issues (P1)

### P1-1: Basket persistence is global, not user-scoped
- Areas: `Customer scrap`, `Donation`, `Corporate` pre-book state contamination
- Type: `Frontend`
- User impact: `Multi-user`
- Risk: Shared device logout/login can expose previous user basket.

Evidence:
- Shared key:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/core/storage/app_preferences.dart` (`basket_items`)
- Session clear does not clear basket:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/auth/domain/repositories/auth_repository.dart` (`logout -> clearSession`, not basket)

Reproduction steps:
1. User A logs in and adds basket items.
2. User A logs out.
3. User B logs in on same device.
4. Basket items from user A are restored.

Log/code snippet:
```dart
static const String basketItemsKey = 'basket_items';
await prefs.remove(authTokenKey);
await prefs.remove(userDataKey);
// no basket clear in logout path
```

Required fix:
- Preferred: user-scoped key `basket_items_<userId>`.
- Minimum: clear basket during logout.

---

### P1-2: Slot API exists but date/time screen uses hardcoded slots
- Areas: `Customer scrap`, `Donation`, `Corporate scheduling`
- Type: `Both`
- User impact: `Multi-user`
- Risk: overbooking and stale availability; no server-side slot sync.

Evidence:
- Hardcoded slots:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/pickup/presentation/select_date_time_screen.dart`
- Endpoint available:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/core/network/api_endpoints.dart` (`/pickup-slots`)

Reproduction steps:
1. Open date/time selection.
2. Observe fixed slots always shown regardless of date/city.
3. Backend slot capacity changes are not reflected.

Log/code snippet:
```dart
final List<String> _timeSlots = [
  '10:00 AM - 01:00 PM',
  '02:00 PM - 05:00 PM',
];
```

Required fix:
- Integrate `/api/pickup-slots` with parameters (date, city_id, pincode).
- Disable unavailable slots and revalidate at submit.

---

### P1-3: No router-level role/auth route guard
- Areas: `All roles`
- Type: `Frontend`
- User impact: `Multi-user`
- Risk: direct route entry/deep links allow role-incompatible screens.

Evidence:
- Router has no `redirect` auth/role enforcement:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/core/utils/app_routes.dart`

Reproduction steps:
1. Login as customer.
2. Manually navigate to `/dashboard/warehouse` or `/dashboard/pickup`.
3. Screen access is attempted; failure occurs later by API instead of guard.

Required fix:
- Add centralized `GoRouter.redirect` guard based on token + primary role.
- Block role-incompatible route prefixes.

---

### P1-4: Corporate flow uses same success screen semantics as scrap
- Areas: `Corporate booking`
- Type: `Frontend`
- User impact: `Single-user`
- Risk: success/tracking labels can mislead if `request_type` handling is not explicit in UI.

Evidence:
- Corporate submit sends `request_type: corporate` correctly:
  - `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/pickup/presentation/corporate_review_screen.dart`
- Success screen only toggles by `isDonation` boolean.

Reproduction steps:
1. Create corporate request.
2. Observe generic pickup confirmation semantics (no explicit corporate context).

Required fix:
- Add `requestType` to success route payload and adapt labels/actions for corporate.

---

## 4) Medium Issues (P2)

### P2-1: Hardcoded Google Maps API key in source
- Area: `Customer review + map usage`
- Type: `Frontend`
- User impact: `Single-user` + platform security exposure
- Risk: key leakage, abuse, quota drain.

Evidence:
- `/Users/amitsinha/Devzign/flutter/scrapify/lib/core/network/api_endpoints.dart`

Reproduction steps:
1. Open source or decompile app.
2. Extract key from constants.

Required fix:
- Move key to env/build-time config.
- Restrict by bundle/package/signature and API scope.

---

### P2-2: Category contract parsing is brittle for `/api/categories`
- Area: `Customer catalog load`
- Type: `Frontend`
- User impact: `Single-user`
- Risk: parser expects list only; backend map-wrapped response can break.

Evidence:
- `/Users/amitsinha/Devzign/flutter/scrapify/lib/features/pickup/domain/repositories/category_repository.dart`
  - `final List<dynamic> list = data['data'] as List<dynamic>;`

Reproduction steps:
1. Backend returns `{ data: { items: [...] } }` shape.
2. Cast to `List<dynamic>` fails.

Required fix:
- Normalize parser as done in subcategories/items.

---

## 5) API Contract Gaps (Requested Endpoints)

### Validated from app code (implemented client integration exists)
- `/api/subcategories` (query `category_id`)
- `/api/items` (query `subcategory_id`)
- `/api/home-appliances/details` (query `category_id`)
- `/api/home-appliances/estimate` (payload with `category_id`, `attributes[]`)
- `/api/pickup-requests`
- `/api/donation-request`
- `/api/corporate-bookings`
- `/api/pickup-requests/{id}/tracking`
- pickup-boy and warehouse endpoint families are wired in repositories

### Gaps / inconsistencies
1. `/api/categories` parser expects `data` as list only; not resilient to `{data:{items}}`.
2. `/api/pickup-slots` endpoint is declared but not consumed in scheduling UI.
3. `coupon_code` prepared by state layer but omitted during multipart serialization to `/api/pickup-requests`.
4. Corporate success payload lacks explicit request-type representation in confirmation/tracking view layer.
5. Household estimate fallback behavior exists in UI, but backend contract for error semantics needs strict consistency (`422` with structured `errors` recommended).

---

## 6) Role-by-Role Flow Verdict

### Customer (scrap booking)
- Verdict: `Fail`
- Blocking issues: P0-1, P0-2, P1-2, P1-3

### Customer (donation booking)
- Verdict: `Partial Pass`
- Notes: no payout requirement is respected in review flow; still impacted by P1-2 and P1-3.

### Customer (corporate booking request)
- Verdict: `Partial Pass`
- Notes: payload contains `request_type: corporate`; requires success/tracking UX separation (P1-4), slot API integration, route guards.

### Pickup Boy
- Verdict: `Partial Pass`
- Notes: dashboard, assignments, accept/reject, status update, verify, reschedule-request endpoints are wired; live integration verification pending.

### Warehouse
- Verdict: `Partial Pass`
- Notes: list/detail/assign/reassign repository wiring present; payload consistency and post-action state integrity need live regression.

### Partner / Channel Partner
- Verdict: `Partial Pass`
- Notes: dashboard/orders endpoints wired; role mapping and route protection remain risk without router guard.

---

## 7) Recommended Fix Order
1. Fix success payload shape in payout flow (P0-1).
2. Add `coupon_code` multipart field and verify backend receives it (P0-2).
3. Implement per-user local basket isolation + clear on logout fallback (P1-1).
4. Integrate `/api/pickup-slots` in all scheduling screens (P1-2).
5. Add router `redirect` guard by auth and role (P1-3).
6. Add explicit corporate success/tracking context (P1-4).
7. Move Maps key to secured config and rotate key (P2-1).
8. Harden `/categories` parser for flexible response shapes (P2-2).

---

## 8) Regression Checklist After Fixes

### Customer Scrap
- [ ] Category -> subcategory -> items -> basket works on fresh login.
- [ ] Photo validations are category-aware.
- [ ] Date/time loads server slots; unavailable slot disabled.
- [ ] Coupon reflected both in UI and backend payload.
- [ ] Success page shows real pickup code/schedule/address.
- [ ] Tracking shows correct status, agent, timeline, amount summary.
- [ ] Cancel/reschedule/review flows persist and refresh correctly.

### Household Dynamic Pricing
- [ ] `GET /home-appliances/details` options load for each appliance category.
- [ ] `POST /home-appliances/estimate` updates live estimate on option change.
- [ ] Estimate failure fallback keeps UI functional without crash.
- [ ] Submitted payload preserves `attribute_id` + selected value integrity.

### Donation
- [ ] No payout method required.
- [ ] Correct payload sent to `/donation-request`.
- [ ] Success/tracking aligned with donation semantics.

### Corporate
- [ ] Payload includes `request_type=corporate`, notes, images, items.
- [ ] Success/list/tracking clearly tagged as corporate request.

### Pickup Boy
- [ ] Dashboard/assignments filters consistent with backend statuses.
- [ ] Accept/reject/status transitions reflect immediately.
- [ ] Verification submits expected items + images correctly.
- [ ] Reschedule request errors and refresh states handled.

### Warehouse
- [ ] Request list/status filters match backend counts.
- [ ] Detail loads required customer/item/location data.
- [ ] Assign + reassign with reason persists and refreshes list/detail.

### Partner / Channel Partner
- [ ] Dashboard/orders visible only for mapped role.
- [ ] Statuses and counts consistent with backend responses.

### Security / Multi-user
- [ ] User A -> logout -> User B login shows empty basket/state.
- [ ] Role-protected routes blocked via router redirect.
- [ ] Session expiry triggers clean forced logout and route reset.
- [ ] No hardcoded production secrets in app source.

---

## 9) Screenshots / Log Snippets for Failed Cases

Because this pass is static audit (no device-run capture), attached code-path snippets are provided as deterministic failure evidence:
- P0-1 route payload mismatch snippet (payout -> success).
- P0-2 missing `coupon_code` serialization snippet.
- P1-1 shared basket key + logout clear omission snippet.
- P1-2 hardcoded slot list snippet.

For final sign-off, capture runtime artifacts in next pass:
1. HTTP request dump for pickup submit with coupon.
2. Navigation payload log before success route.
3. Shared-device basket restore log across two users.
4. Slot API response + rendered availability screenshot.
