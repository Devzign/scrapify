# Backend Script: Channel Partner + Warehouse Verification & Limits

## 1. Objective

Implement backend rules so:

1. New user can apply to become Channel Partner (franchise onboarding request).
2. Channel Partner can request to add Pickup Boy and Warehouse.
3. Admin verifies all onboarding/creation requests before they become active.
4. Until admin decision, requester sees `in_progress` status.
5. Number of warehouses per Channel Partner is controlled only by Admin.
6. Warehouse user cannot add Pickup Boy; warehouse can only allocate requests to Pickup Boy.

---

## 2. Role Permissions (Enforce Strictly)

### Applicant (`channel_partner_applicant`)

Can:

- submit channel partner registration/franchise request
- upload mandatory KYC and compliance docs
- track registration request status

Cannot:

- access channel partner operations before approval
- create pickup boy or warehouse before approval

### Channel Partner (`channel_partner`)

Can:

- create `pickup_boy` onboarding request
- create `warehouse` onboarding request
- view own requests and statuses

Cannot:

- directly create active pickup boy
- directly create active warehouse
- bypass admin verification
- assign pickup requests to pickup boys

### Warehouse (`warehouse`)

Can:

- view warehouse-scoped pickup boys
- view warehouse-scoped requests
- assign/reassign pickup requests to pickup boys

Cannot:

- create pickup boy
- create warehouse
- verify onboarding requests

### Admin (`admin`)

Can:

- verify/reject channel partner registration requests
- verify/reject pickup boy creation requests
- verify/reject warehouse creation requests
- set max warehouse quota per channel partner
- override request status

---

## 3. Required Status Model

Use a single workflow status for onboarding and registration requests:

- `in_progress` (submitted, waiting for admin)
- `approved` (verified by admin)
- `rejected` (rejected by admin, with reason)

When request is `in_progress`, entity must **not** be active in operational lists.

---

## 4. Channel Partner Registration (Franchise + KYC)

Channel partner registration request must capture:

- business location (full address + city/state + geo if available)
- Aadhaar document
- PAN document
- GST document (if applicable)
- police verification document
- additional optional supporting documents

Registration channels:

- mobile app registration flow
- web panel registration flow

Both channels must write to the same backend workflow and same status states.

Admin verification:

1. Request stays `in_progress` until admin decision.
2. On approve:
   - create/activate `channel_partner` user/profile
   - allow login/OTP for channel partner role
3. On reject:
   - store rejection reason
   - keep account non-operational

---

## 5. Warehouse Limit (Admin Controlled Only)

Maintain per-channel-partner limit:

- `channel_partners.max_warehouses_allowed` (integer, nullable)

Validation rule:

1. Before creating warehouse request, check:
   - approved warehouses count for partner
   - pending/in_progress warehouse requests for partner
2. If `approved + in_progress >= max_warehouses_allowed`, block new request.
3. Return clear error:
   - `WAREHOUSE_LIMIT_REACHED`
   - message: `Admin limit reached for warehouse creation.`

Notes:

- Channel Partner cannot edit this limit.
- Only Admin can set/update it.

---

## 6. Data Model Proposal

## 6.1 onboarding_requests

- `id`
- `channel_partner_id` (nullable for new registration request before partner creation)
- `entity_type` (`channel_partner_registration` | `pickup_boy` | `warehouse`)
- `payload_json` (submitted form data)
- `status` (`in_progress` | `approved` | `rejected`)
- `admin_remark` (nullable)
- `verified_by_admin_id` (nullable)
- `verified_at` (nullable)
- `created_at`
- `updated_at`

## 6.2 channel_partner_registration payload (suggested)

- `applicant_name`
- `phone`
- `email`
- `business_name`
- `business_location`
- `aadhaar_doc_url`
- `pan_doc_url`
- `gst_doc_url`
- `police_verification_doc_url`
- `other_docs` (array)

## 6.3 warehouses (existing/new fields)

- `verification_status` (`in_progress` | `approved` | `rejected`) OR map from onboarding request
- `is_active` boolean (set true only after admin approval)

## 6.4 pickup_boys (existing/new fields)

- `verification_status` (`in_progress` | `approved` | `rejected`) OR map from onboarding request
- `is_active` boolean (set true only after admin approval)

---

## 7. API Contract (Minimum)

## 7.1 Applicant/Registration APIs

1. `POST /channel-partner/registration/request`
   - accepts franchise onboarding + KYC payload
   - creates onboarding request with `entity_type=channel_partner_registration`
   - status = `in_progress`
2. `GET /channel-partner/registration/request-status`
   - returns request status and admin remark

## 7.2 Channel Partner APIs

1. `POST /channel-partner/onboarding/pickup-boy`
   - creates onboarding request with status `in_progress`
2. `POST /channel-partner/onboarding/warehouse`
   - validates warehouse limit
   - creates onboarding request with status `in_progress`
3. `GET /channel-partner/onboarding/requests`
   - list own requests with status + remarks

Response must include:

- `request_id`
- `entity_type`
- `status`
- `admin_remark`
- `created_at`

## 7.3 Admin APIs

1. `GET /admin/onboarding/requests?status=in_progress&entity_type=channel_partner_registration|pickup_boy|warehouse`
2. `POST /admin/onboarding/requests/{id}/approve`
3. `POST /admin/onboarding/requests/{id}/reject`
4. `PATCH /admin/channel-partners/{id}/warehouse-limit`

Approval behavior:

- create/activate actual entity record
- mark request `approved`

Rejection behavior:

- keep entity inactive (or do not create)
- mark request `rejected`
- store rejection reason

## 7.4 Warehouse APIs

1. `GET /warehouse/requests`
2. `GET /warehouse/pickup-boys`
3. `POST /warehouse/requests/{id}/assign`
4. `POST /warehouse/requests/{id}/reassign`

Hard guard:

- reject any warehouse user call to create pickup boy or warehouse.

---

## 8. Validation Rules

1. Applicant cannot create duplicate active registration request for same phone/email.
2. Registration requires mandatory docs: Aadhaar, PAN, police verification, location.
3. Only approved channel partners can create pickup boy/warehouse requests.
4. Channel Partner cannot submit duplicate active request for same entity identity (phone/code/etc.).
5. Only `approved` pickup boys are assignable in warehouse assignment APIs.
6. Only `approved` warehouses appear in operational warehouse list.
7. Admin action required for status change from `in_progress` to final state.
8. Audit log every admin decision.

---

## 9. Frontend State Mapping

For applicant and channel partner (app/web):

- `in_progress` => show `In Progress`
- `approved` => show `Approved`
- `rejected` => show `Rejected` + remark

For Warehouse app:

- no create UI for pickup boy/warehouse
- keep assign/reassign only

---

## 10. Acceptance Criteria

1. Applicant submits channel partner registration from app -> status `in_progress`.
2. Applicant submits channel partner registration from web panel -> same workflow/status.
3. Admin approves registration -> partner account becomes operational.
4. Admin rejects registration -> applicant sees rejection reason.
5. Channel Partner submits pickup boy request -> appears as `in_progress`.
6. Channel Partner submits warehouse request -> blocked when admin limit reached.
7. Warehouse user cannot create pickup boy/warehouse through any endpoint.
8. Warehouse user can assign/reassign requests to approved pickup boys only.
