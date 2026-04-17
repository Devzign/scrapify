# Pickup Boy App BRD

## 1. Document Overview

- Project: Pickup Boy Mobile App
- Backend role: `pickup_boy`
- App role label: Pickup Partner / Pickup Boy
- Platforms: Mobile app, backend APIs, admin/warehouse operations panel
- Version: 1.0

## 2. Purpose

Build a Pickup Boy mobile app that allows a pickup agent to:

- log in via OTP
- view assigned pickup tasks
- view dashboard summary
- call customer
- open navigation from current GPS to customer location
- update pickup travel status
- verify collected items
- add, modify, or remove items during verification
- complete pickup and generate final bill
- raise reschedule requests
- view pickup history
- view own profile

The pickup boy app is an execution app for field agents.

## 3. Confirmed Business Decisions

These points are already aligned with current product direction:

1. Pickup assignment and reassignment are handled by warehouse users.
2. Pickup boy app should support Call and Map actions.
3. QR verification is not part of phase 1 mobile flow.
   QR-related UI has been removed from app screens.
4. Pickup boy verification must support:
   - verify existing items
   - add more items
   - modify quantity/weight/rate/condition
   - remove items if customer did not provide them
5. Pickup completion should support final bill generation.
6. Reschedule flow is needed from pickup boy side.
7. History and profile are required as part of the flow.

## 4. Business Objective

The Pickup Boy app should help field agents:

- manage daily pickup assignments
- reduce delays in reaching customers
- verify actual collected items accurately
- generate final payout/bill after verification
- raise reschedule requests when pickup cannot happen as planned
- keep operational status updated for warehouse/admin/customer tracking

## 5. User Roles

### 5.1 Pickup Boy

Can:

- log in
- view assigned tasks
- view current and upcoming pickups
- call customer
- open map directions
- update status
- verify order
- add/update/remove items during verification
- submit final verification
- complete pickup
- request reschedule
- view history
- view own profile

Cannot:

- assign or reassign requests
- approve own changes
- access another pickup boy's data
- access global admin/warehouse controls

### 5.2 Warehouse User

Can:

- assign pickup boy to a request
- reassign request to another pickup boy

### 5.3 Admin

Can:

- audit pickup execution
- view tracking and verification
- inspect assignment history
- override if needed

## 6. In Scope

- OTP login
- pickup boy dashboard
- task list / assignments
- current task card
- upcoming route list
- order verification
- add/edit/remove verified items
- status update flow
- completion and bill generation
- agent reschedule request
- history list
- profile
- notifications

## 7. Out of Scope for Phase 1

- QR verification
- pickup assignment by pickup boy
- warehouse inventory operations
- advanced live-tracking control screens
- earnings/settlement dashboard unless explicitly added later

## 8. Assumptions

- pickup boy logs in using role `pickup_boy`
- warehouse assigns the pickup boy
- pickup boy sees only their own assigned requests
- call and map actions use customer phone and customer coordinates from backend
- app may send location updates to backend for operational purposes

## 9. Recommended App Navigation

Bottom tabs:

1. Home
2. History
3. Profile

Optional future:

- Stats / Eco-stats
- Notifications tab

## 10. High-Level App Flow

### 10.1 Login Flow

1. Pickup boy enters phone number.
2. App sends OTP with role `pickup_boy`.
3. User verifies OTP.
4. Backend returns auth token and user profile.
5. App routes user to Pickup Boy Dashboard.

### 10.2 Dashboard Flow

1. App loads dashboard summary.
2. User sees:
   - greeting
   - current date
   - pending count
   - completed count
   - current task
   - upcoming route
   - active/offline toggle if supported
3. User can:
   - call customer
   - open map
   - start pickup
   - go to history
   - open profile

### 10.3 Current Task Flow

1. User opens dashboard current task card.
2. User sees:
   - customer name
   - customer phone
   - address
   - expected items
   - scheduled slot
3. User actions:
   - Call
   - Map
   - Start Pickup

### 10.4 Verification Flow

1. Pickup boy opens verification screen.
2. App loads pickup details.
3. User sees expected items.
4. User can:
   - verify actual weight
   - change quantity
   - change condition
   - add new item
   - remove uncollected item
   - upload verification photos
5. App shows verification summary and final payout.
6. User completes verification and generates bill.

### 10.5 Completion Flow

