# API Optimization — Phase 2

## Where we are

Grocery is converted to `LazySliver`: **~24 → ~9 requests** on module tap. Twelve below-the-fold sections now fetch only when scrolled to.

The nine still firing eagerly on a grocery tap:

| Call | Why it fires | Actually needed on entry? |
|---|---|---|
| `getCategoryList` | first section | **yes** |
| `getBannerList` | second section | **yes** |
| `getTopOffer` | above-fold promo card | **yes** |
| `getUserInfo` | awaited; referral sheet reads it | **yes** |
| `getNotificationList` | header bell badge (`hasNotification`) | badge only — full list is overkill |
| `getLastOrders(isHome: true)` | the **Home tab's** list | **no** — not rendered on a module screen |
| `getLastOrders(isHome: false)` | module last-orders section | yes, but it is below the fold |
| `getCouponList` | — | **no** — no module screen renders coupons |
| `getModules` | module tab strip | rarely changes; refetched on every tap |

Plus 4 from `setModule`/`switchModule`, which are out of scope by your decision.

**Realistic floor: 4–5 requests per module tap.**

---

## The tension to design around

You want two things that pull in opposite directions:

1. **Fewer simultaneous calls** on entry.
2. **The user still sees all the data** in their view.

Lazy loading alone satisfies (1) and risks (2) — scroll fast and you hit shimmer. The answer is not "fetch less", it's **fetch in priority order, render from cache instantly, and quietly warm what's next**. Three mechanisms, described below, that already have most of their infrastructure in this codebase.

---

## Stage A — Finish what's proven

**Effort: ~2 hours. Saving: ~15 requests per tap on food / shop / pharmacy.**

Replicate the grocery conversion on the other three module screens using the existing [`LazySliver`](../lib/common/widgets/lazy_sliver.dart), then add each to `_lazySectionModules` in `home_screen.dart`.

Section-to-fetch mapping is already documented per screen; the only per-module differences are which sections exist. Food additionally has a **duplicate** `TopPicksNearYouWidget(isRecommended)` (sections 7 and 13) — collapse it during the conversion and one fetch disappears with it.

**Risk:** low; the pattern is proven on grocery. The one failure mode to watch is a section that collapses to zero height while unloaded — then everything below stacks into the viewport and fires at once. `_conditionalSection` keeps sections visible while data is `null`, which is what makes this safe.

---

## Stage B — Stop fetching what the screen never shows

**Effort: ~1 hour. Saving: 3 requests per tap.**

| Call | Change | Evidence |
|---|---|---|
| `getCouponList` | Fetch when the coupon screen opens / at checkout | Consumed only by `coupon/screens/coupon_screen.dart` and web widgets. No module screen renders it. |
| `getLastOrders(isHome: true)` | Only fetch when the **Home** tab is selected | It populates the Home tab's list; a module screen reads the `isHome: false` variant. |
| `getModules` | Once per session, and on zone/language change | Already cache-first. Module lists change rarely; today it refetches on every tap (local **and** a client recall). |

