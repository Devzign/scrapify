# Corporate Scrap Pickup — Backend Integration Script

Share this with your Laravel backend developer.

---

## 1. Migration

```php
// database/migrations/xxxx_add_corporate_fields_to_pickup_requests.php
public function up(): void
{
    Schema::table('pickup_requests', function (Blueprint $table) {
        // 'scrap' | 'donation' | 'corporate'
        $table->string('request_type')->default('scrap')->after('status');
        $table->string('corporate_notes')->nullable()->after('request_type');
        // Pickup boy fills this at time of pickup
        $table->decimal('final_quoted_amount', 10, 2)->nullable()->after('estimated_amount');
        $table->string('quoted_at')->nullable(); // timestamp when quoted
        $table->integer('quoted_by')->nullable(); // pickup_boy user id
    });
}
```

---

## 2. Routes (routes/api.php)

```php
// Corporate Pickup — Customer
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/corporate-pickup-request', [CorporatePickupController::class, 'store']);
    Route::get('/corporate-pickup-requests', [CorporatePickupController::class, 'index']);

    // Pickup boy quotes the price on-site
    Route::post('/pickup-requests/{id}/quote', [CorporatePickupController::class, 'submitQuote']);
});

// Admin
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/corporate-pickups', [Admin\CorporatePickupController::class, 'index']);
    Route::get('/corporate-pickups/{id}', [Admin\CorporatePickupController::class, 'show']);
});

// Warehouse
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('warehouse')->group(function () {
    Route::get('/corporate-pickups', [Warehouse\CorporatePickupController::class, 'index']);
});
```

---

## 3. CorporatePickupController (Customer)

```php
<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PickupRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CorporatePickupController extends Controller
{
    /**
     * List corporate pickups for authenticated customer
     */
    public function index(Request $request)
    {
        $pickups = PickupRequest::with(['items', 'images'])
            ->where('customer_id', Auth::id())
            ->where('request_type', 'corporate')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'code' => 200,
            'data' => [
                'items' => $pickups->items(),
                'pagination' => [
                    'total' => $pickups->total(),
                    'current_page' => $pickups->currentPage(),
                    'per_page' => $pickups->perPage(),
                    'last_page' => $pickups->lastPage(),
                ],
            ],
        ]);
    }

    /**
     * Create corporate pickup request
     * Same as regular pickup but:
     *  - request_type = 'corporate'
     *  - no payout_method required
     *  - estimated_amount = null (quoted later)
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'address'       => 'required|string',
            'address_id'    => 'required|integer',
            'city_id'       => 'required|integer',
            'pincode'       => 'required|string',
            'latitude'      => 'nullable|numeric',
            'longitude'     => 'nullable|numeric',
            'scheduled_at'  => 'required|string',
            'corporate_notes' => 'nullable|string|max:500',
            'items'         => 'required|array|min:1',
            'items.*.category_id' => 'required|integer',
            'items.*.weight'      => 'nullable|numeric|min:0',
            'items.*.quantity'    => 'nullable|integer|min:1',
            'items.*.unit'        => 'nullable|string|in:kg,pcs',
            'images'        => 'nullable|array',
            'images.*'      => 'nullable|file|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        // Resolve warehouse from city
        $warehouse = \App\Models\Warehouse::where('city_id', $validated['city_id'])->first();

        $pickup = PickupRequest::create([
            'pickup_code'      => 'CRP-' . strtoupper(substr(uniqid(), -6)) . '-' . rand(1000, 9999),
            'customer_id'      => Auth::id(),
            'request_type'     => 'corporate',
            'address'          => $validated['address'],
            'address_id'       => $validated['address_id'],
            'city_id'          => $validated['city_id'],
            'pincode'          => $validated['pincode'],
            'latitude'         => $validated['latitude'] ?? 0,
            'longitude'        => $validated['longitude'] ?? 0,
            'scheduled_at'     => $validated['scheduled_at'],
            'payout_method'    => 'quotation', // fixed for corporate
            'corporate_notes'  => $validated['corporate_notes'] ?? null,
            'status'           => 'pending',
            'warehouse_id'     => $warehouse?->id,
            'customer_name'    => Auth::user()->name,
            'customer_phone'   => Auth::user()->phone,
            'estimated_amount' => null, // quoted later by pickup boy
        ]);

        // Create items
        foreach ($validated['items'] as $item) {
            $pickup->items()->create([
                'category_id' => $item['category_id'],
                'weight'      => $item['weight'] ?? 0,
                'quantity'    => $item['quantity'] ?? 1,
                'price_per_unit' => 0, // no price at booking
                'total_price'    => 0,
            ]);
        }

        // Handle images
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $path = $image->store('pickup_requests', 'public');
                $pickup->images()->create([
                    'image_path' => $path,
                    'type' => 'item',
                    'url' => asset('storage/' . $path),
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'code' => 201,
            'message' => 'corporate_pickup.created',
            'data' => $pickup->load(['items', 'images']),
        ], 201);
    }

    /**
     * Pickup boy submits on-site quotation
     * POST /pickup-requests/{id}/quote
     * Body: { final_amount: 5000.00, notes: "optional" }
     */
    public function submitQuote(Request $request, int $id)
    {
        $pickup = PickupRequest::findOrFail($id);

        $validated = $request->validate([
            'final_amount' => 'required|numeric|min:0',
            'notes'        => 'nullable|string|max:500',
        ]);

        $pickup->update([
            'final_quoted_amount' => $validated['final_amount'],
            'quoted_by'           => Auth::id(),
            'quoted_at'           => now(),
            'corporate_notes'     => $validated['notes'] ?? $pickup->corporate_notes,
        ]);

        return response()->json([
            'success' => true,
            'code' => 200,
            'message' => 'quote.submitted',
            'data' => $pickup->fresh(['items', 'images']),
        ]);
    }
}
```