1. Pickup boy submits verification.
2. Backend stores final verified items.
3. Backend calculates/returns final payout.
4. Backend generates final bill/invoice if enabled.
5. Pickup status becomes completed.

### 10.6 Reschedule Flow

1. Pickup boy opens reschedule request screen.
2. User selects reason.
3. User enters optional note.
4. App sends reschedule request.
5. Backend marks request as reschedule requested.
6. Customer/admin flow continues separately for slot confirmation.

### 10.7 History Flow

1. User opens History tab.
2. App shows completed / cancelled / rescheduled / past pickups.
3. User can filter by date/status.
4. User can open past pickup detail.

### 10.8 Profile Flow

1. User opens Profile.
2. User sees:
   - name
   - phone
   - profile image
   - verification badge if applicable
   - warehouse name if applicable
3. User can log out.

## 11. Functional Requirements

### 11.1 Dashboard

The app must show:

- pickup boy name
- current date
- pending pickup count
- completed pickup count
- current assigned task
- upcoming route list
- active/offline state

### 11.2 Current Task

The app must show:

- order code
- customer name
- customer phone
- address
- scheduled time
- expected items
- estimated weight

The app must allow:

- call customer
- open map directions
- start pickup

### 11.3 Order Verification

The app must allow:

- view expected items
- verify actual weight
- update quantity
- update condition
- add new item
- remove item
- upload verification photos
- submit final verification

### 11.4 Status Updates

The app must allow status updates such as:

- accepted
- on_the_way
- arrived
- verifying
- completed
- reschedule_requested

Exact final enum must be confirmed by backend.

### 11.5 Reschedule

The app must allow:

- choose reason
- write note
- submit reschedule request

### 11.6 History

The app must allow:

- list completed pickups
- list rescheduled/cancelled pickups
- open past pickup detail

### 11.7 Profile

The app must allow:

- view profile
- see assigned warehouse if applicable
- logout

### 11.8 Notifications

The app must support:

- new assignment
- reassignment
- status update reminder
- reschedule response
- admin/support message

## 12. Backend Flow

### 12.1 Authentication

- send OTP
- verify OTP
- issue token
- return pickup boy profile

### 12.2 Dashboard Aggregation

Backend should aggregate:

- pending count
- completed count
- current task
- upcoming route list
- pickup boy status

### 12.3 Assignment Visibility

Backend should return only tasks assigned to that pickup boy.

Pickup boy must not see:

- another pickup boy's assignments
- global warehouse/admin data

### 12.4 Travel Status Flow

1. Pickup boy accepts/starts task.
2. Pickup boy updates travel status.
3. Backend stores status updates.
4. Tracking timeline updates for operational visibility.

### 12.5 Verification Flow

1. Pickup boy opens pickup detail.
2. Backend returns expected item list.
3. Pickup boy submits actual verified item list.
4. Backend stores:
   - updated items
   - added items
   - removed items
   - final payout
   - photos
5. Backend optionally generates bill.

### 12.6 Reschedule Request Flow

1. Pickup boy submits reschedule request.
2. Backend stores request and reason.
3. Backend marks pickup as reschedule requested.
4. Customer/admin approval flow continues outside pickup boy app.

### 12.7 History Flow

Backend should provide completed and past pickup list scoped to pickup boy.

## 13. Business Rules

1. Pickup boy can only see assigned pickups.
2. Pickup boy cannot assign or reassign requests.
3. Warehouse user is responsible for assignment and reassignment.
4. QR verification is not required in phase 1.
5. Verification must support add/update/remove item actions.
6. Final bill generation should happen after final verification if enabled.
7. Call and Map require phone and coordinates in pickup payload.

## 14. Data Ownership Rules

All pickup-boy app records must be scoped by `pickup_boy_id` where applicable.

Visible entities:

- assigned pickup requests
- pickup detail for assigned requests
- own profile
- own history

## 15. Suggested Data Model

### 15.1 pickup_boys

- id
- warehouse_id
- channel_partner_id nullable
- name
- phone
- email
- profile_photo
- vehicle_number
- is_active
- is_online
- is_available
- last_active_at
- current_latitude nullable
- current_longitude nullable
- location_updated_at nullable
- created_at
- updated_at

### 15.2 pickup_requests

