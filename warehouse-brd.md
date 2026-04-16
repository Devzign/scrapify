# Warehouse App BRD

## 1. Document Overview

- Project: Warehouse Mobile App
- Backend role: `warehouse`
- Platforms: Mobile app, backend APIs, admin portal
- Version: 1.0

## 2. Purpose

Build a Warehouse app where the warehouse user can:

- log in via OTP
- view pickup requests under their warehouse scope
- see unassigned, assigned, active, completed, and delayed requests
- view pickup boys linked to their warehouse
- assign a pickup boy to a particular request
- reassign a pickup boy when needed
- monitor request execution at warehouse level

This app is primarily an operational assignment console for warehouse users.

## 3. Confirmed Business Rule

This is a confirmed decision:

- pickup assignment and reassignment will be handled by warehouse users

This means the warehouse app must support:

- viewing pickup requests
- viewing available pickup boys
- assigning pickup boy to request
- reassigning pickup boy if required

## 4. Business Objective

The Warehouse app should help warehouse operations teams:

- monitor request volume under their warehouse
- reduce delay in agent assignment
- quickly match pickup requests to available pickup boys
- track assigned and completed pickups
- manage the operational load at warehouse level

## 5. User Roles

### 5.1 Warehouse User

Can:

- log in
- view warehouse-scoped requests
- view warehouse-scoped pickup boys
- assign pickup boys to requests
- reassign pickup boys to requests
- view request status
- view warehouse summary metrics
- view profile

Cannot:

- create or approve channel partner resources
- see another warehouse's requests
- access global admin data
- verify pickup items as pickup boy

### 5.2 Admin

Can:

- view all warehouses
- view all requests
- override assignments
- audit warehouse activity

## 6. In Scope

- OTP login
- warehouse dashboard
- request list
- request detail
- pickup boy list for warehouse
- assign pickup boy
- reassign pickup boy
- notifications
- profile

## 7. Out of Scope for Phase 1

- warehouse inventory management
- payment settlement
- warehouse creation/update inside warehouse app
- QR verification
- live map tracking dashboards

## 8. Assumptions

- warehouse login already uses role `warehouse`
- each warehouse user is scoped to one warehouse or an allowed warehouse set
- requests shown in this app belong only to the warehouse user's operational scope
- assignment and reassignment are warehouse responsibilities

## 9. High-Level App Flow

### 9.1 Login Flow

1. Warehouse user enters phone number.
2. App sends OTP with role `warehouse`.
3. User verifies OTP.
4. Backend returns auth token and user profile.
5. App routes user to Warehouse Dashboard.

### 9.2 Dashboard Flow

1. App loads warehouse dashboard summary.
2. User sees:
   - total requests
   - unassigned requests
   - assigned requests
   - active pickups
   - completed pickups
   - delayed/rescheduled pickups
   - total pickup boys
   - available pickup boys
3. User navigates to:
   - Requests
   - Pickup Boys
   - Profile

### 9.3 Request Flow

1. User opens Requests.
2. App loads warehouse-scoped requests.
3. User filters by:
   - unassigned
   - assigned
   - in progress
   - completed
   - rescheduled
4. User opens request detail.
5. User sees:
   - customer details
   - pickup address
   - scheduled slot
   - items summary
   - current assignment
   - current status
6. User can assign or reassign pickup boy from this screen.

### 9.4 Pickup Boy Flow

1. User opens Pickup Boys.
2. App loads pickup boys mapped to this warehouse.
3. User sees:
   - active/inactive
   - online/offline
   - available/unavailable
   - current load
   - pending assignments
   - completed count
4. User uses this list when assigning/reassigning requests.

### 9.5 Assignment Flow

1. Warehouse user opens a request.
2. User taps Assign Pickup Boy.
3. App loads available warehouse pickup boys.
4. User selects pickup boy.
5. App submits assignment request.
6. Backend updates pickup request with assigned pickup boy.
7. Pickup boy receives notification.

### 9.6 Reassignment Flow

1. Warehouse user opens an already assigned request.
2. User taps Reassign Pickup Boy.
3. App loads available pickup boys.
4. User selects a new pickup boy and reason.
5. Backend updates assignment and stores assignment history.

### 9.7 Profile Flow

1. User opens profile.
2. User views:
   - name
   - phone
   - warehouse name
   - warehouse address
   - support details
3. User can log out.

## 10. Recommended App Navigation

Bottom tabs:

1. Home
2. Requests
3. Pickup Boys
4. Profile

Optional:

- History can be inside Requests using status filter

## 11. Functional Requirements

### 11.1 Dashboard

