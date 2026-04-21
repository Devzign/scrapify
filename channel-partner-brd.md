# Channel Partner App BRD

## 1. Document Overview

- Project: Channel Partner Mobile App
- Backend role: `channel_partner`
- App role label: Dealer / Channel Partner
- Platforms: Mobile app, backend APIs, admin portal
- Version: 1.0

## 2. Purpose

Build a Channel Partner app where the partner can monitor their own business network, including:

- pickup boys under them
- warehouses under them
- orders flowing through their network
- approval requests sent to admin
- final operational metrics

The channel partner can manage their own network, but sensitive actions must remain under admin approval because of background verification and operational control.

Before this, there is a Channel Partner onboarding/registration stage where a new applicant buys/requests franchise and submits KYC/compliance documents. That registration must be admin-verified.

## 3. Confirmed Business Decisions

These points are finalized based on stakeholder input:

1. Channel partner should not directly create pickup boys.
   Pickup boy create/update/status changes must go through admin approval.
2. Channel partner should not directly edit active warehouses.
   Warehouse create/update/status changes must go through admin approval.
3. Pickup assignment and reassignment will be handled by warehouse users, not by channel partners.
4. Financial and final business metrics should be visible in phase 1 dashboard.
5. Approval requests should support attachments/documents for verification.
6. Pickup boy live location is not needed in phase 1.
   Only current status is needed for now. Live location can be added later.
7. Channel Partner registration must support both app-side and web-side submission, with one common admin verification workflow.
8. Mandatory registration docs include Aadhaar, PAN, GST (if applicable), police verification, and business location details.

## 4. Business Objective

The Channel Partner app should help partners:

- see how many orders are incoming, active, completed, cancelled, and rescheduled
- see how many pickup boys are active and available
- see how many warehouses are active and pending approval
- manage their own pickup boy and warehouse requests
- track admin approval decisions
- view final performance metrics for their own network

## 5. User Roles

### 5.1 Channel Partner

Can:

- log in via OTP
- view dashboard and business metrics
- view partner-scoped orders
- view partner-scoped pickup boys
- view partner-scoped warehouses
- submit requests for:
  - pickup boy creation
  - pickup boy update
  - pickup boy status change
  - warehouse creation
  - warehouse update
  - warehouse status change
- upload supporting documents/attachments with requests
- track request approval status
- view own profile

Cannot:

- directly approve own requests
- directly create active pickup boys or warehouses without admin approval
- assign or reassign orders
- see another partner's data
- access global admin data

### 5.0 Channel Partner Applicant (Pre-Approval)

Can:

- submit franchise/channel partner registration request
- upload onboarding docs:
  - Aadhaar
  - PAN
  - GST (if applicable)
  - police verification
  - business location details
- view registration status: `in_progress`, `approved`, `rejected`

Cannot:

- operate as full channel partner before admin approval
- create pickup boy/warehouse requests before registration approval

### 5.2 Warehouse User

Can:

- assign pickups
- reassign pickups

This is outside the main channel partner app flow, but backend rules must preserve this responsibility.

### 5.3 Admin

Can:

- view all channel partners
- review pickup boy and warehouse requests
- approve or reject requests
- inspect partner metrics and network
- activate/deactivate entities
- audit partner operations

## 6. Scope

### In Scope

- channel partner onboarding/registration request flow (app + web)
- registration document upload and verification status tracking
- OTP login
- dashboard
- orders list and detail
- pickup boy list and detail
- warehouse list and detail
- approval requests list and detail
- notifications
- profile
- admin approval workflows

### Out of Scope for Phase 1

- live pickup boy location
- channel partner order assignment/reassignment
- warehouse inventory management
- advanced finance settlement workflows
- QR-based operations

### 6.1 Registration Workflow (Pre-Login/Onboarding)

1. Applicant fills channel partner registration form from app or web panel.
2. Applicant uploads required KYC/compliance docs.
3. Backend creates `in_progress` registration request.
4. Admin reviews and verifies documents.
5. Admin approves/rejects:
   - approved: applicant can operate as channel partner
   - rejected: applicant sees reason and can re-apply/update