- id
- pickup_code
- customer_name
- customer_phone
- address
- latitude
- longitude
- scheduled_at
- status
- warehouse_id
- pickup_boy_id nullable
- estimated_amount nullable
- created_at
- updated_at

### 15.3 pickup_request_items

- id
- pickup_request_id
- item_id nullable
- item_name
- expected_weight nullable
- expected_quantity nullable
- verified_weight nullable
- verified_quantity nullable
- rate nullable
- condition nullable
- created_at
- updated_at

### 15.4 pickup_verification_logs

- id
- pickup_request_id
- pickup_boy_id
- payload_json
- final_payout_amount
- bill_id nullable
- created_at

### 15.5 pickup_assignment_history

- id
- pickup_request_id
- old_pickup_boy_id nullable
- new_pickup_boy_id
- assigned_by_user_id
- reason nullable
- created_at

## 16. Current APIs Already Documented in api-docs.json

These are already present in the current backend doc:

- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`
- `GET /api/auth/profile`
- `GET /api/pickup-boy/assignments`
- `GET /api/pickup-boy/pickups/{id}`
- `POST /api/pickup-boy/pickups/{id}/accept`
- `POST /api/pickup-boy/pickups/{id}/reject`
- `POST /api/pickup-boy/pickups/{id}/status`
- `POST /api/pickup-boy/pickups/{id}/verify`
- `POST /api/pickup-boy/status`
- `POST /api/pickup-boy/location`
- `GET /api/pickup-requests/{id}/tracking`
- `POST /api/pickup-requests/{id}/reschedule`

## 17. API Requirements

### 17.1 Auth

Reuse:

- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`

Request:

```json
{
  "phone": "9876543210",
  "role": "pickup_boy"
}
```

### 17.2 Pickup Boy Dashboard

Create:

- `GET /api/pickup-boy/dashboard`

Should return:

- pickup boy summary
- pending count
- completed count
- current task
- upcoming route

Suggested response:

```json
{
  "success": true,
  "data": {
    "pickup_boy": {
      "id": 14,
      "name": "Rahul",
      "phone": "9876543210",
      "profile_photo": null,
      "is_online": true,
      "is_available": true
    },
    "summary": {
      "pending_count": 3,
      "completed_count": 5
    },
    "current_task": {
      "pickup_id": 4921,
      "order_code": "SC9022",
      "customer_name": "Amit Kumar",
      "customer_phone": "9876543210",
      "address": "Flat 402, Sunshine Apts, Indiranagar, Bengaluru",
      "latitude": 12.9716,
      "longitude": 77.5946,
      "scheduled_at": "2026-04-14 10:30:00",
      "items_summary": "Newspapers, Iron Scrap",
      "estimated_weight_kg": 15,
      "status": "assigned"
    },
    "upcoming_route": []
  }
}
```

### 17.3 Pickup Boy Profile

Create or extend:

- `GET /api/pickup-boy/profile/status`

or ensure `GET /api/auth/profile` returns:

- id
- name
- phone
- role
- profile_photo
- vehicle_number
- warehouse name
- is_online
- is_available

### 17.4 Assignments / History

Reuse or extend:

- `GET /api/pickup-boy/assignments`

Needs filter support:

- `status=pending`
- `status=completed`
- `status=active`
- `date_from`
- `date_to`

If filters are not supported, backend should add them.

### 17.5 Pickup Detail

Reuse:

- `GET /api/pickup-boy/pickups/{id}`

Must return:

- order code
- customer details
- customer phone
- address
- latitude
- longitude
- scheduled_at
- expected items
- uploaded images
- notes
- status
- timeline summary

### 17.6 Status Update

Reuse:

- `POST /api/pickup-boy/pickups/{id}/status`

Needs supported enum for at least:

- on_the_way
- arrived
- verifying
- completed or completion-ready
- reschedule_requested

### 17.7 Verification

Extend existing:

- `POST /api/pickup-boy/pickups/{id}/verify`

Preferred request payload should support:

