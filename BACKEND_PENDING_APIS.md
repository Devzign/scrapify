# Backend Pending / Verify API Endpoints

Frontend is fully wired for all endpoints below. Please implement or confirm these are live.

---

## 1. Customer — Reschedule Pickup

**Status:** Frontend wired, endpoint unknown if live

```
POST /api/pickup-requests/{id}/reschedule
```

**Auth:** Bearer token (customer role)

**Request body:**
```json
{
  "scheduled_date": "2024-11-05",
  "time_slot": "morning",
  "reason": "out_of_town"
}
```

**Expected response:**
```json
{
  "success": true,
  "message": "Pickup rescheduled successfully."
}
```

**Notes:**
- `time_slot` values: `morning` (9 AM–12 PM), `afternoon` (12 PM–3 PM), `evening` (3 PM–6 PM)
- `reason` is optional
- Should update pickup request status to `rescheduled`

---

## 2. Channel Partner — Orders List

**Status:** Frontend wired, please confirm live

```
GET /api/channel-partner/orders
GET /api/channel-partner/orders?status={status}
```

**Auth:** Bearer token (channel_partner role)

**Query params:**
| Param | Values |
|---|---|
| `status` | `active`, `assigned`, `completed`, `cancelled`, `rescheduled` |

**Expected response:**
```json
{
  "data": [
    {
      "id": 1,
      "order_code": "ORD-001",
      "customer_name": "Rahul Sharma",
      "scheduled_at": "2024-11-05 10:00:00",
      "address": "Sector 45, Gurugram",
      "status": "active",
      "assigned_pickup_boy": {
        "id": 3,
        "name": "Vikram Singh"
      }
    }
  ]
}
```

---

## 3. Channel Partner — Order Detail

**Status:** Frontend wired, please confirm live

```
GET /api/channel-partner/orders/{id}
```

**Auth:** Bearer token (channel_partner role)

**Expected response:** Same fields as list item above, with full detail.

---

## 4. Channel Partner — Pickup Boys List

**Status:** Frontend wired, please confirm live

```
GET /api/channel-partner/pickup-boys
```

**Auth:** Bearer token (channel_partner role)

**Expected response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Vikram Singh",
      "phone": "9876543210",
      "is_online": true,
      "is_available": false,
      "is_active": true,
      "warehouse_name": "North Hub",
      "current_assignment_count": 2,
      "completed_count": 45
    }
  ]
}
```

---

## 5. Channel Partner — Warehouses List

**Status:** Frontend wired, please confirm live

```
GET /api/channel-partner/warehouses
```

**Auth:** Bearer token (channel_partner role)

**Expected response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Central Distribution Hub",
      "address": "South Extension, New Delhi",
      "is_active": true,
      "pickup_boys_count": 12,
      "total_orders": 486
    }
  ]
}
```

---

## 6. Channel Partner — Approval Requests

**Status:** Frontend wired, please confirm live

```
GET /api/channel-partner/approval-requests
GET /api/channel-partner/approval-requests?status={status}
```

**Auth:** Bearer token (channel_partner role)

**Query params:**
| Param | Values |
|---|---|
| `status` | `pending`, `approved`, `rejected` |

**Expected response:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Warehouse Zone Expansion",
      "description": "Request to extend delivery zone...",
      "status": "pending",
      "requester_name": "Arjun Mehta",
      "created_at": "2024-10-22T09:15:00Z",
      "warehouse_name": "North Sector Terminal",
      "amount": null,
      "notes": null
    }
  ]
}
```

---

## 7. Channel Partner — Submit Status / Approve / Reject Request

**Status:** Frontend wired, please confirm live

```
POST /api/channel-partner/status-request
```

**Auth:** Bearer token (channel_partner role)

**Request body:**
```json
{
  "request_id": 1,
  "status": "approved"
}
```

**Accepted `status` values:** `approved`, `rejected`

**Expected response:**
```json
{
  "success": true,
  "message": "Request approved successfully."
}
```

---

## 8. Channel Partner — Dashboard

**Status:** Already live per earlier integration — just confirming field names match

```
GET /api/channel-partner/dashboard
```

**Expected fields in response `data`:**
```json
{
  "total_orders": 0,
  "active_orders": 0,
  "completed_orders": 0,
  "cancelled_orders": 0,
  "rescheduled_orders": 0,
  "active_warehouses": 0,
  "pending_warehouse_approvals": 0,
  "total_pickup_boys": 0,
  "available_pickup_boys": 0,
  "active_pickup_boys": 0,
  "pending_pickup_boy_approvals": 0,
  "recent_orders": []
}
```

---

## Summary Table

| # | Endpoint | Method | Status |
|---|---|---|---|
| 1 | `/pickup-requests/{id}/reschedule` | POST | ❓ Needs implementation |
| 2 | `/channel-partner/orders` | GET | ❓ Needs verification |
| 3 | `/channel-partner/orders/{id}` | GET | ❓ Needs verification |
| 4 | `/channel-partner/pickup-boys` | GET | ❓ Needs verification |
| 5 | `/channel-partner/warehouses` | GET | ❓ Needs verification |
| 6 | `/channel-partner/approval-requests` | GET | ❓ Needs verification |
| 7 | `/channel-partner/status-request` | POST | ❓ Needs verification |
| 8 | `/channel-partner/dashboard` | GET | ✅ Live — verify field names |

---

**Base URL (staging/production):** `https://floralwhite-spoonbill-935004.hostingersite.com/api`

All requests require `Authorization: Bearer {token}` header.
