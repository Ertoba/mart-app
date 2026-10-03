# Store item listing APIs — `popular-items` and `store-categories/items`

Two customer endpoints list the items of **one store**. They now read the **same query
parameters**, so a filter bar written for one works against the other unchanged:

| endpoint | returns | ordering |
|---|---|---|
| `GET stores/popular-items/{id}` | a flat, paginated list | most ordered first |
| `GET store-categories/items` | items grouped under the store's categories | grouped, alphabetical inside a group |

They differ only in **shape and default order**, never in what they accept.

Every request and response in this file was captured from a live run against this install
(store `45` — *Café Monarch*, zone `1`, module `4`, 14 active items).

---

## Contents

1. [Base URL, headers and auth](#1-base-url-headers-and-auth)
2. [`GET stores/popular-items/{id}`](#2-get-storespopular-itemsid)
3. [`GET store-categories/items`](#3-get-store-categoriesitems)
4. [Shared parameter reference](#4-shared-parameter-reference)
5. [Worked curl examples](#5-worked-curl-examples)
6. [Behaviour matrix](#6-behaviour-matrix)
7. [Errors](#7-errors)
8. [Where the implementation lives](#8-where-the-implementation-lives)

---

## 1. Base URL, headers and auth

```
Base URL   http://mart_copy.test/api/v1
```

| header | required | notes |
|---|---|---|
| `moduleId` | **yes** | Module id or slug. Missing it is a `403` before the controller runs. |
| `zoneId` | yes in practice | JSON array of zone ids, e.g. `[1]` or `[1,3]`. Absent = no zone filter. |
| `longitude`, `latitude` | only for `sort_by=distance` and `filter_by=nearby` | Plain decimals. |
| `Authorization: Bearer <token>` | no | Both endpoints are public. A token is accepted and ignored by these two. |

`zoneId` is resolved through `ZoneService::resolveZoneIds()` before filtering, so passing a
parent zone also matches its children.

---

## 2. `GET stores/popular-items/{id}`

`{id}` is the store's **numeric id or its slug** — both work.

```bash
curl -s 'http://mart_copy.test/api/v1/stores/popular-items/45?limit=1' \
  -H 'zoneId: [1]' \
  -H 'moduleId: 4' \
  -H 'Accept: application/json'
```

Slug form, identical result:

```bash
curl -s 'http://mart_copy.test/api/v1/stores/popular-items/cafe-monarch45?limit=1' \
  -H 'zoneId: [1]' -H 'moduleId: 4' -H 'Accept: application/json'
```

### Response

```json
{
    "identical_code": "default_200",
    "message": "Successfully fetched",
    "content": {
        "data": [
            {
                "id": 264,
                "name": "Mutton Biriyani",
                "slug": "mutton-biriyani264",
                "image_full_url": null,
                "images_full_url": [],
                "price": 250.0,
                "discount": 10.0,
                "discount_type": "percent",
                "store_discount": 0.0,
                "happy_hour_discount": 0.0,
                "vendor_store_discount": 0.0,
                "flash_sale": 0,
                "stock": 0,
                "unit_type": "Kg",
                "maximum_cart_quantity": 0,
                "veg": 0,
                "organic": 0,
                "is_halal": 0,
                "avg_rating": 5.0,
                "rating_count": 1,
                "available_time_starts": "00:03:00",
                "available_time_ends": "23:56:00",
                "brand_name": null,
                "category_ids": [{ "id": "71", "position": 1 }],
                "module_id": 4,
                "module_type": "food",
                "store_id": 45,
                "store_name": "Café Monarch",
                "store_slug": "cafe-monarch45",
                "store_image_full_url": null,
                "verified_seller": 0,
                "halal_tag_status": 0,
                "zone_id": 1,
                "schedule_order": false,
                "free_delivery": false,
                "has_variant": 1,
                "recommended": 0,
                "store_category_id": 0,
                "store_category_name": null,
                "store_logo_full_url": null
            }
        ],
        "pagination": {
            "current_page": 1,
            "last_page": 14,
            "per_page": 1,
            "total": 14,
            "from": 1,
            "to": 1
        }
    },
    "errors": []
}
```

Items are rendered with `ItemListResource`.

### Ordering

1. `filter_by` never sets the order — any ordering it implies is discarded.
2. Base order is **popularity**: `order_count DESC`.
3. An explicit `sort_by` replaces the base order entirely.
4. `items.id ASC` is always the final tiebreaker, so pages never drop or repeat a row.

Pages concatenate exactly to the full list:

```
full : [264,279,265, 272,274,275, 277,278,280, 281,283,308, 335,336]
p1-p5: [264,279,265][272,274,275][277,278,280][281,283,308][335,336]
```

---

## 3. `GET store-categories/items`

The store is the **required `store_id` query parameter**, numeric only (a slug returns an
empty list).

```bash
curl -s 'http://mart_copy.test/api/v1/store-categories/items?store_id=45&limit=1' \
  -H 'zoneId: [1]' \
  -H 'moduleId: 4' \
  -H 'Accept: application/json'
```

### Response

```json
{
    "identical_code": "default_200",
    "message": "Successfully fetched",
    "content": {
        "total_size": 14,
        "limit": 1,
        "offset": 1,
        "category_source": "main_category",
        "categories": [
            { "id": 71, "name": "Biriyani", "image_full_url": null, "items_count": 2 },
            { "id": 78, "name": "Indian",   "image_full_url": null, "items_count": 1 },
            { "id": 79, "name": "Noodles",  "image_full_url": null, "items_count": 2 },
            { "id": 83, "name": "Snacks",   "image_full_url": null, "items_count": 6 },
            { "id": 84, "name": "Thai",     "image_full_url": null, "items_count": 3 }
        ],
        "category_wise_items": {
            "84": [
                {
                    "id": 279,
                    "name": "Chicken Coconut Soup",
                    "price": 220.0,
                    "discount": 5.0,
                    "discount_type": "percent",
                    "veg": 0,
                    "is_halal": 0,
                    "avg_rating": 0.0,
                    "…": "same item shape as popular-items, plus the fields below"
                }
            ]
        }
    },
    "errors": []
}
```

| field | meaning |
|---|---|
| `total_size` | items matching the filters across **all** categories — the number to paginate against |
| `limit` / `offset` | echo of the page requested |
| `category_source` | `store_category` when the store keeps its own categories, otherwise `main_category` |
| `categories` | only categories that still hold a matching item; `items_count` respects the filters |
| `category_wise_items` | object keyed by **category id (string)**; empty categories are omitted. `{}` when nothing matches |

### Item shape difference

37 fields are shared with `popular-items`. The two resources differ only here:

| only in `popular-items` (`ItemListResource`) | only in `store-categories/items` (`StoreCategoryItemResource`) |
|---|---|
| `recommended`, `store_category_id`, `store_category_name` | `base_price`, `status`, `available_date_starts`, `variations`, `food_variations`, `store`, `store_details` |

---

## 4. Shared parameter reference

Both endpoints accept every row below. Unknown or empty values are ignored, never an error.

### Paging

| param | default | notes |
|---|---|---|
| `limit` | `25` (`config('default_pagination')`) | page size |
| `offset` | `1` | **page number, not a row offset** |

### Filters

| param | values | effect |
|---|---|---|
| `type` | `all` (default), `veg`, `non_veg`, `halal` | `veg` → `veg = 1`, `non_veg` → `veg = 0`, `halal` also pushes `halal` into `filter_by` |
| `name` *or* `search` | free text | matches the item name, its translations, its category name and its tags. `name` wins if both are sent |
| `filter_by` *or* `quick_action` | CSV, JSON array or repeated key | see the list below; the two are merged and de-duplicated |
| `min_price` / `price_min` | number | `price >= n` |
| `max_price` / `price_max` | number | `price <= n` |
| `price` | `[min,max]` | inclusive range; overrides nothing, stacks with the two above |
| `rating` | `1` | order by review count, and derive `rating_count` if that was not sent |
| `rating_count` | `1`–`5` | `avg_rating >= n`, capped below `n + 1` |
| `rating_1` … `rating_5` | `1` | `avg_rating >= n` |
| `rating_1_plus` … `rating_4_plus` | `1` | `avg_rating > n` for 3+ and 4+; 1+/2+ behave as `>=` |
| `rating_plus` | `[3,4]` | `avg_rating >= min(list)` |

`filter_by` / `quick_action` accepts: `free_delivery`, `discounted` (alias `offers`),
`popular`, `new_arrivals`, `top_rated`, `veg`, `non_veg`, `currently_available`, `halal`,
`high`, `low`, `nearby`, `verified_seller`.

### Sorting

| `sort_by` | effect |
|---|---|
| `default` | endpoint's own order (popularity / grouped alphabetical) |
| `price_low_high` (alias `low`) | `price ASC` |
| `price_high_low` (alias `high`) | `price DESC` |
| `a_to_z` / `z_to_a` | name |
| `high_rated` | `avg_rating DESC` |
| `fast_delivery` | open stores first, then shortest delivery time |
| `distance` | nearest store first — needs `longitude` + `latitude` headers |

---

## 5. Worked curl examples

All of these return the **same item set** on both endpoints. Counts are from the live run.

```bash
# Common headers
H=(-H 'zoneId: [1]' -H 'moduleId: 4' -H 'Accept: application/json')
POPULAR='http://mart_copy.test/api/v1/stores/popular-items/45'
GROUPED='http://mart_copy.test/api/v1/store-categories/items?store_id=45'
```

**Bare list** — 14 items

```bash
curl -s "${H[@]}" "$POPULAR?limit=50"
curl -s "${H[@]}" "$GROUPED&limit=50"
```

**Veg only** — 0 items · **Halal only** — 1 item

```bash
curl -s "${H[@]}" "$POPULAR?limit=50&type=veg"
curl -s "${H[@]}" "$POPULAR?limit=50&type=halal"
```

**Price floor / ceiling / range** — 5 · 5 · 8 items

```bash
curl -s "${H[@]}" "$POPULAR?limit=50&min_price=200"
curl -s "${H[@]}" "$POPULAR?limit=50&max_price=100"
curl -s -G "${H[@]}" --data-urlencode 'price=[100,250]' "$POPULAR?limit=50"
```

> Always `--data-urlencode` the bracketed forms (`price`, `zoneId`, `rating_plus`) —
> unencoded `[` `]` are rejected before the app sees them.

**Search** — 2 items (`name` and `search` are interchangeable)

```bash
curl -s "${H[@]}" "$POPULAR?limit=50&name=biriyani"
curl -s "${H[@]}" "$POPULAR?limit=50&search=biriyani"
```

**Rating** — 1 item each

```bash
curl -s "${H[@]}" "$POPULAR?limit=50&rating_count=5"
curl -s "${H[@]}" "$POPULAR?limit=50&rating_4_plus=1"
curl -s -G "${H[@]}" --data-urlencode 'rating_plus=[4,5]' "$POPULAR?limit=50"
```

**Quick filters** — 8 items (`filter_by` and `quick_action` are merged)

```bash
curl -s "${H[@]}" "$POPULAR?limit=50&filter_by=discounted"
curl -s "${H[@]}" "$POPULAR?limit=50&quick_action=discounted"
curl -s "${H[@]}" "$POPULAR?limit=50&filter_by=discounted,currently_available"
```

**Sorting**

```bash
curl -s "${H[@]}" "$POPULAR?limit=50&sort_by=price_low_high"   # 2, 30, 35, 50, 60, 120, 150, 170 …
curl -s "${H[@]}" "$POPULAR?limit=50&sort_by=price_high_low"   # 275, 250, 250, 220, 220 …
curl -s "${H[@]}" "$POPULAR?limit=50&sort_by=a_to_z"
curl -s "${H[@]}" "$POPULAR?limit=50&sort_by=high_rated"
curl -s -H 'longitude: 90.4' -H 'latitude: 23.8' "${H[@]}" "$POPULAR?limit=50&sort_by=distance"
```

**Combined** — filter, search, sort and page in one call

```bash
curl -s -G "${H[@]}" \
  --data-urlencode 'price=[100,250]' \
  --data-urlencode 'type=non_veg' \
  --data-urlencode 'filter_by=discounted' \
  --data-urlencode 'sort_by=price_low_high' \
  --data-urlencode 'limit=10' \
  --data-urlencode 'offset=1' \
  "$POPULAR"
```

**Paging** — `offset` is the page number

```bash
curl -s "${H[@]}" "$POPULAR?limit=3&offset=1"   # [264, 279, 265]
curl -s "${H[@]}" "$POPULAR?limit=3&offset=2"   # [272, 274, 275]
curl -s "${H[@]}" "$POPULAR?limit=3&offset=3"   # [277, 278, 280]
```

---

## 6. Behaviour matrix

Measured on store `45`, zone `1`, module `4`.

| request | `popular-items` | `store-categories/items` |
|---|---|---|
| *(no params)* | 14 | 14 |
| `type=veg` | 0 | 0 |
| `type=non_veg` | 14 | 14 |
| `type=halal` | 1 | 1 |
| `min_price=200` | 5 | 5 |
| `max_price=100` | 5 | 5 |
| `price=[100,250]` | 8 | 8 |
| `name=biriyani` | 2 | 2 |
| `search=biriyani` | 2 | 2 |
| `rating_count=5` | 1 | 1 |
| `rating_4_plus=1` | 1 | 1 |
| `rating_3_plus=1` | 1 | 1 |
| `filter_by=discounted` | 8 | 8 |
| `quick_action=discounted` | 8 | 8 |
| `sort_by=price_low_high` | 14 (reordered) | 14 (reordered) |
| `sort_by=a_to_z` | 14 (reordered) | 14 (reordered) |
| `sort_by=high_rated` | 14 (reordered) | 14 (reordered) |

### Zone and module scoping

Both endpoints filter by the `zoneId` / `moduleId` headers:

| headers | result |
|---|---|
| `zoneId: [1]`, `moduleId: 4` | 14 — the store's own zone and module |
| `zoneId: [1,3]`, `moduleId: 4` | 14 — the store's zone is in the list |
| `zoneId: [3]`, `moduleId: 4` | 0 — store is not in that zone |
| `zoneId: [1]`, `moduleId: 1` | 0 — store is not in that module |

Omitting `zoneId` skips the zone filter entirely; omitting `moduleId` is a `403`.

### Service modules

When the current module is a **service** module, both endpoints delegate to
`ServiceProviderService` and the same parameters are forwarded through `serviceFilters()`.
The response shape is the service module's own.

---

## 7. Errors

**Missing `moduleId` header** — `403`, both endpoints

```json
{
    "identical_code": "forbidden_403",
    "message": "Permission denied",
    "content": null,
    "errors": [{ "code": "moduleId", "message": "Module ID required" }]
}
```

**Missing `store_id`** — `422`, `store-categories/items` only

```json
{
    "identical_code": "unprocessable_entity_422",
    "message": "The store id field is required.",
    "content": null,
    "errors": [{ "code": "store_id", "message": "The store id field is required." }]
}
```

**Unknown store, or every item filtered out** — `200` with an empty payload, not a `404`

```json
{
    "identical_code": "default_200",
    "message": "Successfully fetched",
    "content": {
        "data": [],
        "pagination": {
            "current_page": 1, "last_page": 1, "per_page": 5,
            "total": 0, "from": null, "to": null
        }
    },
    "errors": []
}
```

`store-categories/items` answers the same case with `total_size: 0`, `categories: []`,
`category_wise_items: {}`.

---

## 8. Where the implementation lives

| concern | file |
|---|---|
| shared parameter surface | `app/Traits/Api/StoreItemFiltersTrait.php` |
| flat list endpoint | `app/Http/Controllers/Api/V1/Customer/Store/StoreController@popularItems` |
| grouped endpoint | `app/Http/Controllers/Api/V1/Customer/Item/StoreCategoryController@items` |
| flat list query | `app/Services/Item/ItemService@getStorePopularList` |
| grouped query | `app/Services/Store/StoreCategoryService@getCategoriesWithItems` |
| filter/sort scopes | `app/Models/Item` — `scopeType`, `scopeApplyFilters`, `scopeApplySorting`, `scopeApplyRating`, `scopeApplyPriceRange` |
| `sort_by` / `filter_by` normalisation | `app/Traits/Item/ItemFilterTrait@resolveSearchFilters` |
| routes | `routes/api/v1/api.php` — `stores/popular-items/{id}`, `store-categories/items` |

`StoreItemFiltersTrait` is the single definition of the accepted parameters. Add a parameter
there and both endpoints pick it up; that is what keeps them from drifting apart again.

### Compatibility

Adding the parameters did not change what either endpoint returns when none of them are
sent. Verified against the previous implementation across the whole dataset: **45 stores
identical, 0 different**, plus 91 paginated page comparisons and 45 slug lookups, all
identical. The one deliberate change is that `popular-items` now honours the `zoneId` /
`moduleId` headers — see the scoping table in §6.