The app must show:

- total requests
- unassigned requests
- assigned requests
- active pickups
- completed pickups
- rescheduled/delayed requests
- total pickup boys
- active pickup boys
- available pickup boys
- recent requests

### 11.2 Requests List

The app must allow:

- list warehouse-scoped requests
- filter requests by status
- search by order code / customer / phone
- open request detail

### 11.3 Request Detail

The app must show:

- order code
- customer name
- customer phone
- pickup address
- coordinates
- scheduled date/time
- item summary
- status
- assigned pickup boy
- warehouse notes if any

The app must allow:

- assign pickup boy
- reassign pickup boy

### 11.4 Pickup Boys

The app must allow:

- list pickup boys linked to warehouse
- see operational status
- see availability
- see active workload
- select pickup boy during assignment flow

### 11.5 Notifications

The app must support:

- new request available
- request assigned
- request reassigned
- request cancelled
- support/admin messages

### 11.6 Profile

The app must allow:

- view profile
- view warehouse info
- logout

## 12. Backend Flow

### 12.1 Authentication

- send OTP with role `warehouse`
- verify OTP
- issue token
- return warehouse-scoped profile

### 12.2 Dashboard Aggregation

Backend should aggregate:

- request metrics by status
- pickup boy availability metrics
- recent requests
- assignment backlog

### 12.3 Request Visibility

Backend should return only requests visible to this warehouse.

Warehouse user should only see:

- requests mapped to their warehouse
- pickup boys mapped to their warehouse

### 12.4 Assignment Flow

1. Warehouse user opens request.
2. Warehouse app loads eligible pickup boys.
3. User assigns pickup boy.
4. Backend stores assignment.
5. Backend updates request status if needed.
6. Backend sends notification to pickup boy.

### 12.5 Reassignment Flow

1. Warehouse user opens assigned request.
2. User selects new pickup boy.
3. Backend updates assignment.
4. Backend stores reason and history.
5. Backend notifies new pickup boy and optionally old pickup boy.

## 13. Business Rules

1. Warehouse user can assign and reassign pickup boys.
2. Warehouse user can only assign warehouse-linked pickup boys.
3. Warehouse user can only see warehouse-scoped requests.
4. Warehouse user cannot access another warehouse's data.
5. Assignment history should be auditable.
6. Backend should prevent assignment to inactive/unavailable pickup boys if configured.

## 14. Data Ownership Rules

All warehouse app data must be scoped by `warehouse_id`.

Warehouse-visible entities:

- pickup requests linked to warehouse
- pickup boys linked to warehouse
- assignment history linked to warehouse requests

## 15. Suggested Data Model

### 15.1 warehouses

- id
- name
- code
- address
- city_id
- latitude
- longitude
- is_active
- created_at
- updated_at

### 15.2 warehouse_users

- id
- warehouse_id
- name
- phone
- email
- is_active
- created_at
- updated_at

### 15.3 pickup_boys

- id
- warehouse_id
- channel_partner_id nullable
- name
- phone
- profile_photo
- is_active
- is_online
- is_available
- current_assignment_count
- completed_count
- created_at
- updated_at

### 15.4 pickup_requests

- id
- warehouse_id
- pickup_boy_id nullable
- customer_name
- customer_phone
- address
- latitude
- longitude
- scheduled_at
- status
- item_summary
- estimated_weight
- created_at
- updated_at

### 15.5 pickup_assignment_history

- id
- pickup_request_id
- old_pickup_boy_id nullable
- new_pickup_boy_id
- assigned_by_user_id
- reason nullable
- created_at

## 16. API Requirements

### 16.1 Auth

Reuse:

- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`

Request:

```json
{
  "phone": "9876543210",
  "role": "warehouse"
}
```

### 16.2 Warehouse Dashboard

Create:

- `GET /api/warehouse/dashboard`

Should return:

- warehouse summary
- request metrics
- pickup boy metrics
- recent requests

Suggested response:

```json
{
  "success": true,
  "data": {
    "warehouse": {
      "id": 3,
      "name": "Sector 45 Hub",
      "code": "WH-GGN-45",
      "city": "Gurugram"
    },
    "metrics": {
      "total_requests": 124,
      "unassigned_requests": 8,
      "assigned_requests": 21,
      "active_pickups": 17,
      "completed_pickups": 78,
      "rescheduled_requests": 4,
      "total_pickup_boys": 12,
      "active_pickup_boys": 10,
      "available_pickup_boys": 7
    },
    "recent_requests": []
  }
}
```

### 16.3 Warehouse Profile

Create:

- `GET /api/warehouse/profile`

Should return:

- user details
- warehouse details
- support info

### 16.4 Requests List

Create:

- `GET /api/warehouse/requests`

Filters:

- status
- date_from
- date_to
- pickup_boy_id
- search

Each request should include:

- pickup_id
- order_code
- customer_name
- customer_phone
- address
- latitude
- longitude
- scheduled_at
- status
- item_summary
- estimated_weight
- assigned_pickup_boy

### 16.5 Request Detail

Create:

- `GET /api/warehouse/requests/{id}`

Should return:

- request summary
- customer details
- pickup address
- coordinates
- scheduled slot
- items
- assigned pickup boy
- status timeline
- assignment history summary

### 16.6 Pickup Boys for Warehouse

Create:

- `GET /api/warehouse/pickup-boys`
- `GET /api/warehouse/pickup-boys/{id}`

Each pickup boy should include:

- id
- name
- phone
- profile_photo
- is_active
- is_online
- is_available
- current_assignment_count
- completed_count

### 16.7 Assign Pickup Boy

Use or extend existing admin-style logic into warehouse module:

- `POST /api/warehouse/requests/{id}/assign`

Request body:

```json
{
  "pickup_boy_id": 14,
  "notes": "Assigned from warehouse dashboard"
}
```

Response:

```json
{
  "success": true,
  "message": "Pickup assigned successfully",
  "data": {
    "pickup_id": 4921,
    "pickup_boy_id": 14,
    "status": "assigned"
  }
}
```

### 16.8 Reassign Pickup Boy

Create:

- `POST /api/warehouse/requests/{id}/reassign`

Request body:

```json
{
  "pickup_boy_id": 18,
  "reason": "Previous agent unavailable"
}
```

### 16.9 Assignment Candidates API

Create:

- `GET /api/warehouse/requests/{id}/assignable-pickup-boys`

This should return only eligible pickup boys for that warehouse.

### 16.10 Notifications

Reuse if generic notification system exists:

- `GET /api/notifications`
- `POST /api/notifications/read-all`
- `POST /api/notifications/fcm-token`

## 17. Admin APIs Required

### 17.1 Warehouse Oversight

Create or confirm:

- `GET /api/admin/warehouses`
- `GET /api/admin/warehouses/{id}`
- `GET /api/admin/warehouses/{id}/requests`
- `GET /api/admin/warehouses/{id}/pickup-boys`

### 17.2 Assignment Oversight

Existing:

- `GET /api/admin/pickups`
- `POST /api/admin/pickups/{id}/assign`

Recommended additions:

- `POST /api/admin/pickups/{id}/reassign`
- `GET /api/admin/pickups/{id}/assignment-history`

## 18. Screen-to-Backend Mapping

### Dashboard

- `GET /api/warehouse/dashboard`

### Requests List

- `GET /api/warehouse/requests`

### Request Detail

- `GET /api/warehouse/requests/{id}`

### Pickup Boy List

- `GET /api/warehouse/pickup-boys`

### Pickup Boy Detail

- `GET /api/warehouse/pickup-boys/{id}`

### Assign Pickup Boy

- `GET /api/warehouse/requests/{id}/assignable-pickup-boys`
- `POST /api/warehouse/requests/{id}/assign`

### Reassign Pickup Boy

- `GET /api/warehouse/requests/{id}/assignable-pickup-boys`
- `POST /api/warehouse/requests/{id}/reassign`

### Profile

- `GET /api/warehouse/profile`

## 19. Non-Functional Requirements

- strict warehouse-level access control
- no cross-warehouse visibility
- assignment history audit required
- filters and pagination required
- mobile-friendly response payloads
- notifications for assignment updates

## 20. Success Criteria

The module is successful when:

- warehouse user can log in
- warehouse dashboard shows real operational summary
- warehouse user can list scoped pickup requests
- warehouse user can assign pickup boy to a request
- warehouse user can reassign when needed
- warehouse user can see pickup boy availability
- admin can audit warehouse assignment activity

## 21. Current Gap Summary

Current app status:

- warehouse role exists
- warehouse route exists
- current warehouse dashboard is placeholder only

Current backend doc status:

- `api-docs.json` currently documents:
  - `GET /api/admin/pickups`
  - `POST /api/admin/pickups/{id}/assign`
- no warehouse app-specific API module is documented yet

## 22. Final Decisions to Lock

1. Warehouse app is responsible for pickup assignment and reassignment.
2. Warehouse user scope is limited to own warehouse.
3. Warehouse app is focused on request visibility and assignment flow.
4. Inventory flow is not part of phase 1.
