# Scrapify Backend Handoff

## Purpose
This document lists the backend work required to make the current Flutter app production-ready across all active user roles.

It is based on:
- current frontend implementation in `lib/`
- `api-docs.json`
- `openapi.yaml`

## New Priority Rule Script
For Channel Partner + Warehouse verification/limit workflow, refer to:
- `backend-channel-partner-warehouse-verification-script.md`

## Roles In App
The current app UI supports these business roles:
- `customer`
- `pickup_partner` (mapped to backend `pickup_boy`)
- `dealer` (mapped to backend `channel_partner`)
- `warehouse`

Current frontend mapping is implemented in:
- `lib/core/network/api_role_mapper.dart`

Current mapping:
- `pickup_partner -> pickup_boy`
- `dealer -> channel_partner`
- `warehouse -> admin`

## Immediate Backend Concern
`warehouse -> admin` is not a safe long-term mapping.

Backend should confirm final role model:
- Is `warehouse` a real role?
- Is `channel_partner` the final backend name for dealer?
- Is warehouse intended to use admin permissions or its own restricted role?

If not fixed, authorization will become brittle as flows expand.

---

# 1. Current Frontend Flow Coverage

## 1.1 Already Integrated With Backend
These flows are already wired in the app and should be considered active contracts:

### Authentication
- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`
- `GET /api/auth/profile`
- `POST /api/auth/logout`

### Profile
- `POST /api/auth/profile/update`
- `GET /api/auth/profile/addresses`
- `POST /api/auth/profile/addresses`
- `PUT /api/auth/profile/addresses/{id}`
- `DELETE /api/auth/profile/addresses/{id}`
- `GET /api/auth/profile/payment-details`
- `POST /api/auth/profile/payment-details`
- `PUT /api/auth/profile/payment-details/{id}`
- `DELETE /api/auth/profile/payment-details/{id}`

### Notifications
- `GET /api/notifications`
- `POST /api/notifications/{id}/read`
- `POST /api/notifications/read-all`

### Category Browse Flow
- `GET /api/categories`
- `GET /api/subcategories`
- `GET /api/items`
- `GET /api/home-appliances/details`

## 1.2 Partially Implemented In Frontend But Not Fully Backed
These flows exist in UI but are not fully connected to backend:
- create pickup request
- upload booking images
- review booking
- payout selection during booking
- pickup success confirmation
- pickup tracking
- order history
- pickup boy dashboard
- warehouse dashboard
- dealer/partner dashboard

## 1.3 Mostly Mock / Static In Frontend
These screens exist but are not driven by backend data yet:
- pickup boy dashboard
- warehouse dashboard
- partner dashboard
- pickup tracking
- some customer active request cards on dashboard
- some booking details screens

---

# 2. Backend Endpoints Required For Production

## 2.1 Customer Booking Flow
This is the highest priority missing backend work.

### Required Endpoints
- `POST /api/pickup-request`
- `GET /api/pickup-requests`
- `GET /api/pickup-requests/{id}`
- `POST /api/pickup-requests/{id}/reschedule`
- `POST /api/pickup-requests/{id}/cancel` or `DELETE` equivalent
- `GET /api/pickup-requests/{id}/tracking`

### Why needed
Frontend already collects:
- selected items
- selected appliance options
- selected address
- pickup date/time
- payout method
- images

But the app currently does not send one finalized backend booking request from this assembled state.

### Required request shape for `POST /api/pickup-request`
Backend must finalize one request structure and keep it stable.

Recommended request:
```json
{
  "address_id": 12,
  "city_id": 1,
  "latitude": 19.0760,
  "longitude": 72.8777,
  "scheduled_at": "2026-04-10T14:00:00+05:30",
  "payout_method": "upi",
  "customer_name": "Amit Sinha",
  "customer_phone": "9999999999",
  "image_ids": [21, 22],
  "items": [
    {
      "category_id": 3,
      "quantity": 2,
      "weight": null,
      "selected_options": []
    },
    {
      "category_id": 39,
      "quantity": 1,
      "weight": null,
      "selected_options": [
        {"section_slug": "brand", "option_id": 2},
        {"section_slug": "capacity", "option_id": 7},
        {"section_slug": "body_type", "option_id": 11},
        {"section_slug": "condition", "option_id": 13}
      ]
    }
  ]
}
```

### Important backend decision
Backend must decide whether `items[].category_id` is enough, or whether frontend should send:
- `category_id`
- `subcategory_id`
- `item_id`

This must be explicit.

### Required response shape
```json
{
  "success": true,
  "code": 201,
  "message": "pickup.created",
  "message_text": "Pickup request created successfully",
  "data": {
    "id": 1042,
    "pickup_code": "SCR-1042",
    "status": "pending",
    "estimated_amount": 3120,
    "scheduled_at": "2026-04-10T14:00:00+05:30"
  },
  "errors": null
}
```

## 2.2 Booking Image Upload
Current frontend image flow is local only.

### Backend must choose one official strategy

### Option A: Separate upload endpoint before booking
- `POST /api/pickup-images/upload`
- returns uploaded `image_ids`
- booking request references those ids

Recommended response:
```json
{
  "success": true,
  "data": {
    "images": [
      {"id": 21, "url": "https://.../1.jpg"},
      {"id": 22, "url": "https://.../2.jpg"}
    ]
  }
}
```

### Option B: Upload inside create booking
- multipart booking request including images

Recommendation:
- Use separate upload endpoint.
- It is easier for retries, validation, and draft booking UX.

## 2.3 Customer Orders / Tracking
Customer dashboard already assumes an orders/tracking flow.

### Required Endpoints
- `GET /api/pickup-requests`
- `GET /api/pickup-requests/{id}`
- `GET /api/pickup-requests/{id}/tracking`
- `POST /api/pickup-requests/{id}/reschedule`
- `POST /api/pickup-requests/{id}/cancel`

## 2.4 Donation Pickup Flow
This should be a separate flow from normal scrap pickup creation.

### Business purpose
User creates a pickup request for donation items such as:
- clothes
- old furniture
- reusable household goods

This flow must not calculate payout, price per unit, estimated scrap amount, or any money-related value.

### Required backend behavior
- same overall pickup lifecycle as normal pickup request
- separate donation endpoint and model, or a pickup subtype with explicit `request_type=donation`
- no monetary calculation
- no payout method required
- no payment detail required
- status and tracking can follow the normal pickup lifecycle

### Recommended endpoints
- `POST /api/donation-request`
- `GET /api/donation-requests`
- `GET /api/donation-requests/{id}`
- `GET /api/donation-requests/{id}/tracking`

### Clone existing pickup as donation
If backend wants a one-click clone flow from an old pickup request, add:
- `POST /api/pickup-requests/{id}/clone-as-donation`

This endpoint should:
- copy address
- copy city, latitude, longitude
- copy images if business allows
- copy item lines
- clear all payout/payment fields
- force donation mode
- skip all amount calculations

### Required request shape for `POST /api/donation-request`
Recommended multipart shape, same style as pickup create:

```text
address=62728, Ashok Vihar Phase II, Gurugram, Haryana, 122006
address_id=4
city_id=1
scheduled_at=2026-04-20 10:00:00
donation_category=clothes
notes=Old wearable clothes for donation
images[]=@/path/to/image1.jpg
items[0][category_id]=21
items[0][quantity]=2
items[0][weight]=5.5
items[0][attributes][0][attribute_id]=1
items[0][attributes][0][value]=Reusable
```

### Important validation rules
- `payout_method` must not be required
- `payment_detail_id` must not be required
- `estimated_amount` must not be calculated
- `price_per_unit` and `total_price` should be omitted or stored as `0` consistently
- item category validation should support donation categories, not only scrap categories

### Recommended request body alternative for clone creation
If cloning from an existing pickup is the main use case:

```json
{
  "source_pickup_request_id": 42,
  "scheduled_at": "2026-04-20T10:00:00+05:30",
  "notes": "Donate same items instead of selling",
  "reuse_images": true
}
```

### Required response shape
```json
{
  "success": true,
  "code": 201,
  "message": "donation.created",
  "message_text": "Donation request created successfully",
  "data": {
    "id": 2042,
    "pickup_code": "DON-2042",
    "request_type": "donation",
    "status": "pending",
    "estimated_amount": null,
    "scheduled_at": "2026-04-20T10:00:00+05:30"
  },
  "errors": null
}
```

### Backend note
If backend does not want a separate donation table, then normal pickup requests must support:
- `request_type = scrap | donation`
- nullable payout/payment fields
- nullable monetary fields
- branch logic that skips pricing when `request_type=donation`

### Required tracking response example
Tracking response must also include pickup location data for the customer tracking screen.

Minimum required location fields:
- `address`
- `latitude`
- `longitude`
- `city_name` or equivalent display-friendly city/location string

If the pickup is already assigned, backend should also include agent display fields when available:
- `agent.name`
- `agent.phone`
- `agent.latitude`
- `agent.longitude`
- `agent.vehicle_number` or equivalent

Without these fields, frontend cannot render:
- pickup location text
- map pin for pickup destination
- live agent/location state when order is assigned or in progress

```json
{
  "success": true,
  "data": {
    "id": 1042,
    "pickup_code": "SCR-1042",
    "status": "assigned",
    "scheduled_at": "2026-04-10T14:00:00+05:30",
    "address": "62728, Ashok Vihar Phase II, Gurugram, Haryana",
    "city_name": "Gurugram",
    "latitude": 28.48453794,
    "longitude": 77.02096157,
    "estimated_amount": 3120,
    "final_amount": null,
    "agent": {
      "id": 8,
      "name": "Ravi Kumar",
      "phone": "9876543210",
      "vehicle_number": "DL-01-AB-1234",
      "latitude": 28.486,
      "longitude": 77.022
    },
    "timeline": [
      {
        "status": "pending",
        "label": "Pickup requested",
        "time": "2026-04-09T18:40:00+05:30"
      },
      {
        "status": "assigned",
        "label": "Pickup assigned",
        "time": "2026-04-09T19:10:00+05:30"
      }
    ]
  }
}
```

## 2.4 Pickup Boy Flow
The pickup partner dashboard is currently mock-only.

### Required Endpoints
- `GET /api/pickup-boy/pickups`
- `GET /api/pickup-boy/pickups/{id}`
- `POST /api/pickup-boy/pickups/{id}/accept`
- `POST /api/pickup-boy/pickups/{id}/reject`
- `POST /api/pickup-boy/pickups/{id}/status`
- `POST /api/pickup-boy/pickups/{id}/verify`
- `POST /api/pickup-boy/status` for online/offline toggle

### Required status transitions
- `assigned`
- `accepted`
- `on_the_way`
- `arrived`
- `verifying`
- `picked_up`
- `completed`
- `cancelled`

### Verify endpoint notes
Your docs already include:
- `POST /api/pickup-boy/pickups/{id}/verify`

Backend should also define response shape including:
- verified item values
- final payout
- verification image urls
- next status

Example:
```json
{
  "success": true,
  "data": {
    "pickup_id": 1042,
    "status": "picked_up",
    "final_amount": 2890,
    "verified_items": [
      {"id": 1, "weight": 12.5, "quantity": 2}
    ]
  }
}
```

## 2.5 Admin Assignment Flow
Current docs include:
- `POST /api/admin/pickups/{id}/assign`

This is good, but backend still needs supporting list APIs.

### Required Endpoints
- `GET /api/admin/pickups`
- `GET /api/admin/pickup-boys`
- `POST /api/admin/pickups/{id}/assign`

### Assignment response example
```json
{
  "success": true,
  "data": {
    "pickup_id": 1042,
    "assigned_to": {
      "id": 8,
      "name": "Ravi Kumar"
    },
    "status": "assigned"
  }
}
```

## 2.6 Dealer / Channel Partner Flow
Dealer dashboard exists in UI but has no real backend support.

### Required Endpoints
- `GET /api/channel-partner/dashboard`
- `GET /api/channel-partner/customers`
- `GET /api/channel-partner/payouts`
- `POST /api/channel-partner/withdrawals`
- `GET /api/channel-partner/withdrawals`

### Needed data
- total earnings
- pending payouts
- recent orders
- frequent customers
- withdrawal eligibility

## 2.7 Warehouse Flow
Warehouse dashboard is static UI right now.

### Required Endpoints
- `GET /api/warehouse/dashboard`
- `GET /api/warehouse/shipments`
- `GET /api/warehouse/{id}`
- `POST /api/warehouse/{id}/inventory`
- `GET /api/warehouse/{id}/inventory/summary`

### Needed data
- inbound weight today
- items ready for processing
- recent shipments
- per-category inventory totals

## 2.8 Payment Approval Flow
Current docs include:
- `POST /api/admin/payments/{id}/approve`

This is useful but incomplete for operational UI.

### Required additional endpoints
- `GET /api/admin/payments`
- `GET /api/admin/payments/{id}`
- `POST /api/admin/payments/{id}/approve`

### Response example
```json
{
  "success": true,
  "data": {
    "id": 88,
    "status": "approved",
    "remarks": "Settlement approved",
    "updated_at": "2026-04-09T21:00:00+05:30"
  }
}
```

## 2.9 Location / Slot Management
Frontend currently uses hardcoded time slots.

### Required Endpoints
- `GET /api/states`
- `GET /api/cities`
- `GET /api/serviceable-cities`
- `GET /api/pickup-slots?city_id=1&date=2026-04-10`

### Recommended pickup slot response
```json
{
  "success": true,
  "data": [
    {
      "id": "10_1",
      "label": "10:00 AM - 01:00 PM",
      "start": "10:00",
      "end": "13:00",
      "available": true
    },
    {
      "id": "14_2",
      "label": "02:00 PM - 05:00 PM",
      "start": "14:00",
      "end": "17:00",
      "available": false
    }
  ]
}
```

---

# 3. Home Appliance API Requirements
This area is now partially integrated from frontend.

Current active endpoint:
- `GET /api/home-appliances/details?category_id=<id>`

## Required contract for this endpoint
```json
{
  "success": true,
  "data": {
    "id": 39,
    "name": "Air Conditioner",
    "estimated_price": 4500,
    "sections": [
      {
        "title": "Brand",
        "slug": "brand",
        "options": [
          {"id": 1, "value": "Voltas"},
          {"id": 2, "value": "LG"}
        ]
      },
      {
        "title": "Capacity",
        "slug": "capacity",
        "options": [
          {"id": 10, "value": "1 Ton"},
          {"id": 11, "value": "1.5 Ton"}
        ]
      },
      {
        "title": "Condition",
        "slug": "condition",
        "options": [
          {"id": 21, "value": "Working"},
          {"id": 22, "value": "Non-Working"}
        ]
      }
    ]
  }
}
```

## Critical backend requirement
When customer books a home appliance, backend must accept selected option ids in booking payload and recalculate estimated amount server-side.

Frontend should not be price authority.

---

# 4. Standard Response Format
Backend should standardize one response format.

## Recommended success format
```json
{
  "success": true,
  "code": 200,
  "message": "pickup.created",
  "message_text": "Pickup created successfully",
  "data": {},
  "errors": null
}
```

## Recommended error format
```json
{
  "success": false,
  "code": 422,
  "message": "validation.failed",
  "message_text": "Validation failed",
  "data": null,
  "errors": {
    "phone": ["Phone is required"]
  }
}
```

## Why this matters
Current docs and live responses are mixed:
- `success`
- `status`
- `message`
- `message_text`
- `code`

Frontend can be made tolerant, but backend should not keep drifting.

---

# 5. Recommended Status Enums
These enums should be finalized and reused consistently.

## Pickup Status
Recommended enum:
- `pending`
- `assigned`
- `accepted`
- `on_the_way`
- `arrived`
- `verifying`
- `picked_up`
- `completed`
- `cancelled`
- `rescheduled`
- `failed`

## Payment / Settlement Status
Recommended enum:
- `pending`
- `processing`
- `approved`
- `paid`
- `failed`
- `rejected`

## Notification Type
Recommended enum:
- `pickup_created`
- `pickup_assigned`
- `pickup_rescheduled`
- `pickup_cancelled`
- `pickup_verified`
- `pickup_completed`
- `payment_approved`
- `payment_failed`

## User Role
Recommended enum:
- `customer`
- `pickup_boy`
- `channel_partner`
- `warehouse`
- `admin`

Recommendation:
- do not overload `admin` to mean `warehouse`

---

# 6. Role Permissions Matrix

## Customer
Allowed:
- send OTP
- verify OTP
- view/update profile
- manage addresses
- manage payment details
- browse categories/subcategories/items
- fetch home appliance details
- create pickup request
- view own pickup requests
- view own tracking
- reschedule/cancel own eligible pickups
- read own notifications

Should not access:
- assign pickup
- verify pickup as pickup boy
- warehouse inventory
- admin payment approval

## Pickup Boy
Allowed:
- auth/profile/notifications
- list assigned pickups
- view pickup details
- accept/reject assignment
- update travel/status
- verify items
- upload verification images
- mark pickup completed

Should not access:
- customer-only private addresses/payment methods of other users
- admin assignment APIs
- admin payment approval

## Channel Partner / Dealer
Allowed:
- auth/profile/notifications
- create pickup request on behalf of customer if business requires it
- view own business bookings
- view earnings/payout history
- request withdrawals

Should not access:
- pickup boy verification
- warehouse inventory
- admin payment approval unless explicitly intended

## Warehouse
Allowed:
- auth/profile/notifications
- warehouse dashboard
- inbound shipment list
- inventory operations
- inventory summary

Should not access:
- admin-only user management
- payment approval unless intended

## Admin
Allowed:
- view all pickups
- assign pickups
- manage payment approvals
- view users by role
- high-level dashboard access

---

# 7. Contract Clarifications Backend Must Confirm
These are questions backend must answer before integration is considered stable.

1. Is `/api/categories` authenticated or public?
2. Is category name always a string, or multilingual object `{en, hi}`?
3. Should frontend send `category_id`, `subcategory_id`, or `item_id` in booking items?
4. How should home appliance selected options be submitted?
5. Are images uploaded before booking, or with booking?
6. Is warehouse a distinct role or admin alias?
7. What is the final backend role name for dealer: `dealer` or `channel_partner`?
8. What are the final allowed pickup status transitions?
9. Can customer reschedule after assignment, or only before assignment?
10. Which APIs are paginated and what is the standard pagination structure?

---

# 8. Recommended Pagination Standard
For all list endpoints:
```json
{
  "success": true,
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "per_page": 20,
      "total": 124,
      "total_pages": 7
    }
  }
}
```

Use this for:
- pickup requests
- notifications
- warehouse shipments
- payments
- partner payouts
- admin pickup lists

---

# 9. Priority Order For Backend Team

## Priority 1
- finalize role names and permissions
- standardize API response shape
- finalize booking request payload
- finalize image upload workflow

## Priority 2
- customer pickup list/detail/tracking APIs
- pickup status lifecycle
- reschedule/cancel rules

## Priority 3
- pickup boy assigned list/status/verify APIs
- admin assignment flow support APIs

## Priority 4
- warehouse dashboard/inventory APIs
- channel partner earnings/payout APIs
- payment approval list/detail APIs

## Priority 5
- serviceable cities and dynamic pickup slots
- notification unread count and FCM token flow

---

# 10. Final Summary For Backend Developer
Backend is not fully ready for the full multi-user app flow yet.

What is currently usable:
- auth
- profile
- addresses
- payment methods
- notifications
- categories/items
- home appliance details

What must still be completed for production:
- real booking creation
- booking image uploads
- customer orders/tracking
- pickup boy operational APIs
- warehouse APIs
- channel partner earnings APIs
- admin support APIs
- stable role/permission model
- consistent response structure