## 7. High-Level App Flow

### 7.1 Login Flow

1. Channel partner enters phone number.
2. App sends OTP with role `channel_partner`.
3. User verifies OTP.
4. Backend returns auth token and profile.
5. App routes user to Channel Partner Dashboard.

### 7.2 Dashboard Flow

1. App loads dashboard summary.
2. User sees:
   - total orders
   - active orders
   - completed orders
   - cancelled orders
   - rescheduled orders
   - total warehouses
   - active warehouses
   - pending warehouse approvals
   - total pickup boys
   - active pickup boys
   - available pickup boys
   - pending pickup boy approvals
   - final metrics
3. User navigates to Orders, Team, Warehouses, Requests, or Profile.

### 7.3 Orders Flow

1. User opens Orders.
2. App loads all partner-scoped orders.
3. User can filter by:
   - status
   - date range
   - warehouse
   - pickup boy
4. User opens an order detail page.
5. User sees:
   - customer details
   - order timeline
   - assigned warehouse
   - assigned pickup boy
   - final payout/metrics if available

### 7.4 Pickup Boy Flow

1. User opens Team / Pickup Boys.
2. App loads all partner pickup boys.
3. User sees:
   - active/inactive
   - online/offline
   - available/unavailable
   - warehouse mapping
   - performance counts
4. User can submit:
   - add pickup boy request
   - update pickup boy request
   - status change request
5. Requests go to admin approval.

### 7.5 Warehouse Flow

1. User opens Warehouses.
2. App loads all partner warehouses.
3. User sees:
   - active/inactive
   - address
   - city
   - total linked pickup boys
   - total linked orders
4. User can submit:
   - add warehouse request
   - update warehouse request
   - status change request
5. Requests go to admin approval.

### 7.6 Request / Approval Flow

1. User opens Requests.
2. App loads:
   - pending requests
   - approved requests
   - rejected requests
3. User opens request detail.
4. User sees:
   - request type
   - submitted payload summary
   - attached documents
   - admin remarks
   - approval timestamps

### 7.7 Profile Flow

1. User opens Profile.
2. User sees:
   - name
   - phone
   - company
   - city
   - support details
3. User can edit allowed profile fields.
4. User can log out.

## 8. Recommended App Navigation

Bottom tabs:

1. Home
2. Orders
3. Team
4. Warehouses
5. Profile

Requests can either be:

- a separate tab, or
- a section inside Home/Profile

## 9. Functional Requirements

### 9.1 Dashboard

The app must show:

- total orders
- active orders
- completed orders
- cancelled orders
- rescheduled orders
- total warehouses
- active warehouses
- pending warehouse approvals
- total pickup boys
- active pickup boys
- available pickup boys
- pending pickup boy approvals
- final metrics
- recent orders
- pending request count

### 9.2 Orders

The app must allow:

- list partner-scoped orders
- filter orders
- open order detail
- see assigned pickup boy
- see assigned warehouse
- see order status timeline
- see final payout / summary where available

### 9.3 Pickup Boys

The app must allow:

- list pickup boys owned by partner
- view pickup boy detail
- see active/inactive
- see online/offline
- see available/unavailable
- submit pickup boy create request
- submit pickup boy update request
- submit pickup boy status request
- attach documents if required for approval

### 9.4 Warehouses

The app must allow:

- list warehouses owned by partner
- view warehouse detail
- submit warehouse create request
- submit warehouse update request
- submit warehouse status request
- attach documents if required for approval

### 9.5 Approval Requests

The app must allow:

- list approval requests
- filter by status
- open request detail
- view attached files
- read admin remarks
- track approval result

### 9.6 Profile

The app must allow:

- view profile
- edit profile
- access support
- logout

## 10. Backend Flow

### 10.1 Authentication

- OTP sent with role `channel_partner`
- OTP verified
- auth token issued
- partner profile returned

