# Backend Update Spec (Priority Fixes from Audit)

Date: 2026-05-05  
Source: Full audit findings (`full_flow_audit_2026-05-05.md`)

## Priority
- **P0:** Must fix before production release
- **P1:** Fix in same release cycle
- **P2:** Security/reliability hardening

---

## P0 Requirements

### 1) Accept and process `coupon_code` in pickup creation
Endpoint:
- `POST /api/pickup-requests`

Required:
- Read multipart field `coupon_code`.
- Validate coupon ownership/eligibility.
- Apply coupon to estimated/final price response consistently.
- Return applied coupon metadata in response (`coupon_code`, discount/extra value).

Validation cases:
1. Coupon sent + valid -> 200 with applied coupon details.
2. Coupon sent + invalid/expired -> 422 with structured errors.
3. Coupon omitted -> no coupon behavior.

---

### 2) Keep success payload complete for UI correctness
Endpoints:
- `POST /api/pickup-requests`
- `POST /api/donation-request`
- `POST /api/corporate-bookings`

Required response fields in `data`:
- `id`
- `pickup_code`
- `scheduled_at`
- `address`
- `status`
- `items[]`
- `estimated_amount` (if available)
- `coupon_code` / discount metadata (if applied)

Reason:
- UI success/tracking pages must not rely on fallback static values.

---

## P1 Requirements

### 3) Implement dynamic slot availability and strict booking check
Endpoint:
- `GET /api/pickup-slots`

Recommended request:
- `date` (YYYY-MM-DD)
- `city_id`
- optional: `pincode`

Recommended response:
```json
{
  "success": true,
  "data": {
    "date": "2026-05-06",
    "slots": [
      {"id": 1, "label": "10:00 AM - 01:00 PM", "available": true, "capacity_left": 4},
      {"id": 2, "label": "02:00 PM - 05:00 PM", "available": false, "capacity_left": 0}
    ]
  }
}
```

Booking enforcement:
- Re-validate slot at submit (`pickup-requests`, `donation-request`, `corporate-bookings`) to prevent race-condition overbooking.

---

### 4) Household estimate endpoint finalization
Endpoint:
- `POST /api/home-appliances/estimate`

Request:
```json
{
  "category_id": 3,
  "attributes": [
    {"attribute_id": 101, "attribute_name": "Brand", "option_id": 1001, "value": "Voltas"}
  ]
}
```

Success response:
```json
{
  "success": true,
  "message": "Estimated price calculated",
  "data": {
    "estimated_price": 4700
  }
}
```

Error response (recommended 422):
```json
{
  "success": false,
  "message": "Invalid attribute selection",
  "errors": {
    "attributes": ["Option does not belong to category"]
  }
}
```

Behavior:
- Validate category/attribute/option linkage.
- Keep p95 latency under 300ms.
- Deterministic pricing for same inputs.

---

## P2 Requirements

### 5) Contract normalization for catalog endpoints
Endpoints:
- `GET /api/categories`
- `GET /api/subcategories`
- `GET /api/items`

Requirement:
- Keep response structure consistent across these three endpoints.
- Prefer one stable shape:
```json
{ "success": true, "data": [ ... ] }
```
(or document and enforce `data.items` shape consistently everywhere)

---

## Cross-Role Contract Checks
Ensure role authorization and payload behavior are strict for:
- Customer endpoints (`pickup-requests`, `donation-request`, `corporate-bookings`)
- Pickup-boy endpoints (`/pickup-boy/*`)
- Warehouse endpoints (`/warehouse/*`)
- Partner/channel-partner endpoints (`/channel-partner/*`)

Required:
1. 401 for unauthenticated.
2. 403 for wrong role.
3. No cross-user data exposure in list/detail APIs.
4. Status transitions enforce valid state machine.

---

## QA Sign-off Cases (Backend)
1. Coupon applied value in submit response equals coupon service output.
2. Same slot cannot be overbooked concurrently.
3. Invalid appliance option linkage rejected with structured error.
4. Tracking endpoint returns only owner/authorized-role request.
5. Warehouse reassign requires reason and persists audit trail.

---

## Implementation Notes
- Keep old clients backward-compatible where feasible.
- Version contracts or use tolerant parsers during rollout window.
- Add request-id logging for all booking submissions for traceability.