---

## 4. Admin CorporatePickupController

```php
<?php
namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\PickupRequest;

class CorporatePickupController extends Controller
{
    public function index()
    {
        $pickups = PickupRequest::with(['customer', 'items', 'warehouse', 'pickupBoy'])
            ->where('request_type', 'corporate')
            ->orderBy('created_at', 'desc')
            ->paginate(25);

        return response()->json([
            'success' => true,
            'code' => 200,
            'data' => [
                'items' => $pickups->items(),
                'pagination' => [
                    'total' => $pickups->total(),
                    'current_page' => $pickups->currentPage(),
                    'last_page' => $pickups->lastPage(),
                ],
            ],
        ]);
    }

    public function show(int $id)
    {
        $pickup = PickupRequest::with(['customer', 'items.category', 'images', 'warehouse', 'pickupBoy'])
            ->where('request_type', 'corporate')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'code' => 200,
            'data' => $pickup,
        ]);
    }
}
```

---

## 5. Key Differences from Regular Pickup

| Field | Regular Scrap | Corporate |
|---|---|---|
| `request_type` | `scrap` | `corporate` |
| `payout_method` | required (upi/bank/cash) | fixed as `quotation` |
| `estimated_amount` | calculated | `null` at booking |
| `final_quoted_amount` | - | set by pickup boy on-site |
| `pickup_code` prefix | `SCR-` | `CRP-` |
| Items | subcategory + attributes | main category + kg/pcs only |

---

## 6. Pickup Boy — Quote Screen API Call

```
POST /api/pickup-requests/{id}/quote
Headers: Authorization: Bearer {token}
Body: {
  "final_amount": 5000,
  "notes": "Mixed metal and e-waste"
}
```

---

## 7. Admin Panel Filter

Add to existing `/admin/pickups` endpoint:
```
GET /admin/pickups?type=corporate
GET /admin/pickups?type=scrap
GET /admin/pickups (all)
```

Filter in controller:
```php
if ($request->has('type')) {
    $query->where('request_type', $request->type);
}
```

---

## 8. pickup_requests table response shape (for mobile)

The existing `/pickup-requests` endpoint already returns all requests.
Add `request_type` and `final_quoted_amount` to the response transformer/resource.

For `/pickup-requests?type=corporate` filtering:
```php
if ($request->has('type')) {
    $query->where('request_type', $request->type);
}
```
