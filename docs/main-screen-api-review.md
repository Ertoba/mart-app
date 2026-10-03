# `main_screen.dart` — API Call Review

**Scope:** how [`lib/features/dashboard/screens/main_screen.dart`](../lib/features/dashboard/screens/main_screen.dart) triggers network calls, and the request cost of tapping a module tab.
**Method:** static trace of the call graph from `MainScreen` → `SplashController` → `HomeScreen.loadData` → feature controllers, cross-checked against the runtime log that `ApiClient` emits for every request (`====> API Call: <uri>`).
**See also:** [home-api-usage.md](./home-api-usage.md) — the field-level companion to this doc: what is *inside* each home response, and which keys the app never reads.

---

## 1. How API calls are triggered

`MainScreen` never calls `ApiClient` itself. It owns **no** repository or service. All traffic is triggered indirectly through three entry points:

```
MainScreen.initState()
  ├── HomeScreen.loadData(false)        ← the bulk of the traffic
  └── LocationController.getZone(...)   ← 1 request (mobile only)

Module tab tap
  └── SplashController.selectModuleByTabIndex(index)
        └── switchModule(index, true)
              ├── await setModule(module)         ← cart + cashback + pro offer
              ├── clear caches (local, no network)
              └── 350ms debounce → HomeScreen.loadData(true, fromModule: true)

Pull-to-refresh
  └── _onRefresh(selectedModule)   → module-specific loadData
```

The layering itself is correct and follows the project convention — screens call controllers, controllers call service interfaces, repositories own `ApiClient`. **No architectural violation was found in this screen.** The issues below are about *volume* and *duplication*, not structure.

### The one design decision worth noting

`switchModule` debounces the heavy load by 350 ms and guards it with a `_moduleSwitchToken`:

```dart
_moduleLoadDebounce?.cancel();
_moduleLoadDebounce = Timer(const Duration(milliseconds: 350), () {
  if(token == _moduleSwitchToken) HomeScreen.loadData(true, fromModule: true);
});
```

This is good and does real work: rapidly tapping through five tabs issues **one** `loadData`, not five. Note it protects only `loadData` — the calls inside `setModule` are **not** debounced and do fire on every tap (see §4.1).

---

## 2. Cost of opening the app on the Home tab

`module == null`, so the large module block inside `loadData` is skipped.

| Trigger | Requests |
|---|---|
| `LocationController.getZone` | 1 |
| `getModules` | 1 |
| `getFeaturedBanner`, `getFeaturedStoreList` | 2 |
| Logged in: `getUserInfo`, `getNotificationList`, `getLastOrders`×2, `getCouponList`, `getAddressList` | 6 |
| `HomeNewScreen.initState` (`getLastOrders`, smart banners, …) | 2–3 |

**≈ 12–13 requests** for a logged-in user, **≈ 4** for a guest.

---

## 3. Cost of tapping a module tab

This is where the volume is. One tap on **Food**, logged in:

| Stage | Calls | Count |
|---|---|---|
| `setModule` | `getAllCarts`, `getCashBackOfferList`, `getProActiveOffer`* | 2–3 |
| `switchModule` (after `await setModule`) | `getAllCarts`, `getCashBackOfferList` **again** | 2 |
| `loadData` — module block | banners, promotional banners, reels, recommended/popular/latest/top-offer/quick-delivery stores, store list, discounted/popular/reviewed/recommended items, categories, basic + item campaigns, advertisements, visit-again | 18 |
| `loadData` — auth block | `getUserInfo`, `getNotificationList`, `getLastOrders`×2, `getCouponList` | 5 |
| `loadData` — always | `getModules` | 1 |
| `FoodModuleScreen.initState` | `getLastOrders(isHome: false)`, `getTopOffer` | 2 |

### **≈ 30 requests per module tap**

\* only when `proStatus` is true.

Per module type:

| Module | Approx. requests | Notes |
|---|---|---|
| Food | 30 | + `getQuickDeliveryStoreList` |
| Grocery | 32 | + flash sale, brands, quick delivery |
| Shop / eCommerce | 33 | + featured categories, flash sale, brands |
| Pharmacy | 34 | + basic medicine, featured + verified stores, common conditions |
| Parcel | ~10 | skips the module block entirely; + `getParcelCategoryList` |
| Taxi | ~7 | separate `loadTaxiApis` path |
| Ride | ~6 | skips the module block |
| Service | ~12 | own `ServiceScreen.loadData` |

The four store modules are the expensive ones. **Switching Food → Grocery → Food costs roughly 90 requests.**

---

## 4. Findings

### 4.1 — `getAllCarts` and `getCashBackOfferList` fire twice per module tap

**Severity: high** — trivially fixable, ~2 wasted round-trips on every tab tap.

`switchModule` awaits `setModule`, which already issues both calls, then issues them again:

| Call | In `setModule` | In `switchModule` |
|---|---|---|
| `getAllCarts` / `getServiceCartGroups` | [`splash_controller.dart:299-302`](../lib/features/splash/controllers/splash_controller.dart#L299) | [`:411-413`](../lib/features/splash/controllers/splash_controller.dart#L411) |
| `getCashBackOfferList` | [`:313`](../lib/features/splash/controllers/splash_controller.dart#L313) | [`:422`](../lib/features/splash/controllers/splash_controller.dart#L422) |

`getAllCarts` has a `_allCartsGeneration` guard so the **stale response is discarded** — meaning the duplicate is pure waste: the request is sent, the payload downloaded, then thrown away.

**Fix:** delete the calls from `switchModule`; `setModule` is awaited immediately above and already covers both.

### 4.2 — `getLastOrders` is fetched 3× per module tap

**Severity: medium**

- `loadData` calls it with `isHome: true` **and** `isHome: false` ([`home_screen.dart:75,80`](../lib/features/home/screens/home_screen.dart#L75))
- every module screen calls `isHome: false` again in `initState` ([`food_module_screen.dart:48`](../lib/features/dashboard/modules/food/screens/food_module_screen.dart#L48) and the grocery/shop/pharmacy equivalents)

Both variants hit the same endpoint with different parameters, and the third is redundant with the second. The comment at `home_screen.dart:76-79` explains the `isHome: false` call was added so the list refreshes after placing an order — but that made the module screens' own call redundant rather than replacing it.

**Fix:** drop the `getLastOrders(isHome: false)` from the four module screens' `initState`, since `loadData` now covers it.

### 4.3 — 18 parallel requests in a single burst

**Severity: medium** — architectural, not a bug.

The module block fires ~18 requests with no batching, no priority and no concurrency limit. On a slow connection they contend with each other, and the ones that matter for first paint (banners, categories) compete with ones far below the fold (`getRecommendedItemList`, `getTopOfferStoreList`, `getAdvertisementList`).

**Options, cheapest first:**
1. Defer below-the-fold sections to a `VisibilityDetector` or a post-first-frame callback.
2. Split `loadData` into `loadCriticalData()` / `loadSecondaryData()`, awaiting only the former.
3. Ask the backend for a composite home endpoint — one round-trip for the whole dashboard is the real fix.

### 4.4 — `HomeScreen.loadData` is a 60-line static method with 12 branches

**Severity: low** — maintainability.

It decides what to fetch via a chain of `if(moduleType == …)` checks reading `Get.find<SplashController>().module!.moduleType.toString()` repeatedly, with `configModel!` force-unwrapped throughout. It's the single most branch-heavy function in the startup path and the easiest place to introduce a duplicate call — §4.2 happened here.

**Suggestion:** a per-module strategy (`Map<String, Future<void> Function()>`) would make each module's fetch set explicit and reviewable.

### 4.5 — `getZone` is called on every `MainScreen` mount

**Severity: low**

[`main_screen.dart:75-80`](../lib/features/dashboard/screens/main_screen.dart#L75) re-fetches the zone from the cached address on every mount, unconditionally. `loadData` separately calls `syncZoneData()`. Worth confirming both are needed.

---

## 5. What is already done well

- **The 350 ms debounce + token guard** in `switchModule` genuinely prevents overlapping module loads and stale-module responses. This is the kind of protection that's usually missing.
- **`getAllCarts` generation guard** correctly discards out-of-order responses.
- **Layering is clean** — no `ApiClient` usage from screens or controllers anywhere in this path.
- **`AutomaticKeepAliveClientMixin`** on `MainScreen` avoids a full rebuild-and-refetch when returning to the dashboard.

---

## 6. Recommended order of work

| # | Change | Effort | Saving |
|---|---|---|---|
| 1 | Remove duplicate `getAllCarts` + `getCashBackOfferList` from `switchModule` | 5 min | 2 requests/tap |
| 2 | Remove `getLastOrders(isHome: false)` from the 4 module screens | 10 min | 1 request/tap |
| 3 | Defer below-the-fold fetches out of the initial burst | Half day | ~6 requests off the critical path |
| 4 | Composite home endpoint (backend) | Backend work | 18 → 1 |

Items 1 and 2 remove **3 of ~30 requests per tap** for a few minutes' work and carry no behavioural risk — both are strictly redundant calls whose results are already fetched on the same code path.

---

## 7. How to verify these numbers yourself

`ApiClient` logs every outbound request ([`api_client.dart:82`](../lib/api/api_client.dart#L82)), so the counts above can be confirmed empirically rather than trusted:

```bash
flutter run | grep --line-buffered '====> API Call'
```

Tap a module tab and count the lines. To count per module:

```bash
flutter run | grep '====> API Call' | awk '{print $4}' | sort | uniq -c | sort -rn
```

Any endpoint showing a count of 2 or more from a single tap is a duplicate worth investigating.

**Caveat on the numbers:** these are static counts of *call sites reached*. Actual request counts vary with login state, `repeatOrderOption`, `proStatus`, and whether a controller short-circuits on cached data. The relative picture — ~30 per tap, 3 of them redundant — holds regardless.