`getNotificationList` is the interesting one. The header only needs a boolean (`hasNotification`), but fetches the entire notification list to derive it — on every module tap. Without a backend change the honest fix is **fetch once per session** and refresh it when a push arrives or the notification screen is opened, rather than per tap. (A `GET /notifications/unread-count` would be the real fix, but that's backend work and out of scope.)

---

## Stage C — Guarantee the user always sees data

This is the half that protects the experience, and it's what makes aggressive laziness safe.

### C1 — Cache-first everywhere (render instantly, refresh behind)

Ten of the twelve lazy grocery sections already default to `DataSourceEnum.local`, so on a repeat visit they paint from the Drift cache **immediately** and refresh in the background. Two do not, and always block on the network:

- `getQuickDeliveryStoreList`
- `getPromotionalBannerList`

Convert both to the existing local-then-client pattern using [`CachedRepositoryMixin`](../lib/helper/cached_repository_mixin.dart). After this, every section a returning user scrolls to shows real content with no shimmer at all.

### C2 — Idle prefetch (the key piece)

After the first frame, when the user is *not* scrolling, quietly warm the next one or two unloaded sections. Scrolling then almost never reaches an unfetched section, while entry cost stays at 4–5 requests.

`main_screen.dart` already owns the `ScrollController` and already has an idle hook — `_onScrollEnd` (`NotificationListener<ScrollEndNotification>`). Extend that: on scroll-end, ask the next unrevealed `LazySliver` to warm itself. Cap concurrency at one or two so a warm never competes with a visible section's fetch.

Trade-off: total requests over a full session return to roughly today's number. The difference is **when** — spread across idle moments instead of 24 at once on tap. That is exactly the "user sees all their data without a burst" outcome.

### C3 — Keep shimmer honest

Laziness is only invisible if an unloaded section looks like it's loading. Audit each section's placeholder to confirm it has realistic height — the same property `LazySliver` depends on for correctness.

---

## Stage D — Protect the network layer

**Effort: ~3 hours. Saving: eliminates duplicate and stampeding requests app-wide.**

`ApiClient` currently has **no in-flight de-duplication and no concurrency limit** (verified — no `_pending`, `Queue`, or semaphore in `lib/api/api_client.dart`). Two consequences:

1. **Duplicate concurrent GETs both hit the network.** This is why `getAllCarts` can fire twice and download the payload twice even though the second response is discarded by its generation guard.
2. **Fast scrolling can stampede.** With Stage A on all four modules, flinging down the page can reveal six sections in a few frames — six simultaneous requests.

Two additions to `ApiClient.getData`:

- **In-flight map:** key on `uri + query`; if a request is already running, return the same `Future` instead of issuing a second. Fixes the duplicate-cart download without touching `setModule`/`switchModule`.
- **Concurrency cap** (4–6 simultaneous GETs, queue the rest). Keeps the visible section's request from queueing behind six off-screen ones on a slow connection.

This is the highest-leverage change in the list because it applies to every screen, not just the dashboard — but it also carries the widest blast radius, which is why it is last.

---

## Recommended sequence

| # | Stage | Effort | Effect on a module tap |
|---|---|---|---|
| 1 | A — lazy-load food / shop / pharmacy | 2h | ~24 → ~9 on three more modules |
| 2 | B — drop coupons, home-orders, modules | 1h | ~9 → ~5 |
| 3 | C1 — cache-first on the last two sections | 1h | no change in count; removes shimmer for returning users |
| 4 | C2 — idle prefetch | 3h | count unchanged; scrolling stops hitting shimmer |
| 5 | D — dedup + concurrency cap in ApiClient | 3h | removes duplicates app-wide; smooths bursts |

Stages 1–2 are the measurable wins. Stage 3–4 is what keeps the experience intact as the loading gets lazier. Stage 5 is infrastructure that pays off everywhere.

---

## Verification

Per stage, using the logging `ApiClient` already does:

```bash
flutter run | grep --line-buffered '====> API Call' | awk '{print $4}' | sort > /tmp/tap_<stage>.txt
wc -l /tmp/tap_<stage>.txt          # count on module tap
sort /tmp/tap_<stage>.txt | uniq -c | sort -rn | head   # any count >= 2 is a duplicate
```

| After stage | Expected on a grocery tap |
|---|---|
| current | ~9 |
| B | ~5 |
| D | no endpoint appears twice |

Behavioural checks that must keep passing:

1. Referral sheet still appears for a discount-eligible user (`getUserInfo` stays awaited)
2. Header notification badge still correct after Stage B's session-scoped fetch
3. Coupons still load when opening the coupon screen and at checkout
4. Module tab strip still correct after `getModules` becomes session-scoped — **test a zone change**, which is when the module list genuinely differs
5. Place an order → module last-orders list updates
6. Scroll each module top to bottom → every section populates, none stuck on shimmer
7. Rapid module switching → no crash, content matches the module landed on

---

## What I would not do

**Do not lazy-load above-the-fold sections.** Categories and banner must stay eager or the screen opens empty.

**Do not add a TTL to the Drift cache.** Every cached read is already followed by a network refresh, so nothing is stale beyond one round-trip. A TTL would mean a schema migration for no gain.

**Do not add `visibility_detector`.** `SliverLayoutBuilder` already gives exactly the signal needed, with no dependency.

**Do not guard getters that have no `reload` parameter.** Covered by convention 5 in `CLAUDE.md` — it makes data permanently stale, which is worse than an extra request.