### 10.2 Dashboard Aggregation

Backend aggregates:

- order metrics
- warehouse metrics
- pickup boy metrics
- pending approval counts
- final partner metrics
- recent order activity

### 10.3 Partner Order Visibility

Backend returns only partner-owned / partner-scoped orders.

Partner should not see:

- other partner orders
- admin global orders
- warehouse-private data outside their scope

### 10.4 Pickup Boy Request Approval Flow

1. Partner submits pickup boy request.
2. Backend stores approval request with payload and attachments.
3. Admin reviews request.
4. Admin approves or rejects.
5. If approved, actual pickup boy record is created/updated.
6. If rejected, remarks are stored and returned to partner app.

### 10.5 Warehouse Request Approval Flow

1. Partner submits warehouse request.
2. Backend stores approval request with payload and attachments.
3. Admin reviews.
4. Admin approves or rejects.
5. If approved, actual warehouse record is created/updated.

### 10.6 Assignment Responsibility

Order assignment and reassignment must remain under warehouse-side workflow.

Channel partner can view assignment information, but cannot execute assignment actions in phase 1.

## 11. Business Rules

1. All pickup boy create/update/status requests require admin approval.
2. All warehouse create/update/status requests require admin approval.
3. Channel partner cannot assign or reassign pickups.
4. Warehouse user handles pickup assignment and reassignment.
5. Final metrics must be visible to channel partner in phase 1.
6. Approval requests must support attachments/documents.
7. Live pickup boy location is excluded from phase 1.
8. Only current status of pickup boys is needed for now.

## 12. Data Ownership Rules

All applicable records must be scoped by `channel_partner_id`.

Partner-visible entities:

- pickup boys
- warehouses
- orders
- approval requests

## 13. Suggested Data Model

### 13.1 channel_partners

- id
- name
- company_name
- phone
- email
- city_id
- profile_photo
- is_active
- created_at
- updated_at

### 13.2 pickup_boys

- id
- channel_partner_id
- name
- phone
- email
- city_id
- warehouse_id
- vehicle_number
- profile_photo
- is_active
- is_online
- is_available
- created_at
- updated_at

### 13.3 warehouses

- id
- channel_partner_id
- name
- code
- address
- city_id
- latitude
- longitude
- service_radius_km
- is_active
- created_at
- updated_at

### 13.4 approval_requests

- id
- channel_partner_id
- entity_type
- entity_id nullable
- request_type
- payload_json
- attachment_urls or document references
- status
- admin_remarks nullable
- created_by
- approved_by nullable
- approved_at nullable
- created_at
- updated_at

## 14. API Requirements

### 14.1 Auth

Reuse:

- `POST /api/auth/send-otp`
- `POST /api/auth/verify-otp`

Request:

```json
{
  "phone": "9876543210",
  "role": "channel_partner"
}
```

### 14.2 Channel Partner Dashboard

- `GET /api/channel-partner/dashboard`

Should return:

- partner profile summary
- order metrics
- warehouse metrics
- pickup boy metrics
- pending approvals count
- recent orders
- final partner metrics

### 14.3 Channel Partner Profile

- `GET /api/channel-partner/profile`
- `PUT /api/channel-partner/profile`

### 14.4 Orders

- `GET /api/channel-partner/orders`
- `GET /api/channel-partner/orders/{id}`

Filters:

- status
- date_from
- date_to
- warehouse_id
- pickup_boy_id
- search

### 14.5 Pickup Boys

- `GET /api/channel-partner/pickup-boys`
- `GET /api/channel-partner/pickup-boys/{id}`
- `POST /api/channel-partner/pickup-boys`
- `PUT /api/channel-partner/pickup-boys/{id}`
- `POST /api/channel-partner/pickup-boys/{id}/status-request`

Important:

- these are request-driven operations
- approved changes should be applied only after admin action

### 14.6 Warehouses