```json
{
  "verified_items": [
    {
      "pickup_item_id": 501,
      "item_id": 101,
      "item_name": "Iron Scrap",
      "weight_kg": 42.5,
      "quantity": 1,
      "rate_per_kg": 28,
      "condition": "mixed",
      "action": "updated"
    },
    {
      "pickup_item_id": null,
      "item_id": 205,
      "item_name": "Plastic Waste",
      "weight_kg": 5.0,
      "quantity": 1,
      "rate_per_kg": 12,
      "condition": "good",
      "action": "added"
    },
    {
      "pickup_item_id": 502,
      "item_id": 111,
      "item_name": "Newspaper",
      "quantity": 0,
      "action": "removed"
    }
  ],
  "final_payout_amount": 2090,
  "notes": "Customer added extra plastic waste",
  "images": []
}
```

Backend should return:

- saved verified items
- final payout
- bill/invoice id or url if generated

### 17.8 Completion / Bill Generation

If completion is separate, add:

- `POST /api/pickup-boy/pickups/{id}/complete`

If completion is part of verification, confirm this behavior clearly.

### 17.9 Reschedule Request

Create:

- `POST /api/pickup-boy/pickups/{id}/reschedule-request`

Request body:

```json
{
  "reason_code": "heavy_traffic",
  "reason_text": "Heavy Traffic",
  "additional_note": "Running late by 45 minutes"
}
```

### 17.10 Customer Reschedule Slots

Needed for the full linked flow:

- `GET /api/pickup-requests/{id}/reschedule-slots`
- `POST /api/pickup-requests/{id}/reschedule`

### 17.11 Tracking

Reuse:

- `GET /api/pickup-requests/{id}/tracking`

### 17.12 Status / Availability

Reuse:

- `POST /api/pickup-boy/status`

Should support:

```json
{
  "is_online": true
}
```

If `is_available` is also needed separately, backend should extend payload.

### 17.13 Location Update

Reuse:

- `POST /api/pickup-boy/location`

Suggested payload:

```json
{
  "latitude": 12.9716,
  "longitude": 77.5946,
  "vehicle_number": "DL01AB1234"
}
```

## 18. Screen-to-Backend Mapping

### Dashboard

- `GET /api/pickup-boy/dashboard`

### Current Task Card

- `GET /api/pickup-boy/dashboard`
or
- `GET /api/pickup-boy/assignments?status=active`

### Start Pickup / Status Changes

- `POST /api/pickup-boy/pickups/{id}/status`

### Order Verification Screen

- `GET /api/pickup-boy/pickups/{id}`
- `POST /api/pickup-boy/pickups/{id}/verify`

### History Tab

- `GET /api/pickup-boy/assignments?status=completed`

### Profile

- `GET /api/auth/profile`
or
- `GET /api/pickup-boy/profile/status`

### Reschedule Screen

- `POST /api/pickup-boy/pickups/{id}/reschedule-request`

## 19. Admin / Warehouse Dependencies

### Warehouse Dependencies

Warehouse-side system must support:

- assignment
- reassignment

### Admin Dependencies

Admin must be able to:

- inspect verification payloads
- inspect assignment history
- inspect status changes
- inspect reschedule requests

Recommended admin APIs:

- `GET /api/admin/pickups/{id}`
- `GET /api/admin/pickups/{id}/verification`
- `GET /api/admin/pickups/{id}/timeline`
- `GET /api/admin/pickups/{id}/assignment-history`

## 20. Non-Functional Requirements

- strict role-based access
- pickup-boy data isolation
- location updates must be lightweight
- verification uploads must support mobile network conditions
- assignment/status/verification changes must be auditable

## 21. Success Criteria

The module is successful when:

- pickup boy can log in and reach dashboard
- current and upcoming tasks are visible
- call and map work using backend customer data
- pickup boy can update task status
- pickup boy can verify actual collected items
- pickup boy can add/modify/remove items
- final payout and bill generation flow works
- pickup boy can raise reschedule requests
- history and profile are available

## 22. Current Gap Summary

Current app status:

- dashboard screen exists
- order verification screen exists
- reschedule screens exist
- profile/history flow still needs proper API wiring
- QR is removed from phase 1 UI

Current backend doc status:

- base pickup-boy execution APIs exist in `api-docs.json`
- dedicated dashboard API is not documented
- reschedule-request API is not documented
- assignments filter contract is unclear
- verify API likely needs extension for add/update/remove item support

## 23. Final Decisions to Lock

1. Pickup assignment and reassignment remain warehouse responsibilities.
2. Pickup boy app is an execution and verification app.
3. QR verification is not required in phase 1.
4. Verification must support item add/update/remove.
5. Completion should support final bill generation.
