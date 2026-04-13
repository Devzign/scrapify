# Backend Script: Global App Settings API

Please create a global app settings API for the mobile app.

## Goal
We need one backend-driven settings source for app-wide configuration and user preference handling.

## Primary use cases
- store and return the user's last selected app language
- enable or disable donation flow using a backend flag
- support more app-wide flags later without app release dependency

## Required behavior

### 1. Global app settings API
Create an endpoint like:

- `GET /api/app-settings`

This API should return:
- app-level feature flags
- app-level configuration values
- current user's saved language if authenticated

Recommended response:

```json
{
  "success": true,
  "code": 200,
  "message": "app_settings.fetched",
  "message_text": "App settings fetched successfully",
  "data": {
    "language": "hi",
    "supported_languages": ["en", "hi", "gu"],
    "features": {
      "donation_enabled": true,
      "scrap_pickup_enabled": true,
      "wallet_enabled": false
    },
    "settings": {
      "default_city_id": 1,
      "customer_support_number": "+91XXXXXXXXXX"
    }
  },
  "errors": null
}
```

### 2. Save user language preference
Create an endpoint like:

- `POST /api/app-settings/language`

Request:

```json
{
  "language": "hi"
}
```

Behavior:
- save the selected language against the authenticated user
- this should become the default response language for future APIs
- when user logs in again, backend should remember the last selected language

### 3. Language-aware API responses
Backend should support returning translated response text based on the user's selected language.

That means:
- if user selected `hi`, then message text and localized values should prefer Hindi
- if user selected `en`, then response should prefer English
- backend may also support `Accept-Language` header as override, but saved user preference should remain the main default

Recommended priority:
1. explicit request header if sent
2. saved user preference from backend
3. system default language

### 4. Donation feature flag
Add a backend-controlled feature flag:

- `donation_enabled`

Behavior:
- if `donation_enabled = false`, app should hide or block donation flow
- if `donation_enabled = true`, app can show donation flow normally

This flag should come from `GET /api/app-settings`.

## Recommended endpoints
- `GET /api/app-settings`
- `POST /api/app-settings/language`
- optional: `PUT /api/admin/app-settings` for admin-side management

## Recommended database structure

### Option A: user preference + global settings tables
- `user_preferences`
  - `user_id`
  - `language`
- `app_settings`
  - `key`
  - `value`

### Option B: single JSON settings source + user preference table
- one global settings record for app config
- separate user preference record for language

## Important backend rules
- do not hardcode donation enable/disable only in frontend
- backend should be source of truth for feature toggles
- language preference should persist across sessions
- this API should be lightweight because app may call it during startup

## Immediate frontend needs
Frontend wants to use this for:
- selected language restore on app open
- donation feature visibility
- future app-level flags

## Final request
Please create a global app settings API and language preference API so the app can:
- fetch global flags
- fetch saved user language
- update language
- receive localized backend responses based on last selected language