- `GET /api/channel-partner/warehouses`
- `GET /api/channel-partner/warehouses/{id}`
- `POST /api/channel-partner/warehouses`
- `PUT /api/channel-partner/warehouses/{id}`
- `POST /api/channel-partner/warehouses/{id}/status-request`

### 14.7 Approval Requests

- `GET /api/channel-partner/approval-requests`
- `GET /api/channel-partner/approval-requests/{id}`

Filters:

- status
- entity_type
- request_type
- date_from
- date_to

### 14.8 Notifications

Reuse if generic notification system already exists:

- `GET /api/notifications`
- `POST /api/notifications/read-all`
- `POST /api/notifications/fcm-token`

## 15. Admin APIs Required

### 15.1 Channel Partner Management

- `GET /api/admin/channel-partners`
- `GET /api/admin/channel-partners/{id}`
- `POST /api/admin/channel-partners/{id}/status`

### 15.2 Pickup Boy Approval

- `GET /api/admin/channel-partner/pickup-boy-requests`
- `POST /api/admin/channel-partner/pickup-boy-requests/{request_id}/approve`
- `POST /api/admin/channel-partner/pickup-boy-requests/{request_id}/reject`

### 15.3 Warehouse Approval

- `GET /api/admin/channel-partner/warehouse-requests`
- `POST /api/admin/channel-partner/warehouse-requests/{request_id}/approve`
- `POST /api/admin/channel-partner/warehouse-requests/{request_id}/reject`

### 15.4 Partner Oversight

- `GET /api/admin/channel-partners/{id}/dashboard`
- `GET /api/admin/channel-partners/{id}/orders`
- `GET /api/admin/channel-partners/{id}/pickup-boys`
- `GET /api/admin/channel-partners/{id}/warehouses`

## 16. Screen-to-Backend Mapping

### Home Dashboard

- `GET /api/channel-partner/dashboard`

### Orders List

- `GET /api/channel-partner/orders`

### Order Detail

- `GET /api/channel-partner/orders/{id}`

### Pickup Boy List

- `GET /api/channel-partner/pickup-boys`

### Pickup Boy Detail

- `GET /api/channel-partner/pickup-boys/{id}`

### Add/Edit Pickup Boy Request

- `POST /api/channel-partner/pickup-boys`
- `PUT /api/channel-partner/pickup-boys/{id}`

### Warehouse List

- `GET /api/channel-partner/warehouses`

### Warehouse Detail

- `GET /api/channel-partner/warehouses/{id}`

### Add/Edit Warehouse Request

- `POST /api/channel-partner/warehouses`
- `PUT /api/channel-partner/warehouses/{id}`

### Requests List

- `GET /api/channel-partner/approval-requests`

### Request Detail

- `GET /api/channel-partner/approval-requests/{id}`

### Profile

- `GET /api/channel-partner/profile`
- `PUT /api/channel-partner/profile`

## 17. Non-Functional Requirements

- strict role-based access
- partner data isolation
- audit logs for all approval actions
- pagination and filters on large lists
- mobile-friendly response payloads
- secure attachment upload handling

## 18. Success Criteria

The module is successful when:

- channel partner can log in successfully
- dashboard shows partner-owned operational summary
- partner can view all scoped orders
- partner can manage pickup boy and warehouse requests
- admin can approve/reject requests
- partner can view approval results in app
- assignment ownership remains with warehouse flow

## 19. Current Gap Summary

Current app status:

- auth role exists
- placeholder partner dashboard exists
- no proper partner flow is wired yet

Current backend doc gap:

- no documented `/api/channel-partner/*` module
- no documented `/api/admin/channel-partners/*` approval module
- no documented partner request/approval workflow

## 20. Final Decisions to Lock

1. Pickup boy creation/update/status must be approval based.
2. Warehouse creation/update/status must be approval based.
3. Pickup assignment and reassignment belongs to warehouse user workflow.
4. Final metrics are included in phase 1.
5. Attachments are required for approval/verification requests.
6. Live location is not included in phase 1.
7. Current pickup boy status is enough for phase 1.
