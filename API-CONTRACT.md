# API Response Data — 6amMart User App

Every API this system calls, and **only the response data it actually uses**. Anything not listed here is not read by the app — the backend can stop sending it.

Nested data uses dot notation: `banners.store.id` is the `id` inside the `store` object inside each `banners` entry.

**Base URL:** `https://6ammart-admin.6amtech.com`

| | |
|---|---|
| Endpoints | 282 |
| Endpoints returning parsed data | 185 |
| Data fields used | 8957 |

> Fields were resolved with the Dart analyzer — every read is bound to the exact class that declares it, so a field is listed only if something in code or view genuinely reads it.

---

## Index

### Config & zone

- [`/api/v1/about-us`](#api-v1-about-us-aboutusuri)
- [`/api/v1/broadcasting/user-auth`](#api-v1-broadcasting-user-auth-pusherbroadcusturl)
- [`/api/v1/cancelation`](#api-v1-cancelation-cancellationuri)
- [`/api/v1/config`](#api-v1-config-configuri)
- [`/api/v1/config/direction-api`](#api-v1-config-direction-api-directionuri)
- [`/api/v1/config/distance-api`](#api-v1-config-distance-api-distancematrixuri)
- [`/api/v1/config/geocode-api`](#api-v1-config-geocode-api-geocodeuri)
- [`/api/v1/config/get-zone-id`](#api-v1-config-get-zone-id-zoneuri)
- [`/api/v1/config/place-api-autocomplete`](#api-v1-config-place-api-autocomplete-searchlocationuri)
- [`/api/v1/config/place-api-details`](#api-v1-config-place-api-details-placedetailsuri)
- [`/api/v1/module`](#api-v1-module-moduleuri)
- [`/api/v1/module/top-offer`](#api-v1-module-top-offer-topofferuri)
- [`/api/v1/privacy-policy`](#api-v1-privacy-policy-privacypolicyuri)
- [`/api/v1/pro-customer/terms-and-conditions`](#api-v1-pro-customer-terms-and-conditions-protermsandconditionuri)
- [`/api/v1/rideshare/customer/config/cancellation-reason-list`](#api-v1-rideshare-customer-config-cancellation-reason-list-ridecancellationreasonlist)
- [`/api/v1/rideshare/customer/config/get-payment-methods`](#api-v1-rideshare-customer-config-get-payment-methods-getpaymentmethods)
- [`/api/v1/rideshare/customer/config/get-routes`](#api-v1-rideshare-customer-config-get-routes-remaindistance)
- [`/api/v1/rideshare/customer/config/get-zone-id`](#api-v1-rideshare-customer-config-get-zone-id-getzoneiduri)
- [`/api/v1/rideshare/customer/config/other-emergency-contact-list`](#api-v1-rideshare-customer-config-other-emergency-contact-list-getotheremergencynumberlist)
- [`/api/v1/rideshare/customer/config/safety-alert-reason-list`](#api-v1-rideshare-customer-config-safety-alert-reason-list-getsafetyalertreasonlist)
- [`/api/v1/rideshare/customer/config/safety-precaution-list`](#api-v1-rideshare-customer-config-safety-precaution-list-getprecautionlist)
- [`/api/v1/shipping-policy`](#api-v1-shipping-policy-shippingpolicyuri)
- [`/api/v1/terms-and-conditions`](#api-v1-terms-and-conditions-termsandconditionuri)
- [`/api/v1/zone/check`](#api-v1-zone-check-checkzoneuri)
- [`/api/v1/zone/list`](#api-v1-zone-list-zonelisturi)

### Rental

- [`/api/v1/rental/banners`](#api-v1-rental-banners-gettaxibanneruri)
- [`/api/v1/rental/banners`](#api-v1-rental-banners-getproviderbanneruri)
- [`/api/v1/rental/coupon/apply`](#api-v1-rental-coupon-apply-taxicouponapplyuri)
- [`/api/v1/rental/coupon/list`](#api-v1-rental-coupon-list-gettaxicouponuri)
- [`/api/v1/rental/customer/trip/last`](#api-v1-rental-customer-trip-last-rentallasttrips)
- [`/api/v1/rental/provider/get-provider-details`](#api-v1-rental-provider-get-provider-details-getproviderdetailsuri)
- [`/api/v1/rental/provider/get-provider-reviews`](#api-v1-rental-provider-get-provider-reviews-gettaxiproviderreviewuri)
- [`/api/v1/rental/provider/verified`](#api-v1-rental-provider-verified-getverifiedprovidersuri)
- [`/api/v1/rental/user/cart/add-to-cart`](#api-v1-rental-user-cart-add-to-cart-addtocarcarturi)
- [`/api/v1/rental/user/cart/get-cart`](#api-v1-rental-user-cart-get-cart-getcarcartlisturi)
- [`/api/v1/rental/user/cart/remove-cart`](#api-v1-rental-user-cart-remove-cart-removeallcarcarturi)
- [`/api/v1/rental/user/cart/remove-multiple-cart`](#api-v1-rental-user-cart-remove-multiple-cart-removemultiplecarcarturi)
- [`/api/v1/rental/user/cart/remove-vehicle`](#api-v1-rental-user-cart-remove-vehicle-removecarcarturi)
- [`/api/v1/rental/user/cart/update-cart`](#api-v1-rental-user-cart-update-cart-updatecarcarturi)
- [`/api/v1/rental/user/cart/update-user-data`](#api-v1-rental-user-cart-update-user-data-tripupdateuserdatauri)
- [`/api/v1/rental/user/review/add`](#api-v1-rental-user-review-add-addtaxireviewuri)
- [`/api/v1/rental/user/trip/cancel-trip`](#api-v1-rental-user-trip-cancel-trip-tripcanceluri)
- [`/api/v1/rental/user/trip/delete-trip`](#api-v1-rental-user-trip-delete-trip-tripdeleteuri)
- [`/api/v1/rental/user/trip/get-tax`](#api-v1-rental-user-trip-get-tax-gettriptaxuri)
- [`/api/v1/rental/user/trip/get-trip-details`](#api-v1-rental-user-trip-get-trip-details-tripdetailsuri)
- [`/api/v1/rental/user/trip/get-trip-list`](#api-v1-rental-user-trip-get-trip-list-triplisturi)
- [`/api/v1/rental/user/trip/payment`](#api-v1-rental-user-trip-payment-trippaymenturi)
- [`/api/v1/rental/user/trip/reorder`](#api-v1-rental-user-trip-reorder-rentalreorder)
- [`/api/v1/rental/user/trip/trip-booking`](#api-v1-rental-user-trip-trip-booking-tripbookinguri)
- [`/api/v1/rental/user/wish-list`](#api-v1-rental-user-wish-list-gettaxiwishlisturi)
- [`/api/v1/rental/user/wish-list/add`](#api-v1-rental-user-wish-list-add-addtaxiwishlisturi)
- [`/api/v1/rental/user/wish-list/remove`](#api-v1-rental-user-wish-list-remove-removetaxiwishlisturi)
- [`/api/v1/rental/vehicle/brand-list`](#api-v1-rental-vehicle-brand-list-gettaxibrandlisturi)
- [`/api/v1/rental/vehicle/category-list`](#api-v1-rental-vehicle-category-list-getprovidervehiclecategorylisturi)
- [`/api/v1/rental/vehicle/category-list`](#api-v1-rental-vehicle-category-list-getvehiclecategoriesuri)
- [`/api/v1/rental/vehicle/get-provider-vehicles`](#api-v1-rental-vehicle-get-provider-vehicles-getprovidervehiclelisturi)
- [`/api/v1/rental/vehicle/get-vehicle-details`](#api-v1-rental-vehicle-get-vehicle-details-getvehicledetailsuri)
- [`/api/v1/rental/vehicle/popular-suggestion/`](#api-v1-rental-vehicle-popular-suggestion-getpopulartaxisuggestionuri)
- [`/api/v1/rental/vehicle/search/`](#api-v1-rental-vehicle-search-getselectvehiclesuri)
- [`/api/v1/rental/vehicle/search/suggestion`](#api-v1-rental-vehicle-search-suggestion-getsearchvehiclesuggestionuri)
- [`/api/v1/rental/vehicle/top-rated`](#api-v1-rental-vehicle-top-rated-gettopratedcarsuri)

### Ride-share

- [`/api/v1/rideshare/customer/banner/list`](#api-v1-rideshare-customer-banner-list-getridesharebanneruri)
- [`/api/v1/rideshare/customer/banner/update-redirection-count`](#api-v1-rideshare-customer-banner-update-redirection-count-bannercountupdate)
- [`/api/v1/rideshare/customer/coupon/apply`](#api-v1-rideshare-customer-coupon-apply-getridesharecouponapplyuri)
- [`/api/v1/rideshare/customer/coupon/list`](#api-v1-rideshare-customer-coupon-list-getridesharecouponuri)
- [`/api/v1/rideshare/customer/discount/list?limit=10&offset=`](#api-v1-rideshare-customer-discount-list-limit-10-offset-bestofferlist)
- [`/api/v1/rideshare/customer/drivers-near-me`](#api-v1-rideshare-customer-drivers-near-me-nearestdriverlist)
- [`/api/v1/rideshare/customer/review/store`](#api-v1-rideshare-customer-review-store-submitreview)
- [`/api/v1/rideshare/customer/ride/arrival-time`](#api-v1-rideshare-customer-ride-arrival-time-arrivalpickuppoint)
- [`/api/v1/rideshare/customer/ride/bidding-list/`](#api-v1-rideshare-customer-ride-bidding-list-biddinglist)
- [`/api/v1/rideshare/customer/ride/create`](#api-v1-rideshare-customer-ride-create-riderequest)
- [`/api/v1/rideshare/customer/ride/delete`](#api-v1-rideshare-customer-ride-delete-ridedeleteuri)
- [`/api/v1/rideshare/customer/ride/details/`](#api-v1-rideshare-customer-ride-details-tripdetails)
- [`/api/v1/rideshare/customer/ride/digital-payment`](#api-v1-rideshare-customer-ride-digital-payment-digitalpayment)
- [`/api/v1/rideshare/customer/ride/final-fare`](#api-v1-rideshare-customer-ride-final-fare-finalfare)
- [`/api/v1/rideshare/customer/ride/get-estimated-fare`](#api-v1-rideshare-customer-ride-get-estimated-fare-estimatedfare)
- [`/api/v1/rideshare/customer/ride/ignore-bidding`](#api-v1-rideshare-customer-ride-ignore-bidding-ignorebidding)
- [`/api/v1/rideshare/customer/ride/list`](#api-v1-rideshare-customer-ride-list-triplist)
- [`/api/v1/rideshare/customer/ride/list-history`](#api-v1-rideshare-customer-ride-list-history-gethistoryridelisturi)
- [`/api/v1/rideshare/customer/ride/list-running`](#api-v1-rideshare-customer-ride-list-running-getrunningridelisturi)
- [`/api/v1/rideshare/customer/ride/payment`](#api-v1-rideshare-customer-ride-payment-paymenturi)
- [`/api/v1/rideshare/customer/ride/pending-ride-list`](#api-v1-rideshare-customer-ride-pending-ride-list-getrunningridelist)
- [`/api/v1/rideshare/customer/ride/received-returning-parcel/`](#api-v1-rideshare-customer-ride-received-returning-parcel-parcelreceived)
- [`/api/v1/rideshare/customer/ride/ride-resume-status`](#api-v1-rideshare-customer-ride-ride-resume-status-currentridestatus)
- [`/api/v1/rideshare/customer/ride/trip-action`](#api-v1-rideshare-customer-ride-trip-action-tripacceptorreject)
- [`/api/v1/rideshare/customer/ride/update-status/`](#api-v1-rideshare-customer-ride-update-status-updatetripstatus)
- [`/api/v1/rideshare/customer/safety-alert/mark-as-solved/`](#api-v1-rideshare-customer-safety-alert-mark-as-solved-markassolvedsafetyalert)
- [`/api/v1/rideshare/customer/safety-alert/resend/`](#api-v1-rideshare-customer-safety-alert-resend-resendsafetyalert)
- [`/api/v1/rideshare/customer/safety-alert/show/`](#api-v1-rideshare-customer-safety-alert-show-customeralertdetails)
- [`/api/v1/rideshare/customer/safety-alert/store`](#api-v1-rideshare-customer-safety-alert-store-storesafetyalert)
- [`/api/v1/rideshare/customer/safety-alert/undo/`](#api-v1-rideshare-customer-safety-alert-undo-undosafetyalert)
- [`/api/v1/rideshare/customer/vehicle/category`](#api-v1-rideshare-customer-vehicle-category-getridesharecategoryuri)
- [`/api/v1/rideshare/user/store-live-location`](#api-v1-rideshare-user-store-live-location-updatelivelocation)

### Service

- [`/api/v1/service/booking/all-running-bookings`](#api-v1-service-booking-all-running-bookings-serviceallrunningbookingsuri)
- [`/api/v1/service/booking/cancel`](#api-v1-service-booking-cancel-servicebookingcanceluri)
- [`/api/v1/service/booking/delete`](#api-v1-service-booking-delete-servicebookingdeleteuri)
- [`/api/v1/service/booking/details/`](#api-v1-service-booking-details-servicebookingdetailsuri)
- [`/api/v1/service/booking/get-tax`](#api-v1-service-booking-get-tax-servicebookinggettaxuri)
- [`/api/v1/service/booking/invoice/`](#api-v1-service-booking-invoice-servicebookinginvoiceuri)
- [`/api/v1/service/booking/last`](#api-v1-service-booking-last-servicebookinglasturi)
- [`/api/v1/service/booking/list`](#api-v1-service-booking-list-servicebookinglisturi)
- [`/api/v1/service/booking/payment`](#api-v1-service-booking-payment-servicebookingpaymenturi)
- [`/api/v1/service/booking/place`](#api-v1-service-booking-place-serviceplacebookinguri)
- [`/api/v1/service/booking/rebook`](#api-v1-service-booking-rebook-servicebookingrebookuri)
- [`/api/v1/service/booking/track`](#api-v1-service-booking-track-servicebookingtrackuri)
- [`/api/v1/service/campaigns`](#api-v1-service-campaigns-servicecampaignsuri)
- [`/api/v1/service/campaigns/details`](#api-v1-service-campaigns-details-servicecampaigndetailsuri)
- [`/api/v1/service/category-providers`](#api-v1-service-category-providers-servicecategoryprovidersqueryuri)
- [`/api/v1/service/custom-requests`](#api-v1-service-custom-requests-customservicerequestsuri)
- [`/api/v1/service/customer/get-zone-id`](#api-v1-service-customer-get-zone-id-getservicezoneid)
- [`/api/v1/service/details`](#api-v1-service-details-servicedetailsuri)
- [`/api/v1/service/explore`](#api-v1-service-explore-serviceexploreuri)
- [`/api/v1/service/get-combined-data`](#api-v1-service-get-combined-data-servicecombineddatauri)
- [`/api/v1/service/item-or-store-search`](#api-v1-service-item-or-store-search-serviceitemorstoresearchuri)
- [`/api/v1/service/offers/items`](#api-v1-service-offers-items-serviceofferitemsuri)
- [`/api/v1/service/popular`](#api-v1-service-popular-servicepopularuri)
- [`/api/v1/service/query`](#api-v1-service-query-servicequeryuri)
- [`/api/v1/service/quick-emergency-experts`](#api-v1-service-quick-emergency-experts-servicequickemergencyexpertsuri)
- [`/api/v1/service/recommended`](#api-v1-service-recommended-servicerecommendeduri)
- [`/api/v1/service/related`](#api-v1-service-related-servicerelateduri)
- [`/api/v1/service/related-provider-services`](#api-v1-service-related-provider-services-servicerelatedproviderservicesuri)
- [`/api/v1/service/requested-services`](#api-v1-service-requested-services-requestedservicesuri)
- [`/api/v1/service/reviews`](#api-v1-service-reviews-servicereviewlisturi)
- [`/api/v1/service/reviews/submit`](#api-v1-service-reviews-submit-servicereviewsubmituri)
- [`/api/v1/service/search`](#api-v1-service-search-servicesearchuri)

### Categories

- [`/api/v1/categories`](#api-v1-categories-categoryuri)
- [`/api/v1/categories`](#api-v1-categories-servicecategoriesuri)
- [`/api/v1/categories/childes/`](#api-v1-categories-childes-subcategoryuri)
- [`/api/v1/categories/featured/items`](#api-v1-categories-featured-items-featuredcategoriesitemsuri)
- [`/api/v1/categories/items/`](#api-v1-categories-items-categoryitemuri)
- [`/api/v1/categories/popular`](#api-v1-categories-popular-searchpopularcategoriesuri)
- [`/api/v1/categories/stores/`](#api-v1-categories-stores-categorystoreuri)
- [`/api/v1/categories/top`](#api-v1-categories-top-topcategoriesuri)

### Items

- [`/api/v1/brand`](#api-v1-brand-brandlisturi)
- [`/api/v1/brand/items`](#api-v1-brand-items-branditemuri)
- [`/api/v1/common-condition`](#api-v1-common-condition-commonconditionuri)
- [`/api/v1/common-condition/items/`](#api-v1-common-condition-items-conditionwiseitemuri)
- [`/api/v1/items/basic`](#api-v1-items-basic-basicmedicineuri)
- [`/api/v1/items/details/`](#api-v1-items-details-itemdetailsuri)
- [`/api/v1/items/discounted`](#api-v1-items-discounted-discounteditemsuri)
- [`/api/v1/items/item-or-store-search`](#api-v1-items-item-or-store-search-searchsuggestionsuri)
- [`/api/v1/items/latest`](#api-v1-items-latest-storeitemuri)
- [`/api/v1/items/most-reviewed`](#api-v1-items-most-reviewed-revieweditemuri)
- [`/api/v1/items/popular`](#api-v1-items-popular-popularitemuri)
- [`/api/v1/items/recommended`](#api-v1-items-recommended-storerecommendeditemuri)
- [`/api/v1/items/recommended?filter=`](#api-v1-items-recommended-filter-recommendeditemsuri)
- [`/api/v1/items/reviews`](#api-v1-items-reviews-getreviewlisturi)
- [`/api/v1/items/reviews/submit`](#api-v1-items-reviews-submit-reviewuri)
- [`/api/v1/items/suggested`](#api-v1-items-suggested-cartstoresuggesteditemsuri)
- [`/api/v1/store-categories/items`](#api-v1-store-categories-items-storecategoryitemsuri)
- [`/api/v1/trending-searches`](#api-v1-trending-searches-trendingsearchesuri)

### Stores

- [`/api/v1/offers/stores`](#api-v1-offers-stores-offerstoresuri)
- [`/api/v1/stores/details/`](#api-v1-stores-details-storedetailsuri)
- [`/api/v1/stores/distance`](#api-v1-stores-distance-distancestoresuri)
- [`/api/v1/stores/exclusive-deals`](#api-v1-stores-exclusive-deals-exclusivedealsuri)
- [`/api/v1/stores/get-stores`](#api-v1-stores-get-stores-storeuri)
- [`/api/v1/stores/latest`](#api-v1-stores-latest-lateststoreuri)
- [`/api/v1/stores/popular`](#api-v1-stores-popular-popularstoreuri)
- [`/api/v1/stores/quick-delivery`](#api-v1-stores-quick-delivery-quickdeliverystoresuri)
- [`/api/v1/stores/recommended`](#api-v1-stores-recommended-recommendedstoreuri)
- [`/api/v1/stores/reviews`](#api-v1-stores-reviews-storereviewuri)
- [`/api/v1/stores/top-offer-near-me`](#api-v1-stores-top-offer-near-me-topofferstoreuri)
- [`/api/v1/stores/verified`](#api-v1-stores-verified-serviceverifiedprovidersuri)

### Promotions

- [`/api/v1/advertisement/list`](#api-v1-advertisement-list-advertisementlisturi)
- [`/api/v1/banners`](#api-v1-banners-servicebannersuri)
- [`/api/v1/banners`](#api-v1-banners-banneruri)
- [`/api/v1/banners/`](#api-v1-banners-storebannersuri)
- [`/api/v1/banners/taxi`](#api-v1-banners-taxi-taxibanneruri)
- [`/api/v1/campaigns/basic`](#api-v1-campaigns-basic-basiccampaignuri)
- [`/api/v1/campaigns/basic-campaign-details?basic_campaign_id=`](#api-v1-campaigns-basic-campaign-details-basic-campaign-id-basiccampaigndetailsuri)
- [`/api/v1/campaigns/item`](#api-v1-campaigns-item-itemcampaignuri)
- [`/api/v1/cashback/getCashback`](#api-v1-cashback-getcashback-getcashbackamounturi)
- [`/api/v1/cashback/list`](#api-v1-cashback-list-cashbackofferlisturi)
- [`/api/v1/coupon/apply?code=`](#api-v1-coupon-apply-code-couponapplyuri)
- [`/api/v1/coupon/list`](#api-v1-coupon-list-couponuri)
- [`/api/v1/coupon/list/taxi`](#api-v1-coupon-list-taxi-taxicouponuri)
- [`/api/v1/flash-sales`](#api-v1-flash-sales-flashsaleuri)
- [`/api/v1/flash-sales/items`](#api-v1-flash-sales-items-flashsaleproductsuri)
- [`/api/v1/offers/items`](#api-v1-offers-items-offeritemsuri)
- [`/api/v1/other-banners`](#api-v1-other-banners-parcelotherbanneruri)
- [`/api/v1/other-banners`](#api-v1-other-banners-promotionalbanneruri)
- [`/api/v1/other-banners/video-content`](#api-v1-other-banners-video-content-videocontenturi)
- [`/api/v1/other-banners/why-choose`](#api-v1-other-banners-why-choose-whychooseuri)
- [`/api/v1/smart-banners`](#api-v1-smart-banners-smartbanneruri)

### Cart

- [`/api/v1/customer/cart/add`](#api-v1-customer-cart-add-addcarturi)
- [`/api/v1/customer/cart/get-all`](#api-v1-customer-cart-get-all-getallcartsuri)
- [`/api/v1/customer/cart/list`](#api-v1-customer-cart-list-getcartlisturi)
- [`/api/v1/customer/cart/remove`](#api-v1-customer-cart-remove-removeallcarturi)
- [`/api/v1/customer/cart/remove-item`](#api-v1-customer-cart-remove-item-removeitemcarturi)
- [`/api/v1/customer/cart/update`](#api-v1-customer-cart-update-updatecarturi)

### Orders

- [`/api/v1/customer/order-again/reorder`](#api-v1-customer-order-again-reorder-reorderuri)
- [`/api/v1/customer/order/all-running-orders`](#api-v1-customer-order-all-running-orders-dashboardorderuri)
- [`/api/v1/customer/order/cancel`](#api-v1-customer-order-cancel-ordercanceluri)
- [`/api/v1/customer/order/cancellation-reasons`](#api-v1-customer-order-cancellation-reasons-ordercancellationuri)
- [`/api/v1/customer/order/delete`](#api-v1-customer-order-delete-orderdeleteuri)
- [`/api/v1/customer/order/details?order_id=`](#api-v1-customer-order-details-order-id-orderdetailsuri)
- [`/api/v1/customer/order/get-Tax`](#api-v1-customer-order-get-tax-getordertaxuri)
- [`/api/v1/customer/order/get-surge-price`](#api-v1-customer-order-get-surge-price-getsurgepriceuri)
- [`/api/v1/customer/order/last`](#api-v1-customer-order-last-lastordersuri)
- [`/api/v1/customer/order/list`](#api-v1-customer-order-list-allorderlist)
- [`/api/v1/customer/order/offline-payment`](#api-v1-customer-order-offline-payment-offlinepaymentsaveinfouri)
- [`/api/v1/customer/order/offline-payment-update`](#api-v1-customer-order-offline-payment-update-offlinepaymentupdateinfouri)
- [`/api/v1/customer/order/parcel-instructions`](#api-v1-customer-order-parcel-instructions-parcelinstructionuri)
- [`/api/v1/customer/order/parcel-return`](#api-v1-customer-order-parcel-return-customerparcelreturn)
- [`/api/v1/customer/order/payment-failed`](#api-v1-customer-order-payment-failed-paymentfaileddetailsuri)
- [`/api/v1/customer/order/payment-method`](#api-v1-customer-order-payment-method-codswitchuri)
- [`/api/v1/customer/order/place`](#api-v1-customer-order-place-placeorderuri)
- [`/api/v1/customer/order/prescription/place`](#api-v1-customer-order-prescription-place-placeprescriptionorderuri)
- [`/api/v1/customer/order/refund-reasons`](#api-v1-customer-order-refund-reasons-refundreasonuri)
- [`/api/v1/customer/order/refund-request`](#api-v1-customer-order-refund-request-refundrequesturi)
- [`/api/v1/customer/order/track?order_id=`](#api-v1-customer-order-track-order-id-trackuri)
- [`/api/v1/customer/order/wallet-payment`](#api-v1-customer-order-wallet-payment-walletswitchuri)
- [`/api/v1/customer/saved-files`](#api-v1-customer-saved-files-savedfilesuri)
- [`/api/v1/customer/saved-files/delete-all`](#api-v1-customer-saved-files-delete-all-deletesavedfilesuri)
- [`/api/v1/customer/saved-files/store`](#api-v1-customer-saved-files-store-storesavedfilesuri)
- [`/api/v1/most-tips`](#api-v1-most-tips-mosttipsuri)
- [`/api/v1/offline_payment_method_list`](#api-v1-offline-payment-method-list-offlinemethodlisturi)
- [`/api/v1/vehicle/extra_charge`](#api-v1-vehicle-extra-charge-vehiclechargeuri)

### Address

- [`/api/v1/customer/address/add`](#api-v1-customer-address-add-addaddressuri)
- [`/api/v1/customer/address/delete?address_id=`](#api-v1-customer-address-delete-address-id-removeaddressuri)
- [`/api/v1/customer/address/list`](#api-v1-customer-address-list-addresslisturi)
- [`/api/v1/customer/address/update/`](#api-v1-customer-address-update-updateaddressuri)

### Wishlist

- [`/api/v1/customer/wish-list`](#api-v1-customer-wish-list-wishlistgeturi)
- [`/api/v1/customer/wish-list/add?`](#api-v1-customer-wish-list-add-addwishlisturi)
- [`/api/v1/customer/wish-list/remove?`](#api-v1-customer-wish-list-remove-removewishlisturi)

### Customer account

- [`/api/v1/customer/ai-chat/conversations`](#api-v1-customer-ai-chat-conversations-aichatconversationlisturi)
- [`/api/v1/customer/ai-chat/messages`](#api-v1-customer-ai-chat-messages-aichatmessagesuri)
- [`/api/v1/customer/ai-chat/send`](#api-v1-customer-ai-chat-send-aichatsendmessageuri)
- [`/api/v1/customer/automated-message`](#api-v1-customer-automated-message-supportreasonuri)
- [`/api/v1/customer/cm-firebase-token`](#api-v1-customer-cm-firebase-token-tokenuri)
- [`/api/v1/customer/info`](#api-v1-customer-info-customerinfouri)
- [`/api/v1/customer/loyalty-point/point-transfer`](#api-v1-customer-loyalty-point-point-transfer-loyaltypointtransferuri)
- [`/api/v1/customer/loyalty-point/transactions`](#api-v1-customer-loyalty-point-transactions-loyaltytransactionuri)
- [`/api/v1/customer/message/details`](#api-v1-customer-message-details-messagelisturi)
- [`/api/v1/customer/message/list`](#api-v1-customer-message-list-conversationlisturi)
- [`/api/v1/customer/message/search-list`](#api-v1-customer-message-search-list-searchconversationlisturi)
- [`/api/v1/customer/message/send`](#api-v1-customer-message-send-sendmessageuri)
- [`/api/v1/customer/monthly-order/list`](#api-v1-customer-monthly-order-list-monthlyorderlisturi)
- [`/api/v1/customer/monthly-order/remove`](#api-v1-customer-monthly-order-remove-monthlyorderremoveuri)
- [`/api/v1/customer/notifications`](#api-v1-customer-notifications-notificationuri)
- [`/api/v1/customer/pro-customer/active-offer`](#api-v1-customer-pro-customer-active-offer-proactiveofferuri)
- [`/api/v1/customer/pro-customer/cancel`](#api-v1-customer-pro-customer-cancel-procancelsubscriptionsuri)
- [`/api/v1/customer/pro-customer/subscribe`](#api-v1-customer-pro-customer-subscribe-procustomersubscribeuri)
- [`/api/v1/customer/reels/details`](#api-v1-customer-reels-details-reeldetailsuri)
- [`/api/v1/customer/reels/like`](#api-v1-customer-reels-like-reellikeuri)
- [`/api/v1/customer/reels/list`](#api-v1-customer-reels-list-reellisturi)
- [`/api/v1/customer/reels/stats`](#api-v1-customer-reels-stats-reelstatsuri)
- [`/api/v1/customer/reels/visit`](#api-v1-customer-reels-visit-reelvisituri)
- [`/api/v1/customer/remove-account`](#api-v1-customer-remove-account-customerremoveuri)
- [`/api/v1/customer/suggested-items`](#api-v1-customer-suggested-items-suggesteditemuri)
- [`/api/v1/customer/update-interest`](#api-v1-customer-update-interest-interesturi)
- [`/api/v1/customer/update-profile`](#api-v1-customer-update-profile-updateprofileuri)
- [`/api/v1/customer/update-zone`](#api-v1-customer-update-zone-updatezoneuri)
- [`/api/v1/customer/visit-again`](#api-v1-customer-visit-again-visitagainstoreuri)
- [`/api/v1/customer/wallet/add-fund`](#api-v1-customer-wallet-add-fund-addfunduri)
- [`/api/v1/customer/wallet/bonuses`](#api-v1-customer-wallet-bonuses-walletbonusuri)
- [`/api/v1/customer/wallet/transactions`](#api-v1-customer-wallet-transactions-wallettransactionuri)

### Auth

- [`/api/v1/auth/delivery-man/store`](#api-v1-auth-delivery-man-store-dmregisteruri)
- [`/api/v1/auth/firebase-reset-password`](#api-v1-auth-firebase-reset-password-firebaseresetpassword)
- [`/api/v1/auth/firebase-verify-token`](#api-v1-auth-firebase-verify-token-firebaseauthverify)
- [`/api/v1/auth/forgot-password`](#api-v1-auth-forgot-password-forgetpassworduri)
- [`/api/v1/auth/guest/request`](#api-v1-auth-guest-request-guestloginuri)
- [`/api/v1/auth/login`](#api-v1-auth-login-loginuri)
- [`/api/v1/auth/reset-password`](#api-v1-auth-reset-password-resetpassworduri)
- [`/api/v1/auth/sign-up`](#api-v1-auth-sign-up-registeruri)
- [`/api/v1/auth/update-info`](#api-v1-auth-update-info-personalinformationuri)
- [`/api/v1/auth/vendor/register`](#api-v1-auth-vendor-register-storeregisteruri)
- [`/api/v1/auth/verify-phone`](#api-v1-auth-verify-phone-verifyphoneuri)
- [`/api/v1/auth/verify-token`](#api-v1-auth-verify-token-verifytokenuri)
- [`/api/v1/get-vehicles`](#api-v1-get-vehicles-vehiclesuri)
- [`/api/v1/vendor/business_plan`](#api-v1-vendor-business-plan-businessplanuri)
- [`/api/v1/vendor/package-view`](#api-v1-vendor-package-view-storepackagesuri)
- [`/api/v1/vendor/subscription/payment/api`](#api-v1-vendor-subscription-payment-api-businessplanpaymenturi)

### Parcel

- [`/api/v1/get-parcel-cancellation-reasons`](#api-v1-get-parcel-cancellation-reasons-getparcelcancellationreasons)
- [`/api/v1/parcel-category`](#api-v1-parcel-category-parcelcategoryuri)

### Other

- [`/api/v1/`](#api-v1-searchuri)
- [`/api/v1/app-download-section`](#api-v1-app-download-section-appdownloadsectionuri)
- [`/api/v1/delivery-man/reviews/submit`](#api-v1-delivery-man-reviews-submit-deliverymanreviewuri)
- [`/api/v1/newsletter/subscribe`](#api-v1-newsletter-subscribe-subscriptionuri)
- [`/api/v1/pro-customer/faqs`](#api-v1-pro-customer-faqs-profaqsuri)
- [`/api/v1/pro-customer/plans`](#api-v1-pro-customer-plans-proplansuri)
- [`/api/v1/refund-policy`](#api-v1-refund-policy-refunduri)

---

# Config & zone

<a id="api-v1-about-us-aboutusuri"></a>
## Endpoint : /api/v1/about-us

- **Constant**: `AppConstants.aboutUsUri`
- **Repository**: `html_repository.dart:14` — getHtmlText
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-broadcasting-user-auth-pusherbroadcusturl"></a>
## Endpoint : /api/v1/broadcasting/user-auth

- **Constant**: `AppConstants.pusherBroadcustUrl`
- **Repository**: `pusher_helper.dart:103`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-cancelation-cancellationuri"></a>
## Endpoint : /api/v1/cancelation

- **Constant**: `AppConstants.cancellationUri`
- **Repository**: `html_repository.dart:14` — getHtmlText
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-config-configuri"></a>
## Endpoint : /api/v1/config

- **Constant**: `AppConstants.configUri`
- **Repository**: `splash_repository.dart:30`
- **Model**: `lib/common/models/config_model.dart`
- **Parsed to model**: Yes

**Data:**

- business_name
- logo_full_url
- address
- phone
- email
- country
- default_location
- default_location.lat
- default_location.lng
- currency_symbol
- currency_symbol_direction
- app_minimum_version_android
- app_url_android
- app_minimum_version_ios
- app_url_ios
- customer_verification
- order_delivery_verification
- cash_on_delivery
- digital_payment
- demo
- maintenance_mode
- timeformat
- language
- language.key
- language.value
- toggle_veg_non_veg
- toggle_dm_registration
- toggle_rider_registration
- toggle_store_registration
- schedule_order_slot_duration
- digit_after_decimal_point
- module
- module.id
- module.module_name
- module.module_type
- module.slug
- module.thumbnail_full_url
- module.icon_full_url
- module.short_description
- module.stores_count
- module.top_offer
- module.top_offer.discount
- module.top_offer.discount_type
- module.min_delivery_time
- module.flash_sale
- module.free_delivery
- module_config
- parcel_per_km_shipping_charge
- parcel_minimum_shipping_charge
- social_media
- social_media.name
- social_media.link
- footer_text
- download_user_app_links
- download_user_app_links.playstore_url_status
- download_user_app_links.playstore_url
- download_user_app_links.apple_store_url_status
- download_user_app_links.apple_store_url
- loyalty_point_exchange_rate
- loyalty_point_item_purchase_point
- loyalty_point_status
- loyalty_point_minimum_point
- customer_wallet_status
- dm_tips_status
- ref_earning_status
- refund_active_status
- ref_earning_exchange_rate
- social_login
- social_login.status
- social_login.client_id
- social_login.redirect_url_flutter
- apple_login
- apple_login.status
- apple_login.client_id
- apple_login.redirect_url_flutter
- refund_policy
- cancelation_policy
- shipping_policy
- prescription_order_status
- cookies_text
- home_delivery_status
- takeaway_status
- partial_payment_status
- partial_payment_method
- additional_charge_status
- additional_charge_name
- additional_charge
- active_payment_method_list
- active_payment_method_list.gateway
- active_payment_method_list.gateway_title
- active_payment_method_list.gateway_image_full_url
- digital_payment_info
- digital_payment_info.plugin_payment_gateways
- validation_config
- validation_config.max_file_size
- add_fund_status
- offline_payment_status
- guest_checkout_status
- admin_commission
- subscription_free_trial_days
- subscription_free_trial_status
- subscription_business_model
- commission_business_model
- subscription_free_trial_type
- country_picker_status
- firebase_otp_verification
- centralize_login
- centralize_login.manual_login_status
- centralize_login.otp_login_status
- centralize_login.social_login_status
- centralize_login.google_login_status
- centralize_login.facebook_login_status
- centralize_login.apple_login_status
- centralize_login.email_verification_status
- centralize_login.phone_verification_status
- vehicle_distance_min
- vehicle_hourly_min
- vehicle_day_wise_min
- admin_free_delivery
- admin_free_delivery.status
- admin_free_delivery.type
- admin_free_delivery.free_delivery_over
- is_sms_active
- is_mail_active
- parcel_cancellation_basic_setup
- parcel_cancellation_basic_setup.return_fee_status
- parcel_cancellation_basic_setup.return_fee
- websocket_status
- websocket_url
- safety_feature_status
- ride_safety_delay_time
- ride_safety_delay_time_format
- safety_feature_after_ride_complete_status
- safety_feature_after_ride_complete_time
- safety_feature_after_ride_complete_time_format
- emergency_govt_number
- review_status
- popular_tips
- ride_search_radius
- ride_otp_confirmation
- rider_completion_radius
- dm_referral_data
- dm_referral_data.referal_status
- rider_referral_data
- rider_referral_data.referal_status
- customer_route_preference
- repeat_order_option
- monthly_order_reminder
- maintenance_mode_data
- maintenance_mode_data.maintenance_system_setup
- maintenance_mode_data.maintenance_message_setup
- maintenance_mode_data.maintenance_message_setup.business_number
- maintenance_mode_data.maintenance_message_setup.business_email
- maintenance_mode_data.maintenance_message_setup.maintenance_message
- maintenance_mode_data.maintenance_message_setup.message_body
- pro_member_status
- ai_chat_status
- service_module
- service_module.schedule_time_restriction_status
- service_module.schedule_time_restriction_value
- service_module.schedule_time_restriction_unit
- service_module.bidding_system
- service_module.post_validation_days
- service_module.otp_for_complete_service
- service_module.rebooking_option
- service_module.provider_verified_badge
- verified_store_status

<a id="api-v1-config-direction-api-directionuri"></a>
## Endpoint : /api/v1/config/direction-api

- **Constant**: `AppConstants.directionUri`
- **Repository**: `order_repository.dart:41` — getRouteBetweenCoordinates
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-config-distance-api-distancematrixuri"></a>
## Endpoint : /api/v1/config/distance-api

- **Constant**: `AppConstants.distanceMatrixUri`
- **Repository**: `checkout_repository.dart:44` — getDistanceInMeter
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-config-geocode-api-geocodeuri"></a>
## Endpoint : /api/v1/config/geocode-api

- **Constant**: `AppConstants.geocodeUri`
- **Repository**: `location_repository.dart:19` — getAddressFromGeocode
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-config-get-zone-id-zoneuri"></a>
## Endpoint : /api/v1/config/get-zone-id

- **Constant**: `AppConstants.zoneUri`
- **Repository**: `location_repository.dart:31`
- **Model**: `lib/features/location/domain/models/zone_model.dart`
- **Parsed to model**: Yes

**Data:**

- zone_id
- zone_data
- zone_data.id
- zone_data.status
- zone_data.cash_on_delivery
- zone_data.digital_payment
- zone_data.offline_payment
- zone_data.increased_delivery_fee_status
- zone_data.increase_delivery_charge_message
- zone_data.modules
- zone_data.modules.id
- zone_data.modules.module_name
- zone_data.modules.module_type
- zone_data.modules.stores_count
- zone_data.modules.theme_id
- zone_data.modules.additional_delivery_option_status
- zone_data.modules.delivery_options
- zone_data.modules.delivery_options.delivery_type
- zone_data.modules.delivery_options.extra_charge
- zone_data.modules.delivery_options.reduce_charge
- zone_data.modules.delivery_options.add_delivery_time
- zone_data.modules.delivery_options.reduce_delivery_time
- zone_data.modules.pivot
- zone_data.modules.pivot.zone_id
- zone_data.modules.pivot.per_km_shipping_charge
- zone_data.modules.pivot.minimum_shipping_charge
- zone_data.modules.pivot.maximum_shipping_charge
- zone_data.modules.pivot.maximum_cod_order_amount
- zone_data.modules.pivot.delivery_charge_type
- zone_data.modules.pivot.fixed_shipping_charge
- zone_data.modules.pivot.minimum_delivery_charge

<a id="api-v1-config-place-api-autocomplete-searchlocationuri"></a>
## Endpoint : /api/v1/config/place-api-autocomplete

- **Constant**: `AppConstants.searchLocationUri`
- **Repository**: `location_repository.dart:45` — searchLocation
- **Model**: `lib/features/location/domain/models/prediction_model.dart`
- **Parsed to model**: Yes

**Data:**

- placePrediction

<a id="api-v1-config-place-api-details-placedetailsuri"></a>
## Endpoint : /api/v1/config/place-api-details

- **Constant**: `AppConstants.placeDetailsUri`
- **Repository**: `location_repository.dart:60` — getPlaceDetails
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-module-moduleuri"></a>
## Endpoint : /api/v1/module

- **Constant**: `AppConstants.moduleUri`
- **Repository**: `splash_repository.dart:137`
- **Model**: `lib/common/models/module_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- module_name
- module_type
- slug
- thumbnail_full_url
- icon_full_url
- short_description
- stores_count
- top_offer
- top_offer.discount
- top_offer.discount_type
- min_delivery_time
- flash_sale
- free_delivery

<a id="api-v1-module-top-offer-topofferuri"></a>
## Endpoint : /api/v1/module/top-offer

- **Constant**: `AppConstants.topOfferUri`
- **Repository**: `home_repository.dart:62` — getTopOffer
- **Model**: `lib/features/home/domain/models/top_offer_model.dart`
- **Parsed to model**: Yes

**Data:**

- discount
- discount_type

<a id="api-v1-privacy-policy-privacypolicyuri"></a>
## Endpoint : /api/v1/privacy-policy

- **Constant**: `AppConstants.privacyPolicyUri`
- **Repository**: `html_repository.dart:14` — getHtmlText
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-pro-customer-terms-and-conditions-protermsandconditionuri"></a>
## Endpoint : /api/v1/pro-customer/terms-and-conditions

- **Constant**: `AppConstants.proTermsAndConditionUri`
- **Repository**: `html_repository.dart:14` — getHtmlText
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-config-cancellation-reason-list-ridecancellationreasonlist"></a>
## Endpoint : /api/v1/rideshare/customer/config/cancellation-reason-list

- **Constant**: `AppConstants.rideCancellationReasonList`
- **Repository**: `trip_repository.dart:19` — getRideCancellationReasonList
- **Model**: `lib/features/ride_share_module/trip/domain/models/ride_cancelation_cause_list_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.ongoing_ride
- data.accepted_ride

<a id="api-v1-rideshare-customer-config-get-payment-methods-getpaymentmethods"></a>
## Endpoint : /api/v1/rideshare/customer/config/get-payment-methods

- **Constant**: `AppConstants.getPaymentMethods`
- **Repository**: `ride_payment_repository.dart:30` — getPaymentGetWayList
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-config-get-routes-remaindistance"></a>
## Endpoint : /api/v1/rideshare/customer/config/get-routes

- **Constant**: `AppConstants.remainDistance`
- **Repository**: `ride_order_repository.dart:161` — remainDistance
- **Model**: `lib/features/ride_share_module/ride_order/domain/models/remaining_distance_model.dart`
- **Parsed to model**: Yes

**Data:**

- distance_text
- duration
- duration_sec
- duration_in_traffic_sec

<a id="api-v1-rideshare-customer-config-get-zone-id-getzoneiduri"></a>
## Endpoint : /api/v1/rideshare/customer/config/get-zone-id

- **Constant**: `AppConstants.getZoneIdUri`
- **Repository**: `search_location_repository.dart:44` — getRiderZone
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-config-other-emergency-contact-list-getotheremergencynumberlist"></a>
## Endpoint : /api/v1/rideshare/customer/config/other-emergency-contact-list

- **Constant**: `AppConstants.getOtherEmergencyNumberList`
- **Repository**: `safety_alert_repository.dart:16` — getOthersEmergencyNumberList
- **Model**: `lib/features/ride_share_module/safety_alert/domain/models/other_emergency_number_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.title
- data.number

<a id="api-v1-rideshare-customer-config-safety-alert-reason-list-getsafetyalertreasonlist"></a>
## Endpoint : /api/v1/rideshare/customer/config/safety-alert-reason-list

- **Constant**: `AppConstants.getSafetyAlertReasonList`
- **Repository**: `safety_alert_repository.dart:21` — getSafetyAlertReasonList
- **Model**: `lib/features/ride_share_module/safety_alert/domain/models/safety_alert_reason_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.reason

<a id="api-v1-rideshare-customer-config-safety-precaution-list-getprecautionlist"></a>
## Endpoint : /api/v1/rideshare/customer/config/safety-precaution-list

- **Constant**: `AppConstants.getPrecautionList`
- **Repository**: `safety_alert_repository.dart:26` — getPrecautionList
- **Model**: `lib/features/ride_share_module/safety_alert/domain/models/precaution_list_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.title
- data.description

<a id="api-v1-shipping-policy-shippingpolicyuri"></a>
## Endpoint : /api/v1/shipping-policy

- **Constant**: `AppConstants.shippingPolicyUri`
- **Repository**: `html_repository.dart:14` — getHtmlText
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-terms-and-conditions-termsandconditionuri"></a>
## Endpoint : /api/v1/terms-and-conditions

- **Constant**: `AppConstants.termsAndConditionUri`
- **Repository**: `html_repository.dart:14` — getHtmlText
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-zone-check-checkzoneuri"></a>
## Endpoint : /api/v1/zone/check

- **Constant**: `AppConstants.checkZoneUri`
- **Repository**: `store_registration_repository.dart:23` — checkInZone
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-zone-list-zonelisturi"></a>
## Endpoint : /api/v1/zone/list

- **Constant**: `AppConstants.zoneListUri`
- **Repository**: `deliveryman_registration_repository.dart:36` — _getZoneList
- **Model**: `lib/features/location/domain/models/zone_data_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- formated_coordinates
- formated_coordinates.lat
- formated_coordinates.lng


---

# Rental

<a id="api-v1-rental-banners-gettaxibanneruri"></a>
## Endpoint : /api/v1/rental/banners  — `getTaxiBannerUri`

- **Constant**: `AppConstants.getTaxiBannerUri`
- **Repository**: `taxi_home_repository.dart:56`
- **Model**: `lib/features/rental_module/home/domain/models/taxi_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- banners
- banners.type
- banners.link
- banners.provider_id
- banners.image_full_url

<a id="api-v1-rental-banners-getproviderbanneruri"></a>
## Endpoint : /api/v1/rental/banners  — `getProviderBannerUri`

- **Constant**: `AppConstants.getProviderBannerUri`
- **Repository**: `taxi_vendor_repository.dart:29`
- **Model**: `lib/features/rental_module/vendor/domain/models/vendor_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- type
- link
- image_full_url

<a id="api-v1-rental-coupon-apply-taxicouponapplyuri"></a>
## Endpoint : /api/v1/rental/coupon/apply

- **Constant**: `AppConstants.taxiCouponApplyUri`
- **Repository**: `taxi_cart_repository.dart:118` — applyTaxiCoupon
- **Model**: `lib/features/rental_module/common/models/taxi_coupon_model.dart`
- **Parsed to model**: Yes

**Data:**

- code
- start_date
- expire_date
- min_purchase
- max_discount
- discount
- discount_type
- coupon_type
- data
- store_new
- store_new.id
- store_new.name

<a id="api-v1-rental-coupon-list-gettaxicouponuri"></a>
## Endpoint : /api/v1/rental/coupon/list

- **Constant**: `AppConstants.getTaxiCouponUri`
- **Repository**: `taxi_home_repository.dart:88`
- **Model**: `lib/features/rental_module/common/models/taxi_coupon_model.dart`
- **Parsed to model**: Yes

**Data:**

- code
- start_date
- expire_date
- min_purchase
- max_discount
- discount
- discount_type
- coupon_type
- data
- store_new
- store_new.id
- store_new.name

<a id="api-v1-rental-customer-trip-last-rentallasttrips"></a>
## Endpoint : /api/v1/rental/customer/trip/last

- **Constant**: `AppConstants.rentalLastTrips`
- **Repository**: `verified_provider_repository.dart:28` — getLastTrips
- **Model**: `lib/features/rental_module/home/domain/models/last_trip_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- trip_amount
- created_at
- estimated_hours
- provider
- provider.name
- provider.logo_full_url
- trip_details
- trip_details.vehicle
- trip_details.vehicle.thumbnail
- trip_details.vehicle.thumbnail_full_url

<a id="api-v1-rental-provider-get-provider-details-getproviderdetailsuri"></a>
## Endpoint : /api/v1/rental/provider/get-provider-details

- **Constant**: `AppConstants.getProviderDetailsUri`
- **Repository**: `taxi_vendor_repository.dart:19`
- **Model**: `lib/features/rental_module/vendor/domain/models/taxi_vendor_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- address
- status
- delivery_time
- announcement
- announcement_message
- avg_rating
- rating_count
- logo_full_url
- cover_photo_full_url
- discount
- discount.min_purchase
- discount.max_discount
- discount.discount
- discount.discount_type
- schedules
- schedules.day
- schedules.opening_time
- schedules.closing_time
- verified_seller

<a id="api-v1-rental-provider-get-provider-reviews-gettaxiproviderreviewuri"></a>
## Endpoint : /api/v1/rental/provider/get-provider-reviews

- **Constant**: `AppConstants.getTaxiProviderReviewUri`
- **Repository**: `taxi_vendor_repository.dart:68`
- **Model**: `lib/features/rental_module/vendor/domain/models/taxi_provider_review_model.dart`
- **Parsed to model**: Yes

**Data:**

- provider
- provider.ratings
- provider.avg_rating
- provider.rating_count
- reviews
- reviews.vehicle_id
- reviews.rating
- reviews.comment
- reviews.reply
- reviews.created_at
- reviews.updated_at
- reviews.vehicle_name
- reviews.customer_name
- reviews.vehicle_image_full_url

<a id="api-v1-rental-provider-verified-getverifiedprovidersuri"></a>
## Endpoint : /api/v1/rental/provider/verified

- **Constant**: `AppConstants.getVerifiedProvidersUri`
- **Repository**: `verified_provider_repository.dart:16`
- **Model**: `lib/features/rental_module/vendor/domain/models/verified_provider_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- stores
- stores.id
- stores.name
- stores.address
- stores.logo_full_url
- stores.cover_photo_full_url
- stores.delivery_time
- stores.distance
- stores.vehicles_count
- stores.verified_seller
- stores.ad
- stores.discount
- stores.discount.discount
- stores.discount.discount_type

<a id="api-v1-rental-user-cart-add-to-cart-addtocarcarturi"></a>
## Endpoint : /api/v1/rental/user/cart/add-to-cart

- **Constant**: `AppConstants.addToCarCartUri`
- **Repository**: `taxi_cart_repository.dart:22` — _addToCart
- **Model**: `lib/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- carts
- carts.id
- carts.provider_id
- carts.quantity
- carts.vehicle
- carts.vehicle.id
- carts.vehicle.name
- carts.vehicle.description
- carts.vehicle.provider_id
- carts.vehicle.type
- carts.vehicle.engine_capacity
- carts.vehicle.seating_capacity
- carts.vehicle.air_condition
- carts.vehicle.fuel_type
- carts.vehicle.transmission_type
- carts.vehicle.trip_hourly
- carts.vehicle.trip_distance
- carts.vehicle.trip_day_wise
- carts.vehicle.hourly_price
- carts.vehicle.distance_price
- carts.vehicle.day_wise_price
- carts.vehicle.discount_type
- carts.vehicle.discount_price
- carts.vehicle.status
- carts.vehicle.new_tag
- carts.vehicle.avg_rating
- carts.vehicle.total_reviews
- carts.vehicle.total_vehicle_count
- carts.vehicle.total_vehicles
- carts.vehicle.thumbnail_full_url
- carts.vehicle.images_full_url
- carts.vehicle.provider
- carts.vehicle.provider.id
- carts.vehicle.provider.name
- carts.vehicle.provider.rating
- carts.vehicle.provider.avg_rating
- carts.vehicle.provider.rating_count
- carts.vehicle.provider.logo_full_url
- carts.vehicle.provider.discount
- carts.vehicle.provider.verified_seller
- carts.vehicle.verified_seller
- carts.provider
- carts.provider.id
- carts.provider.name
- carts.provider.tax
- carts.provider.pickup_zone_id
- carts.provider.discount
- carts.provider.discount.min_purchase
- carts.provider.discount.max_discount
- carts.provider.discount.discount
- carts.provider.discount.discount_type
- carts.provider.verified_seller
- user_data
- user_data.id
- user_data.pickup_location
- user_data.pickup_location.lat
- user_data.pickup_location.lng
- user_data.pickup_location.location_name
- user_data.pickup_location.location_type
- user_data.destination_location
- user_data.destination_location.lat
- user_data.destination_location.lng
- user_data.destination_location.location_name
- user_data.destination_location.location_type
- user_data.pickup_time
- user_data.rental_type
- user_data.estimated_hours
- user_data.distance
- user_data.destination_time

<a id="api-v1-rental-user-cart-get-cart-getcarcartlisturi"></a>
## Endpoint : /api/v1/rental/user/cart/get-cart

- **Constant**: `AppConstants.getCarCartListUri`
- **Repository**: `taxi_cart_repository.dart:98` — _getCartList
- **Model**: `lib/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- carts
- carts.id
- carts.provider_id
- carts.quantity
- carts.vehicle
- carts.vehicle.id
- carts.vehicle.name
- carts.vehicle.description
- carts.vehicle.provider_id
- carts.vehicle.type
- carts.vehicle.engine_capacity
- carts.vehicle.seating_capacity
- carts.vehicle.air_condition
- carts.vehicle.fuel_type
- carts.vehicle.transmission_type
- carts.vehicle.trip_hourly
- carts.vehicle.trip_distance
- carts.vehicle.trip_day_wise
- carts.vehicle.hourly_price
- carts.vehicle.distance_price
- carts.vehicle.day_wise_price
- carts.vehicle.discount_type
- carts.vehicle.discount_price
- carts.vehicle.status
- carts.vehicle.new_tag
- carts.vehicle.avg_rating
- carts.vehicle.total_reviews
- carts.vehicle.total_vehicle_count
- carts.vehicle.total_vehicles
- carts.vehicle.thumbnail_full_url
- carts.vehicle.images_full_url
- carts.vehicle.provider
- carts.vehicle.provider.id
- carts.vehicle.provider.name
- carts.vehicle.provider.rating
- carts.vehicle.provider.avg_rating
- carts.vehicle.provider.rating_count
- carts.vehicle.provider.logo_full_url
- carts.vehicle.provider.discount
- carts.vehicle.provider.verified_seller
- carts.vehicle.verified_seller
- carts.provider
- carts.provider.id
- carts.provider.name
- carts.provider.tax
- carts.provider.pickup_zone_id
- carts.provider.discount
- carts.provider.discount.min_purchase
- carts.provider.discount.max_discount
- carts.provider.discount.discount
- carts.provider.discount.discount_type
- carts.provider.verified_seller
- user_data
- user_data.id
- user_data.pickup_location
- user_data.pickup_location.lat
- user_data.pickup_location.lng
- user_data.pickup_location.location_name
- user_data.pickup_location.location_type
- user_data.destination_location
- user_data.destination_location.lat
- user_data.destination_location.lng
- user_data.destination_location.location_name
- user_data.destination_location.location_type
- user_data.pickup_time
- user_data.rental_type
- user_data.estimated_hours
- user_data.distance
- user_data.destination_time

<a id="api-v1-rental-user-cart-remove-cart-removeallcarcarturi"></a>
## Endpoint : /api/v1/rental/user/cart/remove-cart

- **Constant**: `AppConstants.removeAllCarCartUri`
- **Repository**: `taxi_cart_repository.dart:61`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-cart-remove-multiple-cart-removemultiplecarcarturi"></a>
## Endpoint : /api/v1/rental/user/cart/remove-multiple-cart

- **Constant**: `AppConstants.removeMultipleCarCartUri`
- **Repository**: `taxi_cart_repository.dart:79` — clearMultipleTaxiCart
- **Model**: `lib/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- carts
- carts.id
- carts.provider_id
- carts.quantity
- carts.vehicle
- carts.vehicle.id
- carts.vehicle.name
- carts.vehicle.description
- carts.vehicle.provider_id
- carts.vehicle.type
- carts.vehicle.engine_capacity
- carts.vehicle.seating_capacity
- carts.vehicle.air_condition
- carts.vehicle.fuel_type
- carts.vehicle.transmission_type
- carts.vehicle.trip_hourly
- carts.vehicle.trip_distance
- carts.vehicle.trip_day_wise
- carts.vehicle.hourly_price
- carts.vehicle.distance_price
- carts.vehicle.day_wise_price
- carts.vehicle.discount_type
- carts.vehicle.discount_price
- carts.vehicle.status
- carts.vehicle.new_tag
- carts.vehicle.avg_rating
- carts.vehicle.total_reviews
- carts.vehicle.total_vehicle_count
- carts.vehicle.total_vehicles
- carts.vehicle.thumbnail_full_url
- carts.vehicle.images_full_url
- carts.vehicle.provider
- carts.vehicle.provider.id
- carts.vehicle.provider.name
- carts.vehicle.provider.rating
- carts.vehicle.provider.avg_rating
- carts.vehicle.provider.rating_count
- carts.vehicle.provider.logo_full_url
- carts.vehicle.provider.discount
- carts.vehicle.provider.verified_seller
- carts.vehicle.verified_seller
- carts.provider
- carts.provider.id
- carts.provider.name
- carts.provider.tax
- carts.provider.pickup_zone_id
- carts.provider.discount
- carts.provider.discount.min_purchase
- carts.provider.discount.max_discount
- carts.provider.discount.discount
- carts.provider.discount.discount_type
- carts.provider.verified_seller
- user_data
- user_data.id
- user_data.pickup_location
- user_data.pickup_location.lat
- user_data.pickup_location.lng
- user_data.pickup_location.location_name
- user_data.pickup_location.location_type
- user_data.destination_location
- user_data.destination_location.lat
- user_data.destination_location.lng
- user_data.destination_location.location_name
- user_data.destination_location.location_type
- user_data.pickup_time
- user_data.rental_type
- user_data.estimated_hours
- user_data.distance
- user_data.destination_time

<a id="api-v1-rental-user-cart-remove-vehicle-removecarcarturi"></a>
## Endpoint : /api/v1/rental/user/cart/remove-vehicle

- **Constant**: `AppConstants.removeCarCartUri`
- **Repository**: `taxi_cart_repository.dart:69` — delete
- **Model**: `lib/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- carts
- carts.id
- carts.provider_id
- carts.quantity
- carts.vehicle
- carts.vehicle.id
- carts.vehicle.name
- carts.vehicle.description
- carts.vehicle.provider_id
- carts.vehicle.type
- carts.vehicle.engine_capacity
- carts.vehicle.seating_capacity
- carts.vehicle.air_condition
- carts.vehicle.fuel_type
- carts.vehicle.transmission_type
- carts.vehicle.trip_hourly
- carts.vehicle.trip_distance
- carts.vehicle.trip_day_wise
- carts.vehicle.hourly_price
- carts.vehicle.distance_price
- carts.vehicle.day_wise_price
- carts.vehicle.discount_type
- carts.vehicle.discount_price
- carts.vehicle.status
- carts.vehicle.new_tag
- carts.vehicle.avg_rating
- carts.vehicle.total_reviews
- carts.vehicle.total_vehicle_count
- carts.vehicle.total_vehicles
- carts.vehicle.thumbnail_full_url
- carts.vehicle.images_full_url
- carts.vehicle.provider
- carts.vehicle.provider.id
- carts.vehicle.provider.name
- carts.vehicle.provider.rating
- carts.vehicle.provider.avg_rating
- carts.vehicle.provider.rating_count
- carts.vehicle.provider.logo_full_url
- carts.vehicle.provider.discount
- carts.vehicle.provider.verified_seller
- carts.vehicle.verified_seller
- carts.provider
- carts.provider.id
- carts.provider.name
- carts.provider.tax
- carts.provider.pickup_zone_id
- carts.provider.discount
- carts.provider.discount.min_purchase
- carts.provider.discount.max_discount
- carts.provider.discount.discount
- carts.provider.discount.discount_type
- carts.provider.verified_seller
- user_data
- user_data.id
- user_data.pickup_location
- user_data.pickup_location.lat
- user_data.pickup_location.lng
- user_data.pickup_location.location_name
- user_data.pickup_location.location_type
- user_data.destination_location
- user_data.destination_location.lat
- user_data.destination_location.lng
- user_data.destination_location.location_name
- user_data.destination_location.location_type
- user_data.pickup_time
- user_data.rental_type
- user_data.estimated_hours
- user_data.distance
- user_data.destination_time

<a id="api-v1-rental-user-cart-update-cart-updatecarcarturi"></a>
## Endpoint : /api/v1/rental/user/cart/update-cart

- **Constant**: `AppConstants.updateCarCartUri`
- **Repository**: `taxi_cart_repository.dart:108` — update
- **Model**: `lib/features/rental_module/rental_cart_screen/domain/models/car_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- carts
- carts.id
- carts.provider_id
- carts.quantity
- carts.vehicle
- carts.vehicle.id
- carts.vehicle.name
- carts.vehicle.description
- carts.vehicle.provider_id
- carts.vehicle.type
- carts.vehicle.engine_capacity
- carts.vehicle.seating_capacity
- carts.vehicle.air_condition
- carts.vehicle.fuel_type
- carts.vehicle.transmission_type
- carts.vehicle.trip_hourly
- carts.vehicle.trip_distance
- carts.vehicle.trip_day_wise
- carts.vehicle.hourly_price
- carts.vehicle.distance_price
- carts.vehicle.day_wise_price
- carts.vehicle.discount_type
- carts.vehicle.discount_price
- carts.vehicle.status
- carts.vehicle.new_tag
- carts.vehicle.avg_rating
- carts.vehicle.total_reviews
- carts.vehicle.total_vehicle_count
- carts.vehicle.total_vehicles
- carts.vehicle.thumbnail_full_url
- carts.vehicle.images_full_url
- carts.vehicle.provider
- carts.vehicle.provider.id
- carts.vehicle.provider.name
- carts.vehicle.provider.rating
- carts.vehicle.provider.avg_rating
- carts.vehicle.provider.rating_count
- carts.vehicle.provider.logo_full_url
- carts.vehicle.provider.discount
- carts.vehicle.provider.verified_seller
- carts.vehicle.verified_seller
- carts.provider
- carts.provider.id
- carts.provider.name
- carts.provider.tax
- carts.provider.pickup_zone_id
- carts.provider.discount
- carts.provider.discount.min_purchase
- carts.provider.discount.max_discount
- carts.provider.discount.discount
- carts.provider.discount.discount_type
- carts.provider.verified_seller
- user_data
- user_data.id
- user_data.pickup_location
- user_data.pickup_location.lat
- user_data.pickup_location.lng
- user_data.pickup_location.location_name
- user_data.pickup_location.location_type
- user_data.destination_location
- user_data.destination_location.lat
- user_data.destination_location.lng
- user_data.destination_location.location_name
- user_data.destination_location.location_type
- user_data.pickup_time
- user_data.rental_type
- user_data.estimated_hours
- user_data.distance
- user_data.destination_time

<a id="api-v1-rental-user-cart-update-user-data-tripupdateuserdatauri"></a>
## Endpoint : /api/v1/rental/user/cart/update-user-data

- **Constant**: `AppConstants.tripUpdateUserDataUri`
- **Repository**: `taxi_cart_repository.dart:55`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-review-add-addtaxireviewuri"></a>
## Endpoint : /api/v1/rental/user/review/add

- **Constant**: `AppConstants.addTaxiReviewUri`
- **Repository**: `taxi_order_repository.dart:99`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-trip-cancel-trip-tripcanceluri"></a>
## Endpoint : /api/v1/rental/user/trip/cancel-trip

- **Constant**: `AppConstants.tripCancelUri`
- **Repository**: `taxi_order_repository.dart:23` — delete
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-trip-delete-trip-tripdeleteuri"></a>
## Endpoint : /api/v1/rental/user/trip/delete-trip

- **Constant**: `AppConstants.tripDeleteUri`
- **Repository**: `taxi_order_repository.dart:29`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-trip-get-tax-gettriptaxuri"></a>
## Endpoint : /api/v1/rental/user/trip/get-tax

- **Constant**: `AppConstants.getTripTaxUri`
- **Repository**: `taxi_cart_repository.dart:137`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-trip-get-trip-details-tripdetailsuri"></a>
## Endpoint : /api/v1/rental/user/trip/get-trip-details

- **Constant**: `AppConstants.tripDetailsUri`
- **Repository**: `taxi_order_repository.dart:54`
- **Model**: `lib/features/rental_module/common/models/trip_details_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- trip_amount
- discount_on_trip
- coupon_discount_amount
- pro_discount
- trip_status
- payment_status
- tax_amount
- tax_status
- tax_percentage
- trip_type
- additional_charge
- distance
- estimated_hours
- pickup_location
- pickup_location.lat
- pickup_location.lng
- pickup_location.location_name
- pickup_location.location_type
- destination_location
- destination_location.lat
- destination_location.lng
- destination_location.location_name
- destination_location.location_type
- trip_note
- schedule_at
- quantity
- estimated_trip_end_time
- created_at
- updated_at
- trip_details
- trip_details.quantity
- trip_details.vehicle_details
- trip_details.vehicle_details.name
- trip_details.vehicle_details.hourly_price
- trip_details.vehicle_details.distance_price
- trip_details.vehicle_details.thumbnail_full_url
- trip_details.calculated_price
- trip_details.license_plate_number
- vehicle_identity
- vehicle_identity.trip_id
- vehicle_identity.vehicle_id
- vehicle_identity.vehicle_identity_id
- vehicle_identity.license_plate_number
- vehicle_identity.vehicle_name
- vehicle_identity.vehicle_thumbnail
- vehicle_identity.rating
- vehicle_identity.driver_data
- vehicle_identity.driver_data.id
- vehicle_identity.driver_data.first_name
- vehicle_identity.driver_data.last_name
- vehicle_identity.driver_data.phone
- vehicle_identity.driver_data.image_full_url
- provider
- provider.id
- provider.name
- provider.phone
- provider.avg_rating
- provider.rating_count
- provider.chat
- provider.reviews_section
- provider.logo_full_url
- provider.verified_seller

<a id="api-v1-rental-user-trip-get-trip-list-triplisturi"></a>
## Endpoint : /api/v1/rental/user/trip/get-trip-list

- **Constant**: `AppConstants.tripListUri`
- **Repository**: `taxi_order_repository.dart:43`
- **Model**: `lib/features/rental_module/common/models/trip_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- trips
- trips.id
- trips.trip_amount
- trips.discount_on_trip
- trips.coupon_discount_amount
- trips.pro_discount
- trips.trip_status
- trips.payment_status
- trips.tax_amount
- trips.tax_status
- trips.tax_percentage
- trips.trip_type
- trips.additional_charge
- trips.distance
- trips.estimated_hours
- trips.pickup_location
- trips.pickup_location.lat
- trips.pickup_location.lng
- trips.pickup_location.location_name
- trips.pickup_location.location_type
- trips.destination_location
- trips.destination_location.lat
- trips.destination_location.lng
- trips.destination_location.location_name
- trips.destination_location.location_type
- trips.trip_note
- trips.schedule_at
- trips.quantity
- trips.estimated_trip_end_time
- trips.created_at
- trips.updated_at
- trips.trip_details
- trips.trip_details.quantity
- trips.trip_details.vehicle_details
- trips.trip_details.vehicle_details.name
- trips.trip_details.vehicle_details.hourly_price
- trips.trip_details.vehicle_details.distance_price
- trips.trip_details.vehicle_details.thumbnail_full_url
- trips.trip_details.calculated_price
- trips.trip_details.license_plate_number
- trips.vehicle_identity
- trips.vehicle_identity.trip_id
- trips.vehicle_identity.vehicle_id
- trips.vehicle_identity.vehicle_identity_id
- trips.vehicle_identity.license_plate_number
- trips.vehicle_identity.vehicle_name
- trips.vehicle_identity.vehicle_thumbnail
- trips.vehicle_identity.rating
- trips.vehicle_identity.driver_data
- trips.vehicle_identity.driver_data.id
- trips.vehicle_identity.driver_data.first_name
- trips.vehicle_identity.driver_data.last_name
- trips.vehicle_identity.driver_data.phone
- trips.vehicle_identity.driver_data.image_full_url
- trips.provider
- trips.provider.id
- trips.provider.name
- trips.provider.phone
- trips.provider.avg_rating
- trips.provider.rating_count
- trips.provider.chat
- trips.provider.reviews_section
- trips.provider.logo_full_url
- trips.provider.verified_seller

<a id="api-v1-rental-user-trip-payment-trippaymenturi"></a>
## Endpoint : /api/v1/rental/user/trip/payment

- **Constant**: `AppConstants.tripPaymentUri`
- **Repository**: `taxi_order_repository.dart:75`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-trip-reorder-rentalreorder"></a>
## Endpoint : /api/v1/rental/user/trip/reorder

- **Constant**: `AppConstants.rentalReOrder`
- **Repository**: `verified_provider_repository.dart:67`
- **Model**: `lib/features/order/domain/models/reorder_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- added_count
- unavailable_items
- unavailable_items.name
- unavailable_items.message

<a id="api-v1-rental-user-trip-trip-booking-tripbookinguri"></a>
## Endpoint : /api/v1/rental/user/trip/trip-booking

- **Constant**: `AppConstants.tripBookingUri`
- **Repository**: `taxi_cart_repository.dart:49`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-wish-list-gettaxiwishlisturi"></a>
## Endpoint : /api/v1/rental/user/wish-list

- **Constant**: `AppConstants.getTaxiWishListUri`
- **Repository**: `taxi_favourite_repository.dart:40`
- **Model**: `lib/features/rental_module/home/domain/models/vehicle_details_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- description
- provider_id
- type
- engine_capacity
- seating_capacity
- air_condition
- fuel_type
- transmission_type
- trip_hourly
- trip_distance
- trip_day_wise
- hourly_price
- distance_price
- day_wise_price
- discount_type
- discount_price
- status
- new_tag
- avg_rating
- total_reviews
- total_vehicle_count
- total_vehicles
- thumbnail_full_url
- images_full_url
- provider
- provider.id
- provider.name
- provider.rating
- provider.avg_rating
- provider.rating_count
- provider.logo_full_url
- provider.discount
- provider.discount.max_discount
- provider.discount.discount
- provider.discount.discount_type
- provider.verified_seller
- verified_seller

<a id="api-v1-rental-user-wish-list-add-addtaxiwishlisturi"></a>
## Endpoint : /api/v1/rental/user/wish-list/add

- **Constant**: `AppConstants.addTaxiWishListUri`
- **Repository**: `taxi_favourite_repository.dart:17` — addVehicleFavouriteList
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-user-wish-list-remove-removetaxiwishlisturi"></a>
## Endpoint : /api/v1/rental/user/wish-list/remove

- **Constant**: `AppConstants.removeTaxiWishListUri`
- **Repository**: `taxi_favourite_repository.dart:29`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-vehicle-brand-list-gettaxibrandlisturi"></a>
## Endpoint : /api/v1/rental/vehicle/brand-list

- **Constant**: `AppConstants.getTaxiBrandListUri`
- **Repository**: `taxi_home_repository.dart:173` — getTaxiBrandList
- **Model**: `lib/features/rental_module/common/models/taxi_brand_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- brands
- brands.id
- brands.name
- brands.image_full_url

<a id="api-v1-rental-vehicle-category-list-getprovidervehiclecategorylisturi"></a>
## Endpoint : /api/v1/rental/vehicle/category-list  — `getProviderVehicleCategoryListUri`

- **Constant**: `AppConstants.getProviderVehicleCategoryListUri`
- **Repository**: `taxi_vendor_repository.dart:58` — getVendorVehicleCategoryList
- **Model**: `lib/features/rental_module/vendor/domain/models/vendor_vehicle_category_model.dart`
- **Parsed to model**: Yes

**Data:**

- vehicles
- vehicles.id
- vehicles.name

<a id="api-v1-rental-vehicle-category-list-getvehiclecategoriesuri"></a>
## Endpoint : /api/v1/rental/vehicle/category-list  — `getVehicleCategoriesUri`

- **Constant**: `AppConstants.getVehicleCategoriesUri`
- **Repository**: `taxi_home_repository.dart:162`
- **Model**: `lib/features/rental_module/home/domain/models/vehicle_category_model.dart`
- **Parsed to model**: Yes

**Data:**

- vehicles
- vehicles.id
- vehicles.name
- vehicles.image_full_url

<a id="api-v1-rental-vehicle-get-provider-vehicles-getprovidervehiclelisturi"></a>
## Endpoint : /api/v1/rental/vehicle/get-provider-vehicles

- **Constant**: `AppConstants.getProviderVehicleListUri`
- **Repository**: `taxi_vendor_repository.dart:46`
- **Model**: `lib/features/rental_module/vendor/domain/models/vendor_vehicles_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- max_price
- min_price
- vehicles
- vehicles.id
- vehicles.name
- vehicles.description
- vehicles.provider_id
- vehicles.type
- vehicles.engine_capacity
- vehicles.seating_capacity
- vehicles.air_condition
- vehicles.fuel_type
- vehicles.transmission_type
- vehicles.trip_hourly
- vehicles.trip_distance
- vehicles.trip_day_wise
- vehicles.hourly_price
- vehicles.distance_price
- vehicles.day_wise_price
- vehicles.discount_type
- vehicles.discount_price
- vehicles.status
- vehicles.new_tag
- vehicles.avg_rating
- vehicles.total_reviews
- vehicles.total_vehicle_count
- vehicles.total_vehicles
- vehicles.thumbnail_full_url
- vehicles.images_full_url
- vehicles.provider
- vehicles.provider.id
- vehicles.provider.name
- vehicles.provider.rating
- vehicles.provider.avg_rating
- vehicles.provider.rating_count
- vehicles.provider.logo_full_url
- vehicles.provider.discount
- vehicles.provider.discount.max_discount
- vehicles.provider.discount.discount
- vehicles.provider.discount.discount_type
- vehicles.provider.verified_seller
- vehicles.verified_seller

<a id="api-v1-rental-vehicle-get-vehicle-details-getvehicledetailsuri"></a>
## Endpoint : /api/v1/rental/vehicle/get-vehicle-details

- **Constant**: `AppConstants.getVehicleDetailsUri`
- **Repository**: `taxi_home_repository.dart:115`
- **Model**: `lib/features/rental_module/home/domain/models/vehicle_details_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- description
- provider_id
- type
- engine_capacity
- seating_capacity
- air_condition
- fuel_type
- transmission_type
- trip_hourly
- trip_distance
- trip_day_wise
- hourly_price
- distance_price
- day_wise_price
- discount_type
- discount_price
- status
- new_tag
- avg_rating
- total_reviews
- total_vehicle_count
- total_vehicles
- thumbnail_full_url
- images_full_url
- provider
- provider.id
- provider.name
- provider.rating
- provider.avg_rating
- provider.rating_count
- provider.logo_full_url
- provider.discount
- provider.discount.max_discount
- provider.discount.discount
- provider.discount.discount_type
- provider.verified_seller
- verified_seller

<a id="api-v1-rental-vehicle-popular-suggestion-getpopulartaxisuggestionuri"></a>
## Endpoint : /api/v1/rental/vehicle/popular-suggestion/

- **Constant**: `AppConstants.getPopularTaxiSuggestionUri`
- **Repository**: `taxi_home_repository.dart:184` — getPopularSearchList
- **Model**: `lib/features/rental_module/home/domain/models/popular_car_suggestion_model.dart`
- **Parsed to model**: Yes

**Data:**

- name

<a id="api-v1-rental-vehicle-search-getselectvehiclesuri"></a>
## Endpoint : /api/v1/rental/vehicle/search/

- **Constant**: `AppConstants.getSelectVehiclesUri`
- **Repository**: `taxi_home_repository.dart:133`
- **Model**: `lib/features/rental_module/home/domain/models/selected_cars_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- max_price
- min_price
- vehicles
- vehicles.id
- vehicles.name
- vehicles.description
- vehicles.provider_id
- vehicles.type
- vehicles.engine_capacity
- vehicles.seating_capacity
- vehicles.air_condition
- vehicles.fuel_type
- vehicles.transmission_type
- vehicles.trip_hourly
- vehicles.trip_distance
- vehicles.trip_day_wise
- vehicles.hourly_price
- vehicles.distance_price
- vehicles.day_wise_price
- vehicles.discount_type
- vehicles.discount_price
- vehicles.status
- vehicles.new_tag
- vehicles.avg_rating
- vehicles.total_reviews
- vehicles.total_vehicle_count
- vehicles.total_vehicles
- vehicles.thumbnail_full_url
- vehicles.images_full_url
- vehicles.provider
- vehicles.provider.id
- vehicles.provider.name
- vehicles.provider.rating
- vehicles.provider.avg_rating
- vehicles.provider.rating_count
- vehicles.provider.logo_full_url
- vehicles.provider.discount
- vehicles.provider.discount.max_discount
- vehicles.provider.discount.discount
- vehicles.provider.discount.discount_type
- vehicles.provider.verified_seller
- vehicles.verified_seller

<a id="api-v1-rental-vehicle-search-suggestion-getsearchvehiclesuggestionuri"></a>
## Endpoint : /api/v1/rental/vehicle/search/suggestion

- **Constant**: `AppConstants.getSearchVehicleSuggestionUri`
- **Repository**: `taxi_home_repository.dart:147`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rental-vehicle-top-rated-gettopratedcarsuri"></a>
## Endpoint : /api/v1/rental/vehicle/top-rated

- **Constant**: `AppConstants.getTopRatedCarsUri`
- **Repository**: `taxi_home_repository.dart:31`
- **Model**: `lib/features/rental_module/home/domain/models/top_rated_cars_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- vehicles
- vehicles.id
- vehicles.name
- vehicles.description
- vehicles.provider_id
- vehicles.type
- vehicles.engine_capacity
- vehicles.seating_capacity
- vehicles.air_condition
- vehicles.fuel_type
- vehicles.transmission_type
- vehicles.trip_hourly
- vehicles.trip_distance
- vehicles.trip_day_wise
- vehicles.hourly_price
- vehicles.distance_price
- vehicles.day_wise_price
- vehicles.discount_type
- vehicles.discount_price
- vehicles.status
- vehicles.new_tag
- vehicles.avg_rating
- vehicles.total_reviews
- vehicles.total_vehicle_count
- vehicles.total_vehicles
- vehicles.thumbnail_full_url
- vehicles.images_full_url
- vehicles.provider
- vehicles.provider.id
- vehicles.provider.name
- vehicles.provider.rating
- vehicles.provider.avg_rating
- vehicles.provider.rating_count
- vehicles.provider.logo_full_url
- vehicles.provider.discount
- vehicles.provider.discount.max_discount
- vehicles.provider.discount.discount
- vehicles.provider.discount.discount_type
- vehicles.provider.verified_seller
- vehicles.verified_seller


---

# Ride-share

<a id="api-v1-rideshare-customer-banner-list-getridesharebanneruri"></a>
## Endpoint : /api/v1/rideshare/customer/banner/list

- **Constant**: `AppConstants.getRideShareBannerUri`
- **Repository**: `rideHome_repository.dart:49` — getBannerList
- **Model**: `lib/features/ride_share_module/ride_home/domain/models/ride_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.redirect_link
- data.image

<a id="api-v1-rideshare-customer-banner-update-redirection-count-bannercountupdate"></a>
## Endpoint : /api/v1/rideshare/customer/banner/update-redirection-count

- **Constant**: `AppConstants.bannerCountUpdate`
- **Repository**: `rideHome_repository.dart:92` — updateBannerClickCount
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-coupon-apply-getridesharecouponapplyuri"></a>
## Endpoint : /api/v1/rideshare/customer/coupon/apply

- **Constant**: `AppConstants.getRideShareCouponApplyUri`
- **Repository**: `rideHome_repository.dart:79` — customerAppliedCoupon
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-coupon-list-getridesharecouponuri"></a>
## Endpoint : /api/v1/rideshare/customer/coupon/list

- **Constant**: `AppConstants.getRideShareCouponUri`
- **Repository**: `rideHome_repository.dart:70`
- **Model**: `lib/features/ride_share_module/ride_home/domain/models/ride_coupon_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- data
- data.id
- data.name
- data.description
- data.min_trip_amount
- data.max_coupon_amount
- data.coupon
- data.amount_type
- data.coupon_type
- data.coupon_code
- data.end_date
- data.is_applied
- data.category_coupon_image

<a id="api-v1-rideshare-customer-discount-list-limit-10-offset-bestofferlist"></a>
## Endpoint : /api/v1/rideshare/customer/discount/list?limit=10&offset=

- **Constant**: `AppConstants.bestOfferList`
- **Repository**: `rideHome_repository.dart:87` — getOfferList
- **Model**: `lib/features/ride_share_module/offer/domain/models/best_offer_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- data
- data.title
- data.short_description
- data.terms_conditions
- data.image
- data.discount_amount
- data.zone_discount
- data.customer_level_discount
- data.module_discount
- data.discount_amount_type
- data.max_discount_amount
- data.min_trip_amount
- data.limit
- data.end_date

<a id="api-v1-rideshare-customer-drivers-near-me-nearestdriverlist"></a>
## Endpoint : /api/v1/rideshare/customer/drivers-near-me

- **Constant**: `AppConstants.nearestDriverList`
- **Repository**: `ride_order_repository.dart:171` — nearestDriverList
- **Model**: `lib/features/ride_share_module/ride_order/domain/models/nearest_driver_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.latitude
- data.longitude
- data.category

<a id="api-v1-rideshare-customer-review-store-submitreview"></a>
## Endpoint : /api/v1/rideshare/customer/review/store

- **Constant**: `AppConstants.submitReview`
- **Repository**: `trip_repository.dart:24` — submitReview
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-arrival-time-arrivalpickuppoint"></a>
## Endpoint : /api/v1/rideshare/customer/ride/arrival-time

- **Constant**: `AppConstants.arrivalPickupPoint`
- **Repository**: `ride_order_repository.dart:204` — getDriverLocation
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-bidding-list-biddinglist"></a>
## Endpoint : /api/v1/rideshare/customer/ride/bidding-list/

- **Constant**: `AppConstants.biddingList`
- **Repository**: `ride_order_repository.dart:166` — biddingList
- **Model**: `lib/features/ride_share_module/ride_order/domain/models/bidding_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.ride_requests_id
- data.ride_request
- data.ride_request.estimated_distance
- data.driver
- data.driver.id
- data.driver.first_name
- data.driver.last_name
- data.driver.phone
- data.driver.rating
- data.driver.total_review
- data.driver.profile_image
- data.driver.vehicle
- data.driver.vehicle.model
- data.driver.vehicle.licence_plate_number
- data.bid_fare
- data.driver_avg_rating

<a id="api-v1-rideshare-customer-ride-create-riderequest"></a>
## Endpoint : /api/v1/rideshare/customer/ride/create

- **Constant**: `AppConstants.rideRequest`
- **Repository**: `ride_order_repository.dart:102`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-delete-ridedeleteuri"></a>
## Endpoint : /api/v1/rideshare/customer/ride/delete

- **Constant**: `AppConstants.rideDeleteUri`
- **Repository**: `ride_order_repository.dart:253` — deleteRide
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-details-tripdetails"></a>
## Endpoint : /api/v1/rideshare/customer/ride/details/

- **Constant**: `AppConstants.tripDetails`
- **Repository**: `ride_order_repository.dart:146` — getRideDetails
- **Model**: `lib/features/ride_share_module/ride_location/domain/models/ride_details_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.ref_id
- data.driver
- data.driver.id
- data.driver.first_name
- data.driver.last_name
- data.driver.phone
- data.driver.rating
- data.driver.total_review
- data.driver.profile_image
- data.driver.vehicle
- data.driver.vehicle.model
- data.driver.vehicle.licence_plate_number
- data.vehicle
- data.vehicle.model
- data.vehicle.model.name
- data.vehicle.model.image
- data.vehicle.licence_plate_number
- data.vehicle_category
- data.vehicle_category.name
- data.vehicle_category.image
- data.vehicle_category.type
- data.estimated_fare
- data.estimated_time
- data.estimated_distance
- data.actual_fare
- data.discount_actual_fare
- data.actual_time
- data.actual_distance
- data.idle_fee
- data.delay_fee
- data.cancellation_fee
- data.distance_wise_fare
- data.vat_tax
- data.tips
- data.pickup_coordinates
- data.pickup_coordinates.coordinates
- data.pickup_address
- data.destination_address
- data.payment_method
- data.coupon
- data.coupon_amount
- data.discount_amount
- data.pro_discount
- data.note
- data.otp
- data.type
- data.created_at
- data.entrance
- data.intermediate_addresses
- data.encoded_polyline
- data.driver_avg_rating
- data.driver_rating_count
- data.current_status
- data.paid_fare
- data.is_paused
- data.payment_status
- data.driver_review
- data.ride_complete_time
- data.ride_start_time
- data.customer_safety_alert
- data.intermediate_coordinates
- data.ride_cancellation_reason
- data.tripStatus
- data.tripStatus.ongoing

<a id="api-v1-rideshare-customer-ride-digital-payment-digitalpayment"></a>
## Endpoint : /api/v1/rideshare/customer/ride/digital-payment

- **Constant**: `AppConstants.digitalPayment`
- **Repository**: `digital_payment_screen.dart:37`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-final-fare-finalfare"></a>
## Endpoint : /api/v1/rideshare/customer/ride/final-fare

- **Constant**: `AppConstants.finalFare`
- **Repository**: `ride_order_repository.dart:198` — getFinalFare
- **Model**: `lib/features/ride_share_module/ride_order/domain/models/final_fare_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.paid_fare
- data.coupon_amount
- data.discount_amount
- data.pro_discount
- data.current_status
- data.coupon
- data.coupon.coupon_type
- data.discount
- data.discount.discount_amount
- data.discount.discount_amount_type
- data.distance_wise_fare
- data.idle_fee
- data.delay_fee
- data.cancellation_fee
- data.vat_tax

<a id="api-v1-rideshare-customer-ride-get-estimated-fare-estimatedfare"></a>
## Endpoint : /api/v1/rideshare/customer/ride/get-estimated-fare

- **Constant**: `AppConstants.estimatedFare`
- **Repository**: `ride_order_repository.dart:34` — LatLng
- **Model**: `lib/features/ride_share_module/ride_order/domain/models/estimated_fare_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.zone_id
- data.vehicle_category_id
- data.estimated_distance
- data.estimated_duration
- data.estimated_fare
- data.encoded_polyline
- data.area_id
- data.discount_amount
- data.coupon_applicable
- data.discount_fare
- data.extra_estimated_fare
- data.extra_discount_fare
- data.extra_discount_amount
- data.extra_return_fee
- data.extra_cancellation_fee
- data.extra_fare_amount
- data.extra_fare_fee

<a id="api-v1-rideshare-customer-ride-ignore-bidding-ignorebidding"></a>
## Endpoint : /api/v1/rideshare/customer/ride/ignore-bidding

- **Constant**: `AppConstants.ignoreBidding`
- **Repository**: `ride_order_repository.dart:185` — ignoreBidding
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-list-triplist"></a>
## Endpoint : /api/v1/rideshare/customer/ride/list

- **Constant**: `AppConstants.tripList`
- **Repository**: `trip_repository.dart:14` — getTripList
- **Model**: `lib/features/ride_share_module/trip/domain/models/ride_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- data
- data.id
- data.ref_id
- data.driver
- data.driver.id
- data.driver.first_name
- data.driver.last_name
- data.driver.phone
- data.driver.rating
- data.driver.total_review
- data.driver.profile_image
- data.driver.vehicle
- data.driver.vehicle.model
- data.driver.vehicle.licence_plate_number
- data.vehicle
- data.vehicle.model
- data.vehicle.model.name
- data.vehicle.model.image
- data.vehicle.licence_plate_number
- data.vehicle_category
- data.vehicle_category.name
- data.vehicle_category.image
- data.vehicle_category.type
- data.estimated_fare
- data.estimated_time
- data.estimated_distance
- data.actual_fare
- data.discount_actual_fare
- data.actual_time
- data.actual_distance
- data.idle_fee
- data.delay_fee
- data.cancellation_fee
- data.distance_wise_fare
- data.vat_tax
- data.tips
- data.pickup_coordinates
- data.pickup_coordinates.coordinates
- data.pickup_address
- data.destination_address
- data.payment_method
- data.coupon
- data.coupon_amount
- data.discount_amount
- data.pro_discount
- data.note
- data.otp
- data.type
- data.created_at
- data.entrance
- data.intermediate_addresses
- data.encoded_polyline
- data.driver_avg_rating
- data.driver_rating_count
- data.current_status
- data.paid_fare
- data.is_paused
- data.payment_status
- data.driver_review
- data.ride_complete_time
- data.ride_start_time
- data.customer_safety_alert
- data.intermediate_coordinates
- data.ride_cancellation_reason
- data.tripStatus
- data.tripStatus.ongoing

<a id="api-v1-rideshare-customer-ride-list-history-gethistoryridelisturi"></a>
## Endpoint : /api/v1/rideshare/customer/ride/list-history

- **Constant**: `AppConstants.getHistoryRideListUri`
- **Repository**: `ride_order_repository.dart:245` — getRideList
- **Model**: `lib/features/ride_share_module/ride_order/domain/models/ride_list_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- data
- data.id
- data.ref_id
- data.driver
- data.driver.id
- data.driver.first_name
- data.driver.last_name
- data.driver.phone
- data.driver.rating
- data.driver.total_review
- data.driver.profile_image
- data.driver.vehicle
- data.driver.vehicle.model
- data.driver.vehicle.licence_plate_number
- data.vehicle
- data.vehicle.model
- data.vehicle.model.name
- data.vehicle.model.image
- data.vehicle.licence_plate_number
- data.vehicle_category
- data.vehicle_category.name
- data.vehicle_category.image
- data.vehicle_category.type
- data.estimated_fare
- data.estimated_time
- data.estimated_distance
- data.actual_fare
- data.discount_actual_fare
- data.actual_time
- data.actual_distance
- data.idle_fee
- data.delay_fee
- data.cancellation_fee
- data.distance_wise_fare
- data.vat_tax
- data.tips
- data.pickup_coordinates
- data.pickup_coordinates.coordinates
- data.pickup_address
- data.destination_address
- data.payment_method
- data.coupon
- data.coupon_amount
- data.discount_amount
- data.pro_discount
- data.note
- data.otp
- data.type
- data.created_at
- data.entrance
- data.intermediate_addresses
- data.encoded_polyline
- data.driver_avg_rating
- data.driver_rating_count
- data.current_status
- data.paid_fare
- data.is_paused
- data.payment_status
- data.driver_review
- data.ride_complete_time
- data.ride_start_time
- data.customer_safety_alert
- data.intermediate_coordinates
- data.ride_cancellation_reason
- data.tripStatus
- data.tripStatus.ongoing

<a id="api-v1-rideshare-customer-ride-list-running-getrunningridelisturi"></a>
## Endpoint : /api/v1/rideshare/customer/ride/list-running

- **Constant**: `AppConstants.getRunningRideListUri`
- **Repository**: `ride_order_repository.dart:243` — getRideList
- **Model**: `lib/features/ride_share_module/ride_order/domain/models/ride_list_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- data
- data.id
- data.ref_id
- data.driver
- data.driver.id
- data.driver.first_name
- data.driver.last_name
- data.driver.phone
- data.driver.rating
- data.driver.total_review
- data.driver.profile_image
- data.driver.vehicle
- data.driver.vehicle.model
- data.driver.vehicle.licence_plate_number
- data.vehicle
- data.vehicle.model
- data.vehicle.model.name
- data.vehicle.model.image
- data.vehicle.licence_plate_number
- data.vehicle_category
- data.vehicle_category.name
- data.vehicle_category.image
- data.vehicle_category.type
- data.estimated_fare
- data.estimated_time
- data.estimated_distance
- data.actual_fare
- data.discount_actual_fare
- data.actual_time
- data.actual_distance
- data.idle_fee
- data.delay_fee
- data.cancellation_fee
- data.distance_wise_fare
- data.vat_tax
- data.tips
- data.pickup_coordinates
- data.pickup_coordinates.coordinates
- data.pickup_address
- data.destination_address
- data.payment_method
- data.coupon
- data.coupon_amount
- data.discount_amount
- data.pro_discount
- data.note
- data.otp
- data.type
- data.created_at
- data.entrance
- data.intermediate_addresses
- data.encoded_polyline
- data.driver_avg_rating
- data.driver_rating_count
- data.current_status
- data.paid_fare
- data.is_paused
- data.payment_status
- data.driver_review
- data.ride_complete_time
- data.ride_start_time
- data.customer_safety_alert
- data.intermediate_coordinates
- data.ride_cancellation_reason
- data.tripStatus
- data.tripStatus.ongoing

<a id="api-v1-rideshare-customer-ride-payment-paymenturi"></a>
## Endpoint : /api/v1/rideshare/customer/ride/payment

- **Constant**: `AppConstants.paymentUri`
- **Repository**: `ride_payment_repository.dart:26` — paymentSubmit
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-pending-ride-list-getrunningridelist"></a>
## Endpoint : /api/v1/rideshare/customer/ride/pending-ride-list

- **Constant**: `AppConstants.getRunningRideList`
- **Repository**: `ride_order_repository.dart:209` — getRunningRideList
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-received-returning-parcel-parcelreceived"></a>
## Endpoint : /api/v1/rideshare/customer/ride/received-returning-parcel/

- **Constant**: `AppConstants.parcelReceived`
- **Repository**: `ride_order_repository.dart:221` — parcelReceived
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-ride-resume-status-currentridestatus"></a>
## Endpoint : /api/v1/rideshare/customer/ride/ride-resume-status

- **Constant**: `AppConstants.currentRideStatus`
- **Repository**: `ride_order_repository.dart:141` — currentRideStatus
- **Model**: `lib/features/ride_share_module/ride_location/domain/models/ride_details_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.ref_id
- data.driver
- data.driver.id
- data.driver.first_name
- data.driver.last_name
- data.driver.phone
- data.driver.rating
- data.driver.total_review
- data.driver.profile_image
- data.driver.vehicle
- data.driver.vehicle.model
- data.driver.vehicle.licence_plate_number
- data.vehicle
- data.vehicle.model
- data.vehicle.model.name
- data.vehicle.model.image
- data.vehicle.licence_plate_number
- data.vehicle_category
- data.vehicle_category.name
- data.vehicle_category.image
- data.vehicle_category.type
- data.estimated_fare
- data.estimated_time
- data.estimated_distance
- data.actual_fare
- data.discount_actual_fare
- data.actual_time
- data.actual_distance
- data.idle_fee
- data.delay_fee
- data.cancellation_fee
- data.distance_wise_fare
- data.vat_tax
- data.tips
- data.pickup_coordinates
- data.pickup_coordinates.coordinates
- data.pickup_address
- data.destination_address
- data.payment_method
- data.coupon
- data.coupon_amount
- data.discount_amount
- data.pro_discount
- data.note
- data.otp
- data.type
- data.created_at
- data.entrance
- data.intermediate_addresses
- data.encoded_polyline
- data.driver_avg_rating
- data.driver_rating_count
- data.current_status
- data.paid_fare
- data.is_paused
- data.payment_status
- data.driver_review
- data.ride_complete_time
- data.ride_start_time
- data.customer_safety_alert
- data.intermediate_coordinates
- data.ride_cancellation_reason
- data.tripStatus
- data.tripStatus.ongoing

<a id="api-v1-rideshare-customer-ride-trip-action-tripacceptorreject"></a>
## Endpoint : /api/v1/rideshare/customer/ride/trip-action

- **Constant**: `AppConstants.tripAcceptOrReject`
- **Repository**: `ride_order_repository.dart:176` — tripAcceptOrReject
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-ride-update-status-updatetripstatus"></a>
## Endpoint : /api/v1/rideshare/customer/ride/update-status/

- **Constant**: `AppConstants.updateTripStatus`
- **Repository**: `ride_order_repository.dart:151` — tripStatusUpdate
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-safety-alert-mark-as-solved-markassolvedsafetyalert"></a>
## Endpoint : /api/v1/rideshare/customer/safety-alert/mark-as-solved/

- **Constant**: `AppConstants.markAsSolvedSafetyAlert`
- **Repository**: `safety_alert_repository.dart:46` — marAsSolveSafetyAlert
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-safety-alert-resend-resendsafetyalert"></a>
## Endpoint : /api/v1/rideshare/customer/safety-alert/resend/

- **Constant**: `AppConstants.resendSafetyAlert`
- **Repository**: `safety_alert_repository.dart:58` — resendSafetyAlert
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-safety-alert-show-customeralertdetails"></a>
## Endpoint : /api/v1/rideshare/customer/safety-alert/show/

- **Constant**: `AppConstants.customerAlertDetails`
- **Repository**: `safety_alert_repository.dart:75` — getSafetyAlertDetails
- **Model**: `lib/features/ride_share_module/safety_alert/domain/models/customer_alert_details.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.reason
- data.comment
- data.status

<a id="api-v1-rideshare-customer-safety-alert-store-storesafetyalert"></a>
## Endpoint : /api/v1/rideshare/customer/safety-alert/store

- **Constant**: `AppConstants.storeSafetyAlert`
- **Repository**: `safety_alert_repository.dart:32` — storeSafetyAlert
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-safety-alert-undo-undosafetyalert"></a>
## Endpoint : /api/v1/rideshare/customer/safety-alert/undo/

- **Constant**: `AppConstants.undoSafetyAlert`
- **Repository**: `safety_alert_repository.dart:66` — undoSafetyAlert
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-rideshare-customer-vehicle-category-getridesharecategoryuri"></a>
## Endpoint : /api/v1/rideshare/customer/vehicle/category

- **Constant**: `AppConstants.getRideShareCategoryUri`
- **Repository**: `rideHome_repository.dart:60` — getCategoryList
- **Model**: `lib/features/ride_share_module/ride_home/domain/models/ride_categoty_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.name
- data.image

<a id="api-v1-rideshare-user-store-live-location-updatelivelocation"></a>
## Endpoint : /api/v1/rideshare/user/store-live-location

- **Constant**: `AppConstants.updateLiveLocation`
- **Repository**: `rideHome_repository.dart:99` — updateLastLocation
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_


---

# Service

<a id="api-v1-service-booking-all-running-bookings-serviceallrunningbookingsuri"></a>
## Endpoint : /api/v1/service/booking/all-running-bookings

- **Constant**: `AppConstants.serviceAllRunningBookingsUri`
- **Repository**: `booking_repository.dart:79` — getAllRunningBookings
- **Model**: `lib/common/models/ongoing_order_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.order_type
- data.status

<a id="api-v1-service-booking-cancel-servicebookingcanceluri"></a>
## Endpoint : /api/v1/service/booking/cancel

- **Constant**: `AppConstants.serviceBookingCancelUri`
- **Repository**: `booking_repository.dart:98`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-service-booking-delete-servicebookingdeleteuri"></a>
## Endpoint : /api/v1/service/booking/delete

- **Constant**: `AppConstants.serviceBookingDeleteUri`
- **Repository**: `booking_repository.dart:104` — deleteBooking
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-service-booking-details-servicebookingdetailsuri"></a>
## Endpoint : /api/v1/service/booking/details/

- **Constant**: `AppConstants.serviceBookingDetailsUri`
- **Repository**: `booking_repository.dart:31` — getBookingDetails
- **Model**: `lib/features/service_module/booking_details/domain/models/booking_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- display_id
- child_bookings_count
- repeat_log
- is_custom
- booking_status
- status_label
- status_history
- payment_status
- payment_method
- scheduled
- schedule_at
- otp
- booking_note
- cancellation_reason
- service_location
- service_location.get_service_at
- service_location.address
- amount
- amount.booking_amount
- amount.discount_amount
- amount.coupon_discount_amount
- amount.pro_discount
- amount.ref_bonus_amount
- amount.tax_amount
- amount.tax_status
- amount.additional_charge
- booking_amount
- is_reviewed
- can_rebook
- is_campaign
- provider
- provider.discount
- provider.discount.discount_amount
- provider.discount.discount_amount_type
- provider.id
- provider.name
- provider.slug
- provider.logo_full_url
- provider.cover_photo_full_url
- provider.address
- provider.phone
- provider.latitude
- provider.longitude
- provider.avg_rating
- provider.rating_count
- provider.open
- provider.active
- provider.schedules
- provider.schedules.day
- provider.schedules.opening_time
- provider.schedules.closing_time
- provider.distance
- provider.verified_seller
- provider.ad
- provider.announcement
- provider.announcement_message
- provider.sub_title
- provider.tagline
- provider.discount_type
- provider.order_count
- provider.coupons
- provider.coupons.title
- provider.coupons.code
- provider.coupons.start_date
- provider.coupons.expire_date
- provider.coupons.min_purchase
- provider.coupons.max_discount
- provider.coupons.discount
- provider.coupons.discount_type
- provider.coupons.coupon_type
- provider.coupons.data
- provider.coupons.store_id
- provider.coupons.store_new
- provider.coupons.store_new.name
- provider.coupons.store_new.verified_seller
- provider.instant_booking
- provider.repeat_booking
- provider.schedule_booking
- provider.distance_km
- customer
- customer.name
- customer.phone
- servicemen
- servicemen.name
- servicemen.phone
- servicemen.image_full_url
- details
- details.thumbnail_full_url
- details.service_id
- details.is_campaign
- details.service_name
- details.quantity
- details.price
- details.original_price
- details.variation
- details.variation.variant_key
- details.variation.name
- details.variation.price
- details.variation.discount
- details.variation.discount_type
- partial_payments
- partial_payments.amount
- partial_payments.payment_status
- partial_payments.payment_method
- offline_payment
- offline_payment.status
- offline_payment.note
- offline_payment.method_fields
- offline_payment.method_fields.input_name
- offline_payment.method_fields.input_data
- details_count
- created_at

<a id="api-v1-service-booking-get-tax-servicebookinggettaxuri"></a>
## Endpoint : /api/v1/service/booking/get-tax

- **Constant**: `AppConstants.serviceBookingGetTaxUri`
- **Repository**: `service_checkout_repository.dart:29` — getBookingTax
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-service-booking-invoice-servicebookinginvoiceuri"></a>
## Endpoint : /api/v1/service/booking/invoice/

- **Constant**: `AppConstants.serviceBookingInvoiceUri`
- **Repository**: `booking_repository.dart:56`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-service-booking-last-servicebookinglasturi"></a>
## Endpoint : /api/v1/service/booking/last

- **Constant**: `AppConstants.serviceBookingLastUri`
- **Repository**: `booking_repository.dart:69`
- **Model**: `lib/features/service_module/booking_details/domain/models/booking_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- bookings
- bookings.id
- bookings.display_id
- bookings.child_bookings_count
- bookings.repeat_log
- bookings.is_custom
- bookings.booking_status
- bookings.status_label
- bookings.status_history
- bookings.payment_status
- bookings.payment_method
- bookings.scheduled
- bookings.schedule_at
- bookings.otp
- bookings.booking_note
- bookings.cancellation_reason
- bookings.service_location
- bookings.service_location.get_service_at
- bookings.service_location.address
- bookings.amount
- bookings.amount.booking_amount
- bookings.amount.discount_amount
- bookings.amount.coupon_discount_amount
- bookings.amount.pro_discount
- bookings.amount.ref_bonus_amount
- bookings.amount.tax_amount
- bookings.amount.tax_status
- bookings.amount.additional_charge
- bookings.booking_amount
- bookings.is_reviewed
- bookings.can_rebook
- bookings.is_campaign
- bookings.provider
- bookings.provider.discount
- bookings.provider.discount.discount_amount
- bookings.provider.discount.discount_amount_type
- bookings.provider.id
- bookings.provider.name
- bookings.provider.slug
- bookings.provider.logo_full_url
- bookings.provider.cover_photo_full_url
- bookings.provider.address
- bookings.provider.phone
- bookings.provider.latitude
- bookings.provider.longitude
- bookings.provider.avg_rating
- bookings.provider.rating_count
- bookings.provider.open
- bookings.provider.active
- bookings.provider.schedules
- bookings.provider.schedules.day
- bookings.provider.schedules.opening_time
- bookings.provider.schedules.closing_time
- bookings.provider.distance
- bookings.provider.verified_seller
- bookings.provider.ad
- bookings.provider.announcement
- bookings.provider.announcement_message
- bookings.provider.sub_title
- bookings.provider.tagline
- bookings.provider.discount_type
- bookings.provider.order_count
- bookings.provider.coupons
- bookings.provider.coupons.title
- bookings.provider.coupons.code
- bookings.provider.coupons.start_date
- bookings.provider.coupons.expire_date
- bookings.provider.coupons.min_purchase
- bookings.provider.coupons.max_discount
- bookings.provider.coupons.discount
- bookings.provider.coupons.discount_type
- bookings.provider.coupons.coupon_type
- bookings.provider.coupons.data
- bookings.provider.coupons.store_id
- bookings.provider.coupons.store_new
- bookings.provider.instant_booking
- bookings.provider.repeat_booking
- bookings.provider.schedule_booking
- bookings.provider.distance_km
- bookings.customer
- bookings.customer.name
- bookings.customer.phone
- bookings.servicemen
- bookings.servicemen.name
- bookings.servicemen.phone
- bookings.servicemen.image_full_url
- bookings.details
- bookings.details.thumbnail_full_url
- bookings.details.service_id
- bookings.details.is_campaign
- bookings.details.service_name
- bookings.details.quantity
- bookings.details.price
- bookings.details.original_price
- bookings.details.variation
- bookings.details.variation.variant_key
- bookings.details.variation.name
- bookings.details.variation.price
- bookings.details.variation.discount
- bookings.details.variation.discount_type
- bookings.partial_payments
- bookings.partial_payments.amount
- bookings.partial_payments.payment_status
- bookings.partial_payments.payment_method
- bookings.offline_payment
- bookings.offline_payment.status
- bookings.offline_payment.note
- bookings.offline_payment.method_fields
- bookings.offline_payment.method_fields.input_name
- bookings.offline_payment.method_fields.input_data
- bookings.details_count
- bookings.created_at

<a id="api-v1-service-booking-list-servicebookinglisturi"></a>
## Endpoint : /api/v1/service/booking/list

- **Constant**: `AppConstants.serviceBookingListUri`
- **Repository**: `booking_repository.dart:20` — getBookingList
- **Model**: `lib/features/service_module/booking_details/domain/models/booking_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- bookings
- bookings.id
- bookings.display_id
- bookings.child_bookings_count
- bookings.repeat_log
- bookings.is_custom
- bookings.booking_status
- bookings.status_label
- bookings.status_history
- bookings.payment_status
- bookings.payment_method
- bookings.scheduled
- bookings.schedule_at
- bookings.otp
- bookings.booking_note
- bookings.cancellation_reason
- bookings.service_location
- bookings.service_location.get_service_at
- bookings.service_location.address
- bookings.amount
- bookings.amount.booking_amount
- bookings.amount.discount_amount
- bookings.amount.coupon_discount_amount
- bookings.amount.pro_discount
- bookings.amount.ref_bonus_amount
- bookings.amount.tax_amount
- bookings.amount.tax_status
- bookings.amount.additional_charge
- bookings.booking_amount
- bookings.is_reviewed
- bookings.can_rebook
- bookings.is_campaign
- bookings.provider
- bookings.provider.discount
- bookings.provider.discount.discount_amount
- bookings.provider.discount.discount_amount_type
- bookings.provider.id
- bookings.provider.name
- bookings.provider.slug
- bookings.provider.logo_full_url
- bookings.provider.cover_photo_full_url
- bookings.provider.address
- bookings.provider.phone
- bookings.provider.latitude
- bookings.provider.longitude
- bookings.provider.avg_rating
- bookings.provider.rating_count
- bookings.provider.open
- bookings.provider.active
- bookings.provider.schedules
- bookings.provider.schedules.day
- bookings.provider.schedules.opening_time
- bookings.provider.schedules.closing_time
- bookings.provider.distance
- bookings.provider.verified_seller
- bookings.provider.ad
- bookings.provider.announcement
- bookings.provider.announcement_message
- bookings.provider.sub_title
- bookings.provider.tagline
- bookings.provider.discount_type
- bookings.provider.order_count
- bookings.provider.coupons
- bookings.provider.coupons.title
- bookings.provider.coupons.code
- bookings.provider.coupons.start_date
- bookings.provider.coupons.expire_date
- bookings.provider.coupons.min_purchase
- bookings.provider.coupons.max_discount
- bookings.provider.coupons.discount
- bookings.provider.coupons.discount_type
- bookings.provider.coupons.coupon_type
- bookings.provider.coupons.data
- bookings.provider.coupons.store_id
- bookings.provider.coupons.store_new
- bookings.provider.instant_booking
- bookings.provider.repeat_booking
- bookings.provider.schedule_booking
- bookings.provider.distance_km
- bookings.customer
- bookings.customer.name
- bookings.customer.phone
- bookings.servicemen
- bookings.servicemen.name
- bookings.servicemen.phone
- bookings.servicemen.image_full_url
- bookings.details
- bookings.details.thumbnail_full_url
- bookings.details.service_id
- bookings.details.is_campaign
- bookings.details.service_name
- bookings.details.quantity
- bookings.details.price
- bookings.details.original_price
- bookings.details.variation
- bookings.details.variation.variant_key
- bookings.details.variation.name
- bookings.details.variation.price
- bookings.details.variation.discount
- bookings.details.variation.discount_type
- bookings.partial_payments
- bookings.partial_payments.amount
- bookings.partial_payments.payment_status
- bookings.partial_payments.payment_method
- bookings.offline_payment
- bookings.offline_payment.status
- bookings.offline_payment.note
- bookings.offline_payment.method_fields
- bookings.offline_payment.method_fields.input_name
- bookings.offline_payment.method_fields.input_data
- bookings.details_count
- bookings.created_at

<a id="api-v1-service-booking-payment-servicebookingpaymenturi"></a>
## Endpoint : /api/v1/service/booking/payment

- **Constant**: `AppConstants.serviceBookingPaymentUri`
- **Repository**: `service_checkout_repository.dart:53` — switchToCOD
- **Model**: `lib/features/service_module/service_checkout/domain/models/service_booking_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- redirect_link

<a id="api-v1-service-booking-place-serviceplacebookinguri"></a>
## Endpoint : /api/v1/service/booking/place

- **Constant**: `AppConstants.servicePlaceBookingUri`
- **Repository**: `service_checkout_repository.dart:19` — placeBooking
- **Model**: `lib/features/service_module/service_checkout/domain/models/service_booking_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- token

<a id="api-v1-service-booking-rebook-servicebookingrebookuri"></a>
## Endpoint : /api/v1/service/booking/rebook

- **Constant**: `AppConstants.serviceBookingRebookUri`
- **Repository**: `booking_repository.dart:88` — rebookBooking
- **Model**: `lib/features/service_module/booking_details/domain/models/service_rebook_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- provider_id
- added_count
- unavailable_count
- unavailable_items
- unavailable_items.service_name
- unavailable_items.message

<a id="api-v1-service-booking-track-servicebookingtrackuri"></a>
## Endpoint : /api/v1/service/booking/track

- **Constant**: `AppConstants.serviceBookingTrackUri`
- **Repository**: `booking_repository.dart:44`
- **Model**: `lib/features/service_module/booking_details/domain/models/booking_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- display_id
- child_bookings_count
- repeat_log
- is_custom
- booking_status
- status_label
- status_history
- payment_status
- payment_method
- scheduled
- schedule_at
- otp
- booking_note
- cancellation_reason
- service_location
- service_location.get_service_at
- service_location.address
- amount
- amount.booking_amount
- amount.discount_amount
- amount.coupon_discount_amount
- amount.pro_discount
- amount.ref_bonus_amount
- amount.tax_amount
- amount.tax_status
- amount.additional_charge
- booking_amount
- is_reviewed
- can_rebook
- is_campaign
- provider
- provider.discount
- provider.discount.discount_amount
- provider.discount.discount_amount_type
- provider.id
- provider.name
- provider.slug
- provider.logo_full_url
- provider.cover_photo_full_url
- provider.address
- provider.phone
- provider.latitude
- provider.longitude
- provider.avg_rating
- provider.rating_count
- provider.open
- provider.active
- provider.schedules
- provider.schedules.day
- provider.schedules.opening_time
- provider.schedules.closing_time
- provider.distance
- provider.verified_seller
- provider.ad
- provider.announcement
- provider.announcement_message
- provider.sub_title
- provider.tagline
- provider.discount_type
- provider.order_count
- provider.coupons
- provider.coupons.title
- provider.coupons.code
- provider.coupons.start_date
- provider.coupons.expire_date
- provider.coupons.min_purchase
- provider.coupons.max_discount
- provider.coupons.discount
- provider.coupons.discount_type
- provider.coupons.coupon_type
- provider.coupons.data
- provider.coupons.store_id
- provider.coupons.store_new
- provider.coupons.store_new.name
- provider.coupons.store_new.verified_seller
- provider.instant_booking
- provider.repeat_booking
- provider.schedule_booking
- provider.distance_km
- customer
- customer.name
- customer.phone
- servicemen
- servicemen.name
- servicemen.phone
- servicemen.image_full_url
- details
- details.thumbnail_full_url
- details.service_id
- details.is_campaign
- details.service_name
- details.quantity
- details.price
- details.original_price
- details.variation
- details.variation.variant_key
- details.variation.name
- details.variation.price
- details.variation.discount
- details.variation.discount_type
- partial_payments
- partial_payments.amount
- partial_payments.payment_status
- partial_payments.payment_method
- offline_payment
- offline_payment.status
- offline_payment.note
- offline_payment.method_fields
- offline_payment.method_fields.input_name
- offline_payment.method_fields.input_data
- details_count
- created_at

<a id="api-v1-service-campaigns-servicecampaignsuri"></a>
## Endpoint : /api/v1/service/campaigns

- **Constant**: `AppConstants.serviceCampaignsUri`
- **Repository**: `service_repository.dart:140`
- **Model**: `lib/features/service_module/service_home/domain/models/service_campaign_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- campaigns
- campaigns.id
- campaigns.name
- campaigns.slug
- campaigns.thumbnail_full_url
- campaigns.base_price
- campaigns.discount
- campaigns.discount_type
- campaigns.discounted_price
- campaigns.variations
- campaigns.variations.variant_key
- campaigns.variations.name
- campaigns.variations.price
- campaigns.variations.discount
- campaigns.variations.discount_type
- campaigns.provider_name
- campaigns.provider_image_full_url
- campaigns.verified_provider

<a id="api-v1-service-campaigns-details-servicecampaigndetailsuri"></a>
## Endpoint : /api/v1/service/campaigns/details

- **Constant**: `AppConstants.serviceCampaignDetailsUri`
- **Repository**: `service_repository.dart:149` — getCampaignDetails
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- slug
- short_description
- long_description
- thumbnail_full_url
- additional_images_full_url
- base_price
- discount
- discount_type
- discounted_price
- variations
- variations.variant_key
- variations.name
- variations.price
- variations.discount
- variations.discount_type
- avg_rating
- rating_count
- module_id
- store_id
- store_name
- provider_image_full_url
- verified_provider
- distance_km
- provider
- provider.discount
- provider.discount.discount_amount
- provider.discount.discount_amount_type
- provider.id
- provider.name
- provider.slug
- provider.logo_full_url
- provider.cover_photo_full_url
- provider.address
- provider.phone
- provider.latitude
- provider.longitude
- provider.avg_rating
- provider.rating_count
- provider.open
- provider.active
- provider.schedules
- provider.schedules.day
- provider.schedules.opening_time
- provider.schedules.closing_time
- provider.distance
- provider.verified_seller
- provider.ad
- provider.announcement
- provider.announcement_message
- provider.sub_title
- provider.tagline
- provider.discount_type
- provider.order_count
- provider.coupons
- provider.coupons.title
- provider.coupons.code
- provider.coupons.start_date
- provider.coupons.expire_date
- provider.coupons.min_purchase
- provider.coupons.max_discount
- provider.coupons.discount
- provider.coupons.discount_type
- provider.coupons.coupon_type
- provider.coupons.data
- provider.coupons.store_id
- provider.coupons.store_new
- provider.coupons.store_new.name
- provider.coupons.store_new.verified_seller
- provider.instant_booking
- provider.repeat_booking
- provider.schedule_booking
- provider.distance_km
- faqs
- faqs.question
- faqs.answer
- total_reviews
- reviews
- reviews.rating
- reviews.comment
- reviews.attachment
- reviews.reply
- reviews.item_name
- reviews.item_image_full_url
- reviews.created_at
- reviews.service_name
- reviews.service_image_full_url
- reviews.customer
- reviews.customer.image_full_url
- reviews.review_date
- is_favorite
- is_favourite

<a id="api-v1-service-category-providers-servicecategoryprovidersqueryuri"></a>
## Endpoint : /api/v1/service/category-providers

- **Constant**: `AppConstants.serviceCategoryProvidersQueryUri`
- **Repository**: `service_category_repository.dart:43`
- **Model**: `lib/features/service_module/service_category/domain/models/service_category_data_model.dart`
- **Parsed to model**: Yes

**Data:**

- providers
- providers.services
- providers.services.id
- providers.services.name
- providers.services.slug
- providers.services.short_description
- providers.services.long_description
- providers.services.thumbnail_full_url
- providers.services.additional_images_full_url
- providers.services.base_price
- providers.services.discount
- providers.services.discount_type
- providers.services.discounted_price
- providers.services.variations
- providers.services.variations.variant_key
- providers.services.variations.name
- providers.services.variations.price
- providers.services.variations.discount
- providers.services.variations.discount_type
- providers.services.avg_rating
- providers.services.rating_count
- providers.services.module_id
- providers.services.store_id
- providers.services.store_name
- providers.services.provider_image_full_url
- providers.services.verified_provider
- providers.services.distance_km
- providers.services.provider
- providers.services.provider.discount
- providers.services.provider.id
- providers.services.provider.name
- providers.services.provider.slug
- providers.services.provider.logo_full_url
- providers.services.provider.cover_photo_full_url
- providers.services.provider.address
- providers.services.provider.phone
- providers.services.provider.latitude
- providers.services.provider.longitude
- providers.services.provider.avg_rating
- providers.services.provider.rating_count
- providers.services.provider.open
- providers.services.provider.active
- providers.services.provider.schedules
- providers.services.provider.distance
- providers.services.provider.verified_seller
- providers.services.provider.ad
- providers.services.provider.announcement
- providers.services.provider.announcement_message
- providers.services.provider.sub_title
- providers.services.provider.tagline
- providers.services.provider.discount_type
- providers.services.provider.order_count
- providers.services.provider.coupons
- providers.services.provider.instant_booking
- providers.services.provider.repeat_booking
- providers.services.provider.schedule_booking
- providers.services.provider.distance_km
- providers.services.faqs
- providers.services.faqs.question
- providers.services.faqs.answer
- providers.services.total_reviews
- providers.services.reviews
- providers.services.reviews.rating
- providers.services.reviews.comment
- providers.services.reviews.attachment
- providers.services.reviews.reply
- providers.services.reviews.item_name
- providers.services.reviews.item_image_full_url
- providers.services.reviews.created_at
- providers.services.reviews.service_name
- providers.services.reviews.service_image_full_url
- providers.services.reviews.customer
- providers.services.reviews.review_date
- providers.services.is_favorite
- providers.services.is_favourite
- total_size

<a id="api-v1-service-custom-requests-customservicerequestsuri"></a>
## Endpoint : /api/v1/service/custom-requests

- **Constant**: `AppConstants.customServiceRequestsUri`
- **Repository**: `custom_service_request_repository.dart:14` — createRequest
- **Model**: `lib/features/service_module/custom_service_request/domain/models/custom_service_request_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- description
- customer_information
- customer_information.name
- customer_information.phone
- customer_information.address
- customer_information.road
- customer_information.house
- customer_information.floor
- customer_information.latitude
- customer_information.longitude
- booking_date
- booking_time
- status
- category
- category.name
- sub_category
- sub_category.name
- created_at

<a id="api-v1-service-customer-get-zone-id-getservicezoneid"></a>
## Endpoint : /api/v1/service/customer/get-zone-id

- **Constant**: `AppConstants.getServiceZoneId`
- **Repository**: `search_location_repository.dart:49` — getServiceZone
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-service-details-servicedetailsuri"></a>
## Endpoint : /api/v1/service/details

- **Constant**: `AppConstants.serviceDetailsUri`
- **Repository**: `service_details_repository.dart:13` — getServiceDetails
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- slug
- short_description
- long_description
- thumbnail_full_url
- additional_images_full_url
- base_price
- discount
- discount_type
- discounted_price
- variations
- variations.variant_key
- variations.name
- variations.price
- variations.discount
- variations.discount_type
- avg_rating
- rating_count
- module_id
- store_id
- store_name
- provider_image_full_url
- verified_provider
- distance_km
- provider
- provider.discount
- provider.discount.discount_amount
- provider.discount.discount_amount_type
- provider.id
- provider.name
- provider.slug
- provider.logo_full_url
- provider.cover_photo_full_url
- provider.address
- provider.phone
- provider.latitude
- provider.longitude
- provider.avg_rating
- provider.rating_count
- provider.open
- provider.active
- provider.schedules
- provider.schedules.day
- provider.schedules.opening_time
- provider.schedules.closing_time
- provider.distance
- provider.verified_seller
- provider.ad
- provider.announcement
- provider.announcement_message
- provider.sub_title
- provider.tagline
- provider.discount_type
- provider.order_count
- provider.coupons
- provider.coupons.title
- provider.coupons.code
- provider.coupons.start_date
- provider.coupons.expire_date
- provider.coupons.min_purchase
- provider.coupons.max_discount
- provider.coupons.discount
- provider.coupons.discount_type
- provider.coupons.coupon_type
- provider.coupons.data
- provider.coupons.store_id
- provider.coupons.store_new
- provider.coupons.store_new.name
- provider.coupons.store_new.verified_seller
- provider.instant_booking
- provider.repeat_booking
- provider.schedule_booking
- provider.distance_km
- faqs
- faqs.question
- faqs.answer
- total_reviews
- reviews
- reviews.rating
- reviews.comment
- reviews.attachment
- reviews.reply
- reviews.item_name
- reviews.item_image_full_url
- reviews.created_at
- reviews.service_name
- reviews.service_image_full_url
- reviews.customer
- reviews.customer.image_full_url
- reviews.review_date
- is_favorite
- is_favourite

<a id="api-v1-service-explore-serviceexploreuri"></a>
## Endpoint : /api/v1/service/explore

- **Constant**: `AppConstants.serviceExploreUri`
- **Repository**: `service_repository.dart:110`
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- services
- services.id
- services.name
- services.slug
- services.short_description
- services.long_description
- services.thumbnail_full_url
- services.additional_images_full_url
- services.base_price
- services.discount
- services.discount_type
- services.discounted_price
- services.variations
- services.variations.variant_key
- services.variations.name
- services.variations.price
- services.variations.discount
- services.variations.discount_type
- services.avg_rating
- services.rating_count
- services.module_id
- services.store_id
- services.store_name
- services.provider_image_full_url
- services.verified_provider
- services.distance_km
- services.provider
- services.provider.discount
- services.provider.discount.discount_amount
- services.provider.discount.discount_amount_type
- services.provider.id
- services.provider.name
- services.provider.slug
- services.provider.logo_full_url
- services.provider.cover_photo_full_url
- services.provider.address
- services.provider.phone
- services.provider.latitude
- services.provider.longitude
- services.provider.avg_rating
- services.provider.rating_count
- services.provider.open
- services.provider.active
- services.provider.schedules
- services.provider.schedules.day
- services.provider.schedules.opening_time
- services.provider.schedules.closing_time
- services.provider.distance
- services.provider.verified_seller
- services.provider.ad
- services.provider.announcement
- services.provider.announcement_message
- services.provider.sub_title
- services.provider.tagline
- services.provider.discount_type
- services.provider.order_count
- services.provider.coupons
- services.provider.coupons.title
- services.provider.coupons.code
- services.provider.coupons.start_date
- services.provider.coupons.expire_date
- services.provider.coupons.min_purchase
- services.provider.coupons.max_discount
- services.provider.coupons.discount
- services.provider.coupons.discount_type
- services.provider.coupons.coupon_type
- services.provider.coupons.data
- services.provider.coupons.store_id
- services.provider.coupons.store_new
- services.provider.instant_booking
- services.provider.repeat_booking
- services.provider.schedule_booking
- services.provider.distance_km
- services.faqs
- services.faqs.question
- services.faqs.answer
- services.total_reviews
- services.reviews
- services.reviews.rating
- services.reviews.comment
- services.reviews.attachment
- services.reviews.reply
- services.reviews.item_name
- services.reviews.item_image_full_url
- services.reviews.created_at
- services.reviews.service_name
- services.reviews.service_image_full_url
- services.reviews.customer
- services.reviews.customer.image_full_url
- services.reviews.review_date
- services.is_favorite
- services.is_favourite
- categories
- categories.id
- categories.name
- categories.image_full_url
- categories.childes

<a id="api-v1-service-get-combined-data-servicecombineddatauri"></a>
## Endpoint : /api/v1/service/get-combined-data

- **Constant**: `AppConstants.serviceCombinedDataUri`
- **Repository**: `service_repository.dart:125`
- **Model**: `lib/features/service_module/service_home/domain/models/verified_provider_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- providers
- providers.discount
- providers.discount.discount_amount
- providers.discount.discount_amount_type
- providers.id
- providers.name
- providers.slug
- providers.logo_full_url
- providers.cover_photo_full_url
- providers.address
- providers.phone
- providers.latitude
- providers.longitude
- providers.avg_rating
- providers.rating_count
- providers.open
- providers.active
- providers.schedules
- providers.schedules.day
- providers.schedules.opening_time
- providers.schedules.closing_time
- providers.distance
- providers.verified_seller
- providers.ad
- providers.announcement
- providers.announcement_message
- providers.sub_title
- providers.tagline
- providers.discount_type
- providers.order_count
- providers.coupons
- providers.coupons.title
- providers.coupons.code
- providers.coupons.start_date
- providers.coupons.expire_date
- providers.coupons.min_purchase
- providers.coupons.max_discount
- providers.coupons.discount
- providers.coupons.discount_type
- providers.coupons.coupon_type
- providers.coupons.data
- providers.coupons.store_id
- providers.coupons.store_new
- providers.coupons.store_new.name
- providers.coupons.store_new.verified_seller
- providers.instant_booking
- providers.repeat_booking
- providers.schedule_booking
- providers.distance_km
- stores
- stores.discount
- stores.discount.discount_amount
- stores.discount.discount_amount_type
- stores.id
- stores.name
- stores.slug
- stores.logo_full_url
- stores.cover_photo_full_url
- stores.address
- stores.phone
- stores.latitude
- stores.longitude
- stores.avg_rating
- stores.rating_count
- stores.open
- stores.active
- stores.schedules
- stores.schedules.day
- stores.schedules.opening_time
- stores.schedules.closing_time
- stores.distance
- stores.verified_seller
- stores.ad
- stores.announcement
- stores.announcement_message
- stores.sub_title
- stores.tagline
- stores.discount_type
- stores.order_count
- stores.coupons
- stores.coupons.title
- stores.coupons.code
- stores.coupons.start_date
- stores.coupons.expire_date
- stores.coupons.min_purchase
- stores.coupons.max_discount
- stores.coupons.discount
- stores.coupons.discount_type
- stores.coupons.coupon_type
- stores.coupons.data
- stores.coupons.store_id
- stores.coupons.store_new
- stores.coupons.store_new.name
- stores.coupons.store_new.verified_seller
- stores.instant_booking
- stores.repeat_booking
- stores.schedule_booking
- stores.distance_km

<a id="api-v1-service-item-or-store-search-serviceitemorstoresearchuri"></a>
## Endpoint : /api/v1/service/item-or-store-search

- **Constant**: `AppConstants.serviceItemOrStoreSearchUri`
- **Repository**: `search_repository.dart:152`
- **Model**: `lib/features/search/domain/models/search_suggestion_model.dart`
- **Parsed to model**: Yes

**Data:**

- items
- items.name
- items.module_id
- stores
- stores.name
- stores.module_id

<a id="api-v1-service-offers-items-serviceofferitemsuri"></a>
## Endpoint : /api/v1/service/offers/items

- **Constant**: `AppConstants.serviceOfferItemsUri`
- **Repository**: `offer_repository.dart:27`
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- services
- services.id
- services.name
- services.slug
- services.short_description
- services.long_description
- services.thumbnail_full_url
- services.additional_images_full_url
- services.base_price
- services.discount
- services.discount_type
- services.discounted_price
- services.variations
- services.variations.variant_key
- services.variations.name
- services.variations.price
- services.variations.discount
- services.variations.discount_type
- services.avg_rating
- services.rating_count
- services.module_id
- services.store_id
- services.store_name
- services.provider_image_full_url
- services.verified_provider
- services.distance_km
- services.provider
- services.provider.discount
- services.provider.discount.discount_amount
- services.provider.discount.discount_amount_type
- services.provider.id
- services.provider.name
- services.provider.slug
- services.provider.logo_full_url
- services.provider.cover_photo_full_url
- services.provider.address
- services.provider.phone
- services.provider.latitude
- services.provider.longitude
- services.provider.avg_rating
- services.provider.rating_count
- services.provider.open
- services.provider.active
- services.provider.schedules
- services.provider.schedules.day
- services.provider.schedules.opening_time
- services.provider.schedules.closing_time
- services.provider.distance
- services.provider.verified_seller
- services.provider.ad
- services.provider.announcement
- services.provider.announcement_message
- services.provider.sub_title
- services.provider.tagline
- services.provider.discount_type
- services.provider.order_count
- services.provider.coupons
- services.provider.coupons.title
- services.provider.coupons.code
- services.provider.coupons.start_date
- services.provider.coupons.expire_date
- services.provider.coupons.min_purchase
- services.provider.coupons.max_discount
- services.provider.coupons.discount
- services.provider.coupons.discount_type
- services.provider.coupons.coupon_type
- services.provider.coupons.data
- services.provider.coupons.store_id
- services.provider.coupons.store_new
- services.provider.instant_booking
- services.provider.repeat_booking
- services.provider.schedule_booking
- services.provider.distance_km
- services.faqs
- services.faqs.question
- services.faqs.answer
- services.total_reviews
- services.reviews
- services.reviews.rating
- services.reviews.comment
- services.reviews.attachment
- services.reviews.reply
- services.reviews.item_name
- services.reviews.item_image_full_url
- services.reviews.created_at
- services.reviews.service_name
- services.reviews.service_image_full_url
- services.reviews.customer
- services.reviews.customer.image_full_url
- services.reviews.review_date
- services.is_favorite
- services.is_favourite
- categories
- categories.id
- categories.name
- categories.image_full_url
- categories.childes

<a id="api-v1-service-popular-servicepopularuri"></a>
## Endpoint : /api/v1/service/popular

- **Constant**: `AppConstants.servicePopularUri`
- **Repository**: `service_repository.dart:68` — getProviderPopularServices
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- services
- services.id
- services.name
- services.slug
- services.short_description
- services.long_description
- services.thumbnail_full_url
- services.additional_images_full_url
- services.base_price
- services.discount
- services.discount_type
- services.discounted_price
- services.variations
- services.variations.variant_key
- services.variations.name
- services.variations.price
- services.variations.discount
- services.variations.discount_type
- services.avg_rating
- services.rating_count
- services.module_id
- services.store_id
- services.store_name
- services.provider_image_full_url
- services.verified_provider
- services.distance_km
- services.provider
- services.provider.discount
- services.provider.discount.discount_amount
- services.provider.discount.discount_amount_type
- services.provider.id
- services.provider.name
- services.provider.slug
- services.provider.logo_full_url
- services.provider.cover_photo_full_url
- services.provider.address
- services.provider.phone
- services.provider.latitude
- services.provider.longitude
- services.provider.avg_rating
- services.provider.rating_count
- services.provider.open
- services.provider.active
- services.provider.schedules
- services.provider.schedules.day
- services.provider.schedules.opening_time
- services.provider.schedules.closing_time
- services.provider.distance
- services.provider.verified_seller
- services.provider.ad
- services.provider.announcement
- services.provider.announcement_message
- services.provider.sub_title
- services.provider.tagline
- services.provider.discount_type
- services.provider.order_count
- services.provider.coupons
- services.provider.coupons.title
- services.provider.coupons.code
- services.provider.coupons.start_date
- services.provider.coupons.expire_date
- services.provider.coupons.min_purchase
- services.provider.coupons.max_discount
- services.provider.coupons.discount
- services.provider.coupons.discount_type
- services.provider.coupons.coupon_type
- services.provider.coupons.data
- services.provider.coupons.store_id
- services.provider.coupons.store_new
- services.provider.instant_booking
- services.provider.repeat_booking
- services.provider.schedule_booking
- services.provider.distance_km
- services.faqs
- services.faqs.question
- services.faqs.answer
- services.total_reviews
- services.reviews
- services.reviews.rating
- services.reviews.comment
- services.reviews.attachment
- services.reviews.reply
- services.reviews.item_name
- services.reviews.item_image_full_url
- services.reviews.created_at
- services.reviews.service_name
- services.reviews.service_image_full_url
- services.reviews.customer
- services.reviews.customer.image_full_url
- services.reviews.review_date
- services.is_favorite
- services.is_favourite
- categories
- categories.id
- categories.name
- categories.image_full_url
- categories.childes

<a id="api-v1-service-query-servicequeryuri"></a>
## Endpoint : /api/v1/service/query

- **Constant**: `AppConstants.serviceQueryUri`
- **Repository**: `service_category_repository.dart:26`
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- services
- services.id
- services.name
- services.slug
- services.short_description
- services.long_description
- services.thumbnail_full_url
- services.additional_images_full_url
- services.base_price
- services.discount
- services.discount_type
- services.discounted_price
- services.variations
- services.variations.variant_key
- services.variations.name
- services.variations.price
- services.variations.discount
- services.variations.discount_type
- services.avg_rating
- services.rating_count
- services.module_id
- services.store_id
- services.store_name
- services.provider_image_full_url
- services.verified_provider
- services.distance_km
- services.provider
- services.provider.discount
- services.provider.discount.discount_amount
- services.provider.discount.discount_amount_type
- services.provider.id
- services.provider.name
- services.provider.slug
- services.provider.logo_full_url
- services.provider.cover_photo_full_url
- services.provider.address
- services.provider.phone
- services.provider.latitude
- services.provider.longitude
- services.provider.avg_rating
- services.provider.rating_count
- services.provider.open
- services.provider.active
- services.provider.schedules
- services.provider.schedules.day
- services.provider.schedules.opening_time
- services.provider.schedules.closing_time
- services.provider.distance
- services.provider.verified_seller
- services.provider.ad
- services.provider.announcement
- services.provider.announcement_message
- services.provider.sub_title
- services.provider.tagline
- services.provider.discount_type
- services.provider.order_count
- services.provider.coupons
- services.provider.coupons.title
- services.provider.coupons.code
- services.provider.coupons.start_date
- services.provider.coupons.expire_date
- services.provider.coupons.min_purchase
- services.provider.coupons.max_discount
- services.provider.coupons.discount
- services.provider.coupons.discount_type
- services.provider.coupons.coupon_type
- services.provider.coupons.data
- services.provider.coupons.store_id
- services.provider.coupons.store_new
- services.provider.instant_booking
- services.provider.repeat_booking
- services.provider.schedule_booking
- services.provider.distance_km
- services.faqs
- services.faqs.question
- services.faqs.answer
- services.total_reviews
- services.reviews
- services.reviews.rating
- services.reviews.comment
- services.reviews.attachment
- services.reviews.reply
- services.reviews.item_name
- services.reviews.item_image_full_url
- services.reviews.created_at
- services.reviews.service_name
- services.reviews.service_image_full_url
- services.reviews.customer
- services.reviews.customer.image_full_url
- services.reviews.review_date
- services.is_favorite
- services.is_favourite
- categories
- categories.id
- categories.name
- categories.image_full_url
- categories.childes

<a id="api-v1-service-quick-emergency-experts-servicequickemergencyexpertsuri"></a>
## Endpoint : /api/v1/service/quick-emergency-experts

- **Constant**: `AppConstants.serviceQuickEmergencyExpertsUri`
- **Repository**: `service_repository.dart:96`
- **Model**: `lib/features/service_module/service_home/domain/models/service_experts_model.dart`
- **Parsed to model**: Yes

**Data:**

- providers
- providers.id
- providers.name
- providers.slug
- providers.logo_full_url
- providers.delivery_time
- providers.services
- providers.services.id
- providers.services.name
- providers.services.slug
- providers.services.short_description
- providers.services.long_description
- providers.services.thumbnail_full_url
- providers.services.additional_images_full_url
- providers.services.base_price
- providers.services.discount
- providers.services.discount_type
- providers.services.discounted_price
- providers.services.variations
- providers.services.variations.variant_key
- providers.services.variations.name
- providers.services.variations.price
- providers.services.variations.discount
- providers.services.variations.discount_type
- providers.services.avg_rating
- providers.services.rating_count
- providers.services.module_id
- providers.services.store_id
- providers.services.store_name
- providers.services.provider_image_full_url
- providers.services.verified_provider
- providers.services.distance_km
- providers.services.provider
- providers.services.provider.discount
- providers.services.provider.id
- providers.services.provider.name
- providers.services.provider.slug
- providers.services.provider.logo_full_url
- providers.services.provider.cover_photo_full_url
- providers.services.provider.address
- providers.services.provider.phone
- providers.services.provider.latitude
- providers.services.provider.longitude
- providers.services.provider.avg_rating
- providers.services.provider.rating_count
- providers.services.provider.open
- providers.services.provider.active
- providers.services.provider.schedules
- providers.services.provider.distance
- providers.services.provider.verified_seller
- providers.services.provider.ad
- providers.services.provider.announcement
- providers.services.provider.announcement_message
- providers.services.provider.sub_title
- providers.services.provider.tagline
- providers.services.provider.discount_type
- providers.services.provider.order_count
- providers.services.provider.coupons
- providers.services.provider.instant_booking
- providers.services.provider.repeat_booking
- providers.services.provider.schedule_booking
- providers.services.provider.distance_km
- providers.services.faqs
- providers.services.faqs.question
- providers.services.faqs.answer
- providers.services.total_reviews
- providers.services.reviews
- providers.services.reviews.rating
- providers.services.reviews.comment
- providers.services.reviews.attachment
- providers.services.reviews.reply
- providers.services.reviews.item_name
- providers.services.reviews.item_image_full_url
- providers.services.reviews.created_at
- providers.services.reviews.service_name
- providers.services.reviews.service_image_full_url
- providers.services.reviews.customer
- providers.services.reviews.review_date
- providers.services.is_favorite
- providers.services.is_favourite

<a id="api-v1-service-recommended-servicerecommendeduri"></a>
## Endpoint : /api/v1/service/recommended

- **Constant**: `AppConstants.serviceRecommendedUri`
- **Repository**: `service_repository.dart:82`
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- services
- services.id
- services.name
- services.slug
- services.short_description
- services.long_description
- services.thumbnail_full_url
- services.additional_images_full_url
- services.base_price
- services.discount
- services.discount_type
- services.discounted_price
- services.variations
- services.variations.variant_key
- services.variations.name
- services.variations.price
- services.variations.discount
- services.variations.discount_type
- services.avg_rating
- services.rating_count
- services.module_id
- services.store_id
- services.store_name
- services.provider_image_full_url
- services.verified_provider
- services.distance_km
- services.provider
- services.provider.discount
- services.provider.discount.discount_amount
- services.provider.discount.discount_amount_type
- services.provider.id
- services.provider.name
- services.provider.slug
- services.provider.logo_full_url
- services.provider.cover_photo_full_url
- services.provider.address
- services.provider.phone
- services.provider.latitude
- services.provider.longitude
- services.provider.avg_rating
- services.provider.rating_count
- services.provider.open
- services.provider.active
- services.provider.schedules
- services.provider.schedules.day
- services.provider.schedules.opening_time
- services.provider.schedules.closing_time
- services.provider.distance
- services.provider.verified_seller
- services.provider.ad
- services.provider.announcement
- services.provider.announcement_message
- services.provider.sub_title
- services.provider.tagline
- services.provider.discount_type
- services.provider.order_count
- services.provider.coupons
- services.provider.coupons.title
- services.provider.coupons.code
- services.provider.coupons.start_date
- services.provider.coupons.expire_date
- services.provider.coupons.min_purchase
- services.provider.coupons.max_discount
- services.provider.coupons.discount
- services.provider.coupons.discount_type
- services.provider.coupons.coupon_type
- services.provider.coupons.data
- services.provider.coupons.store_id
- services.provider.coupons.store_new
- services.provider.instant_booking
- services.provider.repeat_booking
- services.provider.schedule_booking
- services.provider.distance_km
- services.faqs
- services.faqs.question
- services.faqs.answer
- services.total_reviews
- services.reviews
- services.reviews.rating
- services.reviews.comment
- services.reviews.attachment
- services.reviews.reply
- services.reviews.item_name
- services.reviews.item_image_full_url
- services.reviews.created_at
- services.reviews.service_name
- services.reviews.service_image_full_url
- services.reviews.customer
- services.reviews.customer.image_full_url
- services.reviews.review_date
- services.is_favorite
- services.is_favourite
- categories
- categories.id
- categories.name
- categories.image_full_url
- categories.childes

<a id="api-v1-service-related-servicerelateduri"></a>
## Endpoint : /api/v1/service/related

- **Constant**: `AppConstants.serviceRelatedUri`
- **Repository**: `service_details_repository.dart:22` — getRelatedServices
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- slug
- short_description
- long_description
- thumbnail_full_url
- additional_images_full_url
- base_price
- discount
- discount_type
- discounted_price
- variations
- variations.variant_key
- variations.name
- variations.price
- variations.discount
- variations.discount_type
- avg_rating
- rating_count
- module_id
- store_id
- store_name
- provider_image_full_url
- verified_provider
- distance_km
- provider
- provider.discount
- provider.discount.discount_amount
- provider.discount.discount_amount_type
- provider.id
- provider.name
- provider.slug
- provider.logo_full_url
- provider.cover_photo_full_url
- provider.address
- provider.phone
- provider.latitude
- provider.longitude
- provider.avg_rating
- provider.rating_count
- provider.open
- provider.active
- provider.schedules
- provider.schedules.day
- provider.schedules.opening_time
- provider.schedules.closing_time
- provider.distance
- provider.verified_seller
- provider.ad
- provider.announcement
- provider.announcement_message
- provider.sub_title
- provider.tagline
- provider.discount_type
- provider.order_count
- provider.coupons
- provider.coupons.title
- provider.coupons.code
- provider.coupons.start_date
- provider.coupons.expire_date
- provider.coupons.min_purchase
- provider.coupons.max_discount
- provider.coupons.discount
- provider.coupons.discount_type
- provider.coupons.coupon_type
- provider.coupons.data
- provider.coupons.store_id
- provider.coupons.store_new
- provider.coupons.store_new.name
- provider.coupons.store_new.verified_seller
- provider.instant_booking
- provider.repeat_booking
- provider.schedule_booking
- provider.distance_km
- faqs
- faqs.question
- faqs.answer
- total_reviews
- reviews
- reviews.rating
- reviews.comment
- reviews.attachment
- reviews.reply
- reviews.item_name
- reviews.item_image_full_url
- reviews.created_at
- reviews.service_name
- reviews.service_image_full_url
- reviews.customer
- reviews.customer.image_full_url
- reviews.review_date
- is_favorite
- is_favourite

<a id="api-v1-service-related-provider-services-servicerelatedproviderservicesuri"></a>
## Endpoint : /api/v1/service/related-provider-services

- **Constant**: `AppConstants.serviceRelatedProviderServicesUri`
- **Repository**: `service_details_repository.dart:31` — getRelatedProviderServices
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- slug
- short_description
- long_description
- thumbnail_full_url
- additional_images_full_url
- base_price
- discount
- discount_type
- discounted_price
- variations
- variations.variant_key
- variations.name
- variations.price
- variations.discount
- variations.discount_type
- avg_rating
- rating_count
- module_id
- store_id
- store_name
- provider_image_full_url
- verified_provider
- distance_km
- provider
- provider.discount
- provider.discount.discount_amount
- provider.discount.discount_amount_type
- provider.id
- provider.name
- provider.slug
- provider.logo_full_url
- provider.cover_photo_full_url
- provider.address
- provider.phone
- provider.latitude
- provider.longitude
- provider.avg_rating
- provider.rating_count
- provider.open
- provider.active
- provider.schedules
- provider.schedules.day
- provider.schedules.opening_time
- provider.schedules.closing_time
- provider.distance
- provider.verified_seller
- provider.ad
- provider.announcement
- provider.announcement_message
- provider.sub_title
- provider.tagline
- provider.discount_type
- provider.order_count
- provider.coupons
- provider.coupons.title
- provider.coupons.code
- provider.coupons.start_date
- provider.coupons.expire_date
- provider.coupons.min_purchase
- provider.coupons.max_discount
- provider.coupons.discount
- provider.coupons.discount_type
- provider.coupons.coupon_type
- provider.coupons.data
- provider.coupons.store_id
- provider.coupons.store_new
- provider.coupons.store_new.name
- provider.coupons.store_new.verified_seller
- provider.instant_booking
- provider.repeat_booking
- provider.schedule_booking
- provider.distance_km
- faqs
- faqs.question
- faqs.answer
- total_reviews
- reviews
- reviews.rating
- reviews.comment
- reviews.attachment
- reviews.reply
- reviews.item_name
- reviews.item_image_full_url
- reviews.created_at
- reviews.service_name
- reviews.service_image_full_url
- reviews.customer
- reviews.customer.image_full_url
- reviews.review_date
- is_favorite
- is_favourite

<a id="api-v1-service-requested-services-requestedservicesuri"></a>
## Endpoint : /api/v1/service/requested-services

- **Constant**: `AppConstants.requestedServicesUri`
- **Repository**: `requested_service_repository.dart:16` — getDetail
- **Model**: `lib/features/service_module/request_service/domain/models/requested_service_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- service_name
- description
- category_id
- sub_category_id
- category_name
- category_image_full_url
- status
- status_label
- can_edit
- can_delete
- feedback
- created_at

<a id="api-v1-service-reviews-servicereviewlisturi"></a>
## Endpoint : /api/v1/service/reviews

- **Constant**: `AppConstants.serviceReviewListUri`
- **Repository**: `service_review_repository.dart:33`
- **Model**: `lib/features/service_module/service_review/domain/models/service_review_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- rating_summary
- rating_summary.avg_rating
- rating_summary.total_reviews
- rating_summary.breakdown
- rating_summary.breakdown.star
- rating_summary.breakdown.count
- reviews
- reviews.rating
- reviews.comment
- reviews.attachment
- reviews.reply
- reviews.item_name
- reviews.item_image_full_url
- reviews.created_at
- reviews.service_name
- reviews.service_image_full_url
- reviews.customer
- reviews.customer.image_full_url
- reviews.review_date

<a id="api-v1-service-reviews-submit-servicereviewsubmituri"></a>
## Endpoint : /api/v1/service/reviews/submit

- **Constant**: `AppConstants.serviceReviewSubmitUri`
- **Repository**: `service_review_repository.dart:16` — submitReview
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-service-search-servicesearchuri"></a>
## Endpoint : /api/v1/service/search

- **Constant**: `AppConstants.serviceSearchUri`
- **Repository**: `search_repository.dart:132`
- **Model**: `lib/features/service_module/service_home/domain/models/service_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- services
- services.id
- services.name
- services.slug
- services.short_description
- services.long_description
- services.thumbnail_full_url
- services.additional_images_full_url
- services.base_price
- services.discount
- services.discount_type
- services.discounted_price
- services.variations
- services.variations.variant_key
- services.variations.name
- services.variations.price
- services.variations.discount
- services.variations.discount_type
- services.avg_rating
- services.rating_count
- services.module_id
- services.store_id
- services.store_name
- services.provider_image_full_url
- services.verified_provider
- services.distance_km
- services.provider
- services.provider.discount
- services.provider.discount.discount_amount
- services.provider.discount.discount_amount_type
- services.provider.id
- services.provider.name
- services.provider.slug
- services.provider.logo_full_url
- services.provider.cover_photo_full_url
- services.provider.address
- services.provider.phone
- services.provider.latitude
- services.provider.longitude
- services.provider.avg_rating
- services.provider.rating_count
- services.provider.open
- services.provider.active
- services.provider.schedules
- services.provider.schedules.day
- services.provider.schedules.opening_time
- services.provider.schedules.closing_time
- services.provider.distance
- services.provider.verified_seller
- services.provider.ad
- services.provider.announcement
- services.provider.announcement_message
- services.provider.sub_title
- services.provider.tagline
- services.provider.discount_type
- services.provider.order_count
- services.provider.coupons
- services.provider.coupons.title
- services.provider.coupons.code
- services.provider.coupons.start_date
- services.provider.coupons.expire_date
- services.provider.coupons.min_purchase
- services.provider.coupons.max_discount
- services.provider.coupons.discount
- services.provider.coupons.discount_type
- services.provider.coupons.coupon_type
- services.provider.coupons.data
- services.provider.coupons.store_id
- services.provider.coupons.store_new
- services.provider.instant_booking
- services.provider.repeat_booking
- services.provider.schedule_booking
- services.provider.distance_km
- services.faqs
- services.faqs.question
- services.faqs.answer
- services.total_reviews
- services.reviews
- services.reviews.rating
- services.reviews.comment
- services.reviews.attachment
- services.reviews.reply
- services.reviews.item_name
- services.reviews.item_image_full_url
- services.reviews.created_at
- services.reviews.service_name
- services.reviews.service_image_full_url
- services.reviews.customer
- services.reviews.customer.image_full_url
- services.reviews.review_date
- services.is_favorite
- services.is_favourite
- categories
- categories.id
- categories.name
- categories.image_full_url
- categories.childes


---

# Categories

<a id="api-v1-categories-categoryuri"></a>
## Endpoint : /api/v1/categories  — `categoryUri`

- **Constant**: `AppConstants.categoryUri`
- **Repository**: `category_repository.dart:47` — _getCategoryList
- **Model**: `lib/features/category/domain/models/category_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- image_full_url
- slug
- module_id

<a id="api-v1-categories-servicecategoriesuri"></a>
## Endpoint : /api/v1/categories  — `serviceCategoriesUri`

- **Constant**: `AppConstants.serviceCategoriesUri`
- **Repository**: `category_repository.dart:113` — getCategoriesWithChildes
- **Model**: `lib/features/service_module/service_home/domain/models/service_category_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- image_full_url
- childes

<a id="api-v1-categories-childes-subcategoryuri"></a>
## Endpoint : /api/v1/categories/childes/

- **Constant**: `AppConstants.subCategoryUri`
- **Repository**: `category_repository.dart:72` — _getSubCategoryList
- **Model**: `lib/features/category/domain/models/category_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- image_full_url
- slug
- module_id

<a id="api-v1-categories-featured-items-featuredcategoriesitemsuri"></a>
## Endpoint : /api/v1/categories/featured/items

- **Constant**: `AppConstants.featuredCategoriesItemsUri`
- **Repository**: `item_repository.dart:240`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-categories-items-categoryitemuri"></a>
## Endpoint : /api/v1/categories/items/

- **Constant**: `AppConstants.categoryItemUri`
- **Repository**: `category_repository.dart:82` — _getCategoryItemList
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-categories-popular-searchpopularcategoriesuri"></a>
## Endpoint : /api/v1/categories/popular

- **Constant**: `AppConstants.searchPopularCategoriesUri`
- **Repository**: `search_repository.dart:165` — getPopularCategories
- **Model**: `lib/features/search/domain/models/popular_categories_model.dart`
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-categories-stores-categorystoreuri"></a>
## Endpoint : /api/v1/categories/stores/

- **Constant**: `AppConstants.categoryStoreUri`
- **Repository**: `category_repository.dart:91` — _getCategoryStoreList
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset

<a id="api-v1-categories-top-topcategoriesuri"></a>
## Endpoint : /api/v1/categories/top

- **Constant**: `AppConstants.topCategoriesUri`
- **Repository**: `search_repository.dart:232`
- **Model**: `lib/features/search/domain/models/top_category_model.dart`
- **Parsed to model**: Yes

**Data:**

- categories
- categories.id
- categories.name
- categories.image_full_url
- categories.slug
- categories.module_id


---

# Items

<a id="api-v1-brand-brandlisturi"></a>
## Endpoint : /api/v1/brand

- **Constant**: `AppConstants.brandListUri`
- **Repository**: `brands_repository.dart:24`
- **Model**: `lib/features/brands/domain/models/brands_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- slug
- image_full_url
- items_count

<a id="api-v1-brand-items-branditemuri"></a>
## Endpoint : /api/v1/brand/items

- **Constant**: `AppConstants.brandItemUri`
- **Repository**: `brands_repository.dart:45`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-common-condition-commonconditionuri"></a>
## Endpoint : /api/v1/common-condition

- **Constant**: `AppConstants.commonConditionUri`
- **Repository**: `item_repository.dart:287` — _getCommonConditions
- **Model**: `lib/features/item/domain/models/common_condition_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name

<a id="api-v1-common-condition-items-conditionwiseitemuri"></a>
## Endpoint : /api/v1/common-condition/items/

- **Constant**: `AppConstants.conditionWiseItemUri`
- **Repository**: `item_repository.dart:70` — _getConditionsWiseItems
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-items-basic-basicmedicineuri"></a>
## Endpoint : /api/v1/items/basic

- **Constant**: `AppConstants.basicMedicineUri`
- **Repository**: `item_repository.dart:28` — getBasicMedicine
- **Model**: `lib/features/item/domain/models/basic_medicine_model.dart`
- **Parsed to model**: Yes

**Data:**

- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-items-details-itemdetailsuri"></a>
## Endpoint : /api/v1/items/details/

- **Constant**: `AppConstants.itemDetailsUri`
- **Repository**: `item_repository.dart:54` — _getItemDetails
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- description
- image_full_url
- video_link
- video_full_url
- video_preview_url
- video_thumbnail_url
- video_embed_url
- images_full_url
- category_id
- category_ids
- category_ids.id
- variations
- variations.type
- variations.price
- variations.stock
- food_variations
- food_variations.max
- food_variations.name
- food_variations.type
- food_variations.min
- food_variations.required
- food_variations.values
- food_variations.values.label
- food_variations.values.optionPrice
- food_variations.values.isSelected
- add_ons
- add_ons.id
- add_ons.name
- add_ons.price
- addons
- addons.id
- addons.name
- addons.price
- choice_options
- choice_options.title
- choice_options.options
- price
- discount
- discount_type
- available_time_starts
- available_time_ends
- store_id
- store_name
- zone_id
- schedule_order
- avg_rating
- rating_count
- module_id
- module_type
- veg
- stock
- unit_type
- available_date_starts
- organic
- maximum_cart_quantity
- flash_sale
- halal_tag_status
- is_halal
- is_prescription_required
- nutritions_name
- allergies_name
- generic_name
- store_details
- store_details.id
- store_details.name
- store_details.slug
- store_details.zone_id
- store_details.show_low_stock_count
- store_details.minimum_stock_for_warning
- slug
- verified_seller
- store_image_full_url
- store_logo_full_url
- free_delivery
- offer_label
- brand_name

<a id="api-v1-items-discounted-discounteditemsuri"></a>
## Endpoint : /api/v1/items/discounted

- **Constant**: `AppConstants.discountedItemsUri`
- **Repository**: `item_repository.dart:215`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-items-item-or-store-search-searchsuggestionsuri"></a>
## Endpoint : /api/v1/items/item-or-store-search

- **Constant**: `AppConstants.searchSuggestionsUri`
- **Repository**: `search_repository.dart:152`
- **Model**: `lib/features/search/domain/models/search_suggestion_model.dart`
- **Parsed to model**: Yes

**Data:**

- items
- items.name
- items.module_id
- stores
- stores.name
- stores.module_id

<a id="api-v1-items-latest-storeitemuri"></a>
## Endpoint : /api/v1/items/latest

- **Constant**: `AppConstants.storeItemUri`
- **Repository**: `store_repository.dart:277`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-items-most-reviewed-revieweditemuri"></a>
## Endpoint : /api/v1/items/most-reviewed

- **Constant**: `AppConstants.reviewedItemUri`
- **Repository**: `item_repository.dart:173`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-items-popular-popularitemuri"></a>
## Endpoint : /api/v1/items/popular

- **Constant**: `AppConstants.popularItemUri`
- **Repository**: `item_repository.dart:131`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-items-recommended-storerecommendeditemuri"></a>
## Endpoint : /api/v1/items/recommended

- **Constant**: `AppConstants.storeRecommendedItemUri`
- **Repository**: `store_repository.dart:300` — _getStoreRecommendedItemList
- **Model**: `lib/features/store/domain/models/recommended_product_model.dart`
- **Parsed to model**: Yes

**Data:**

- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name

<a id="api-v1-items-recommended-filter-recommendeditemsuri"></a>
## Endpoint : /api/v1/items/recommended?filter=

- **Constant**: `AppConstants.recommendedItemsUri`
- **Repository**: `item_repository.dart:263`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-items-reviews-getreviewlisturi"></a>
## Endpoint : /api/v1/items/reviews

- **Constant**: `AppConstants.getReviewListUri`
- **Repository**: `item_repository.dart:332`
- **Model**: `lib/features/item/domain/models/item_review_model.dart`
- **Parsed to model**: Yes

**Data:**

- rating_summary
- rating_summary.avg_rating
- rating_summary.total_reviews
- rating_summary.breakdown
- rating_summary.breakdown.label
- rating_summary.breakdown.count
- total_size
- reviews
- reviews.comment
- reviews.rating
- reviews.created_at
- reviews.reply
- reviews.customer

<a id="api-v1-items-reviews-submit-reviewuri"></a>
## Endpoint : /api/v1/items/reviews/submit

- **Constant**: `AppConstants.reviewUri`
- **Repository**: `review_repository.dart:27` — submitReview
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-items-suggested-cartstoresuggesteditemsuri"></a>
## Endpoint : /api/v1/items/suggested

- **Constant**: `AppConstants.cartStoreSuggestedItemsUri`
- **Repository**: `store_repository.dart:319` — getCartStoreSuggestedItemList
- **Model**: `lib/features/store/domain/models/cart_suggested_item_model.dart`
- **Parsed to model**: Yes

**Data:**

- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name

<a id="api-v1-store-categories-items-storecategoryitemsuri"></a>
## Endpoint : /api/v1/store-categories/items

- **Constant**: `AppConstants.storeCategoryItemsUri`
- **Repository**: `store_repository.dart:366` — getProviderCategoryItems
- **Model**: `lib/features/store/domain/models/store_category_item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- categories
- categories.id
- categories.name

<a id="api-v1-trending-searches-trendingsearchesuri"></a>
## Endpoint : /api/v1/trending-searches

- **Constant**: `AppConstants.trendingSearchesUri`
- **Repository**: `search_repository.dart:219`
- **Model**: `lib/features/search/domain/models/trending_search_model.dart`
- **Parsed to model**: Yes

**Data:**

- trending_searches
- trending_searches.keyword
- trending_searches.module_id


---

# Stores

<a id="api-v1-offers-stores-offerstoresuri"></a>
## Endpoint : /api/v1/offers/stores

- **Constant**: `AppConstants.offerStoresUri`
- **Repository**: `offer_repository.dart:38`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset

<a id="api-v1-stores-details-storedetailsuri"></a>
## Endpoint : /api/v1/stores/details/

- **Constant**: `AppConstants.storeDetailsUri`
- **Repository**: `store_repository.dart:266` — getStoreDetails
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- phone
- logo_full_url
- latitude
- longitude
- address
- minimum_order
- free_delivery
- cover_photo_full_url
- delivery
- take_away
- schedule_order
- avg_rating
- tax
- rating_count
- reviews_count
- self_delivery_system
- minimum_shipping_charge
- maximum_shipping_charge
- per_km_shipping_charge
- open
- active
- zone_id
- delivery_time
- veg
- non_veg
- module_id
- module_type
- order_place_to_schedule_interval
- category_ids
- categories
- store_discount
- store_discount.day
- store_discount.opening_time
- store_discount.closing_time
- schedules
- schedules.day
- schedules.opening_time
- schedules.closing_time
- vendor_id
- prescription_order
- cutlery
- slug
- announcement
- announcement_message
- total_items
- items
- items.id
- items.name
- items.image_full_url
- items.price
- items.discount
- items.discount_type
- top_items
- top_items.id
- top_items.name
- top_items.slug
- top_items.image_full_url
- top_items.thumbnail_full_url
- top_items.price
- top_items.base_price
- top_items.discounted_price
- top_items.discount
- top_items.discount_type
- top_items.avg_rating
- extra_packaging_status
- extra_packaging_amount
- ratings
- reviews_comments_count
- store_sub
- store_sub.chat
- store_business_model
- distance
- distance_km
- current_opening_time
- verified_seller
- avg_item_discount_percentage
- ad
- pro_discount
- pro_discount.start_date
- pro_discount.end_date
- pro_discount.min_purchase
- pro_discount.max_discount
- pro_discount.discount
- pro_discount.discount_type
- is_new
- sponsored
- offer_label
- store_item_image_list
- description
- active_coupons

<a id="api-v1-stores-distance-distancestoresuri"></a>
## Endpoint : /api/v1/stores/distance

- **Constant**: `AppConstants.distanceStoresUri`
- **Repository**: `store_repository.dart:70`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset

<a id="api-v1-stores-exclusive-deals-exclusivedealsuri"></a>
## Endpoint : /api/v1/stores/exclusive-deals

- **Constant**: `AppConstants.exclusiveDealsUri`
- **Repository**: `offer_repository.dart:50` — getExclusiveDeals
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset

<a id="api-v1-stores-get-stores-storeuri"></a>
## Endpoint : /api/v1/stores/get-stores

- **Constant**: `AppConstants.storeUri`
- **Repository**: `store_repository.dart:106`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset

<a id="api-v1-stores-latest-lateststoreuri"></a>
## Endpoint : /api/v1/stores/latest

- **Constant**: `AppConstants.latestStoreUri`
- **Repository**: `store_repository.dart:153`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- phone
- logo_full_url
- latitude
- longitude
- address
- minimum_order
- free_delivery
- cover_photo_full_url
- delivery
- take_away
- schedule_order
- avg_rating
- tax
- rating_count
- reviews_count
- self_delivery_system
- minimum_shipping_charge
- maximum_shipping_charge
- per_km_shipping_charge
- open
- active
- zone_id
- delivery_time
- veg
- non_veg
- module_id
- module_type
- order_place_to_schedule_interval
- category_ids
- categories
- store_discount
- store_discount.day
- store_discount.opening_time
- store_discount.closing_time
- schedules
- schedules.day
- schedules.opening_time
- schedules.closing_time
- vendor_id
- prescription_order
- cutlery
- slug
- announcement
- announcement_message
- total_items
- items
- items.id
- items.name
- items.image_full_url
- items.price
- items.discount
- items.discount_type
- top_items
- top_items.id
- top_items.name
- top_items.slug
- top_items.image_full_url
- top_items.thumbnail_full_url
- top_items.price
- top_items.base_price
- top_items.discounted_price
- top_items.discount
- top_items.discount_type
- top_items.avg_rating
- extra_packaging_status
- extra_packaging_amount
- ratings
- reviews_comments_count
- store_sub
- store_sub.chat
- store_business_model
- distance
- distance_km
- current_opening_time
- verified_seller
- avg_item_discount_percentage
- ad
- pro_discount
- pro_discount.start_date
- pro_discount.end_date
- pro_discount.min_purchase
- pro_discount.max_discount
- pro_discount.discount
- pro_discount.discount_type
- is_new
- sponsored
- offer_label
- store_item_image_list
- description
- active_coupons

<a id="api-v1-stores-popular-popularstoreuri"></a>
## Endpoint : /api/v1/stores/popular

- **Constant**: `AppConstants.popularStoreUri`
- **Repository**: `store_repository.dart:128`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- phone
- logo_full_url
- latitude
- longitude
- address
- minimum_order
- free_delivery
- cover_photo_full_url
- delivery
- take_away
- schedule_order
- avg_rating
- tax
- rating_count
- reviews_count
- self_delivery_system
- minimum_shipping_charge
- maximum_shipping_charge
- per_km_shipping_charge
- open
- active
- zone_id
- delivery_time
- veg
- non_veg
- module_id
- module_type
- order_place_to_schedule_interval
- category_ids
- categories
- store_discount
- store_discount.day
- store_discount.opening_time
- store_discount.closing_time
- schedules
- schedules.day
- schedules.opening_time
- schedules.closing_time
- vendor_id
- prescription_order
- cutlery
- slug
- announcement
- announcement_message
- total_items
- items
- items.id
- items.name
- items.image_full_url
- items.price
- items.discount
- items.discount_type
- top_items
- top_items.id
- top_items.name
- top_items.slug
- top_items.image_full_url
- top_items.thumbnail_full_url
- top_items.price
- top_items.base_price
- top_items.discounted_price
- top_items.discount
- top_items.discount_type
- top_items.avg_rating
- extra_packaging_status
- extra_packaging_amount
- ratings
- reviews_comments_count
- store_sub
- store_sub.chat
- store_business_model
- distance
- distance_km
- current_opening_time
- verified_seller
- avg_item_discount_percentage
- ad
- pro_discount
- pro_discount.start_date
- pro_discount.end_date
- pro_discount.min_purchase
- pro_discount.max_discount
- pro_discount.discount
- pro_discount.discount_type
- is_new
- sponsored
- offer_label
- store_item_image_list
- description
- active_coupons

<a id="api-v1-stores-quick-delivery-quickdeliverystoresuri"></a>
## Endpoint : /api/v1/stores/quick-delivery

- **Constant**: `AppConstants.quickDeliveryStoresUri`
- **Repository**: `store_repository.dart:57`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset

<a id="api-v1-stores-recommended-recommendedstoreuri"></a>
## Endpoint : /api/v1/stores/recommended

- **Constant**: `AppConstants.recommendedStoreUri`
- **Repository**: `store_repository.dart:342`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- phone
- logo_full_url
- latitude
- longitude
- address
- minimum_order
- free_delivery
- cover_photo_full_url
- delivery
- take_away
- schedule_order
- avg_rating
- tax
- rating_count
- reviews_count
- self_delivery_system
- minimum_shipping_charge
- maximum_shipping_charge
- per_km_shipping_charge
- open
- active
- zone_id
- delivery_time
- veg
- non_veg
- module_id
- module_type
- order_place_to_schedule_interval
- category_ids
- categories
- store_discount
- store_discount.day
- store_discount.opening_time
- store_discount.closing_time
- schedules
- schedules.day
- schedules.opening_time
- schedules.closing_time
- vendor_id
- prescription_order
- cutlery
- slug
- announcement
- announcement_message
- total_items
- items
- items.id
- items.name
- items.image_full_url
- items.price
- items.discount
- items.discount_type
- top_items
- top_items.id
- top_items.name
- top_items.slug
- top_items.image_full_url
- top_items.thumbnail_full_url
- top_items.price
- top_items.base_price
- top_items.discounted_price
- top_items.discount
- top_items.discount_type
- top_items.avg_rating
- extra_packaging_status
- extra_packaging_amount
- ratings
- reviews_comments_count
- store_sub
- store_sub.chat
- store_business_model
- distance
- distance_km
- current_opening_time
- verified_seller
- avg_item_discount_percentage
- ad
- pro_discount
- pro_discount.start_date
- pro_discount.end_date
- pro_discount.min_purchase
- pro_discount.max_discount
- pro_discount.discount
- pro_discount.discount_type
- is_new
- sponsored
- offer_label
- store_item_image_list
- description
- active_coupons

<a id="api-v1-stores-reviews-storereviewuri"></a>
## Endpoint : /api/v1/stores/reviews

- **Constant**: `AppConstants.storeReviewUri`
- **Repository**: `review_repository.dart:16`
- **Model**: `lib/features/review/domain/models/review_model.dart`
- **Parsed to model**: Yes

**Data:**

- comment
- rating
- item_name
- item_image_full_url
- customer_name
- created_at
- updated_at
- reply
- item
- item.id
- item.name
- item.description
- item.image_full_url
- item.video_link
- item.video_full_url
- item.video_preview_url
- item.video_thumbnail_url
- item.video_embed_url
- item.images_full_url
- item.category_id
- item.category_ids
- item.category_ids.id
- item.variations
- item.variations.type
- item.variations.price
- item.variations.stock
- item.food_variations
- item.food_variations.max
- item.food_variations.name
- item.food_variations.type
- item.food_variations.min
- item.food_variations.required
- item.food_variations.values
- item.food_variations.values.label
- item.food_variations.values.optionPrice
- item.food_variations.values.isSelected
- item.add_ons
- item.add_ons.id
- item.add_ons.name
- item.add_ons.price
- item.addons
- item.addons.id
- item.addons.name
- item.addons.price
- item.choice_options
- item.choice_options.title
- item.choice_options.options
- item.price
- item.discount
- item.discount_type
- item.available_time_starts
- item.available_time_ends
- item.store_id
- item.store_name
- item.zone_id
- item.schedule_order
- item.avg_rating
- item.rating_count
- item.module_id
- item.module_type
- item.veg
- item.stock
- item.unit_type
- item.available_date_starts
- item.organic
- item.maximum_cart_quantity
- item.flash_sale
- item.halal_tag_status
- item.is_halal
- item.is_prescription_required
- item.nutritions_name
- item.allergies_name
- item.generic_name
- item.store_details
- item.store_details.id
- item.store_details.name
- item.store_details.slug
- item.store_details.zone_id
- item.store_details.show_low_stock_count
- item.store_details.minimum_stock_for_warning
- item.slug
- item.verified_seller
- item.store_image_full_url
- item.store_logo_full_url
- item.free_delivery
- item.offer_label
- item.brand_name

<a id="api-v1-stores-top-offer-near-me-topofferstoreuri"></a>
## Endpoint : /api/v1/stores/top-offer-near-me

- **Constant**: `AppConstants.topOfferStoreUri`
- **Repository**: `store_repository.dart:178`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- phone
- logo_full_url
- latitude
- longitude
- address
- minimum_order
- free_delivery
- cover_photo_full_url
- delivery
- take_away
- schedule_order
- avg_rating
- tax
- rating_count
- reviews_count
- self_delivery_system
- minimum_shipping_charge
- maximum_shipping_charge
- per_km_shipping_charge
- open
- active
- zone_id
- delivery_time
- veg
- non_veg
- module_id
- module_type
- order_place_to_schedule_interval
- category_ids
- categories
- store_discount
- store_discount.day
- store_discount.opening_time
- store_discount.closing_time
- schedules
- schedules.day
- schedules.opening_time
- schedules.closing_time
- vendor_id
- prescription_order
- cutlery
- slug
- announcement
- announcement_message
- total_items
- items
- items.id
- items.name
- items.image_full_url
- items.price
- items.discount
- items.discount_type
- top_items
- top_items.id
- top_items.name
- top_items.slug
- top_items.image_full_url
- top_items.thumbnail_full_url
- top_items.price
- top_items.base_price
- top_items.discounted_price
- top_items.discount
- top_items.discount_type
- top_items.avg_rating
- extra_packaging_status
- extra_packaging_amount
- ratings
- reviews_comments_count
- store_sub
- store_sub.chat
- store_business_model
- distance
- distance_km
- current_opening_time
- verified_seller
- avg_item_discount_percentage
- ad
- pro_discount
- pro_discount.start_date
- pro_discount.end_date
- pro_discount.min_purchase
- pro_discount.max_discount
- pro_discount.discount
- pro_discount.discount_type
- is_new
- sponsored
- offer_label
- store_item_image_list
- description
- active_coupons

<a id="api-v1-stores-verified-serviceverifiedprovidersuri"></a>
## Endpoint : /api/v1/stores/verified

- **Constant**: `AppConstants.serviceVerifiedProvidersUri`
- **Repository**: `store_repository.dart:82`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset


---

# Promotions

<a id="api-v1-advertisement-list-advertisementlisturi"></a>
## Endpoint : /api/v1/advertisement/list

- **Constant**: `AppConstants.advertisementListUri`
- **Repository**: `advertisement_repository.dart:23`
- **Model**: `lib/features/home/domain/models/advertisement_model.dart`
- **Parsed to model**: Yes

**Data:**

- store_id
- add_type
- title
- description
- is_rating_active
- is_review_active
- cover_image_full_url
- profile_image_full_url
- video_attachment_full_url
- average_rating
- reviews_comments_count

<a id="api-v1-banners-servicebannersuri"></a>
## Endpoint : /api/v1/banners  — `serviceBannersUri`

- **Constant**: `AppConstants.serviceBannersUri`
- **Repository**: `service_repository.dart:47`
- **Model**: `lib/features/service_module/service_home/domain/models/service_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- campaigns
- campaigns.id
- campaigns.title
- campaigns.image_full_url
- campaigns.description
- campaigns.available_date_starts
- campaigns.available_date_ends
- campaigns.start_time
- campaigns.end_time
- campaigns.stores
- campaigns.stores.id
- campaigns.stores.name
- campaigns.stores.phone
- campaigns.stores.logo_full_url
- campaigns.stores.latitude
- campaigns.stores.longitude
- campaigns.stores.address
- campaigns.stores.minimum_order
- campaigns.stores.free_delivery
- campaigns.stores.cover_photo_full_url
- campaigns.stores.delivery
- campaigns.stores.take_away
- campaigns.stores.schedule_order
- campaigns.stores.avg_rating
- campaigns.stores.tax
- campaigns.stores.rating_count
- campaigns.stores.reviews_count
- campaigns.stores.self_delivery_system
- campaigns.stores.minimum_shipping_charge
- campaigns.stores.maximum_shipping_charge
- campaigns.stores.per_km_shipping_charge
- campaigns.stores.open
- campaigns.stores.active
- campaigns.stores.zone_id
- campaigns.stores.delivery_time
- campaigns.stores.veg
- campaigns.stores.non_veg
- campaigns.stores.module_id
- campaigns.stores.module_type
- campaigns.stores.order_place_to_schedule_interval
- campaigns.stores.category_ids
- campaigns.stores.categories
- campaigns.stores.store_discount
- campaigns.stores.store_discount.day
- campaigns.stores.store_discount.opening_time
- campaigns.stores.store_discount.closing_time
- campaigns.stores.schedules
- campaigns.stores.schedules.day
- campaigns.stores.schedules.opening_time
- campaigns.stores.schedules.closing_time
- campaigns.stores.vendor_id
- campaigns.stores.prescription_order
- campaigns.stores.cutlery
- campaigns.stores.slug
- campaigns.stores.announcement
- campaigns.stores.announcement_message
- campaigns.stores.total_items
- campaigns.stores.items
- campaigns.stores.items.id
- campaigns.stores.items.name
- campaigns.stores.items.image_full_url
- campaigns.stores.items.price
- campaigns.stores.items.discount
- campaigns.stores.items.discount_type
- campaigns.stores.top_items
- campaigns.stores.top_items.id
- campaigns.stores.top_items.name
- campaigns.stores.top_items.slug
- campaigns.stores.top_items.image_full_url
- campaigns.stores.top_items.thumbnail_full_url
- campaigns.stores.top_items.price
- campaigns.stores.top_items.base_price
- campaigns.stores.top_items.discounted_price
- campaigns.stores.top_items.discount
- campaigns.stores.top_items.discount_type
- campaigns.stores.top_items.avg_rating
- campaigns.stores.extra_packaging_status
- campaigns.stores.extra_packaging_amount
- campaigns.stores.ratings
- campaigns.stores.reviews_comments_count
- campaigns.stores.store_sub
- campaigns.stores.store_sub.chat
- campaigns.stores.store_business_model
- campaigns.stores.distance
- campaigns.stores.distance_km
- campaigns.stores.current_opening_time
- campaigns.stores.verified_seller
- campaigns.stores.avg_item_discount_percentage
- campaigns.stores.ad
- campaigns.stores.pro_discount
- campaigns.stores.pro_discount.start_date
- campaigns.stores.pro_discount.end_date
- campaigns.stores.pro_discount.min_purchase
- campaigns.stores.pro_discount.max_discount
- campaigns.stores.pro_discount.discount
- campaigns.stores.pro_discount.discount_type
- campaigns.stores.is_new
- campaigns.stores.sponsored
- campaigns.stores.offer_label
- campaigns.stores.store_item_image_list
- campaigns.stores.description
- campaigns.stores.active_coupons
- banners
- banners.type
- banners.image_full_url
- banners.link
- banners.service
- banners.service.id
- banners.service.name
- banners.service.slug
- banners.service.short_description
- banners.service.long_description
- banners.service.thumbnail_full_url
- banners.service.additional_images_full_url
- banners.service.base_price
- banners.service.discount
- banners.service.discount_type
- banners.service.discounted_price
- banners.service.variations
- banners.service.variations.variant_key
- banners.service.variations.name
- banners.service.variations.price
- banners.service.variations.discount
- banners.service.variations.discount_type
- banners.service.avg_rating
- banners.service.rating_count
- banners.service.module_id
- banners.service.store_id
- banners.service.store_name
- banners.service.provider_image_full_url
- banners.service.verified_provider
- banners.service.distance_km
- banners.service.provider
- banners.service.provider.discount
- banners.service.provider.id
- banners.service.provider.name
- banners.service.provider.slug
- banners.service.provider.logo_full_url
- banners.service.provider.cover_photo_full_url
- banners.service.provider.address
- banners.service.provider.phone
- banners.service.provider.latitude
- banners.service.provider.longitude
- banners.service.provider.avg_rating
- banners.service.provider.rating_count
- banners.service.provider.open
- banners.service.provider.active
- banners.service.provider.schedules
- banners.service.provider.distance
- banners.service.provider.verified_seller
- banners.service.provider.ad
- banners.service.provider.announcement
- banners.service.provider.announcement_message
- banners.service.provider.sub_title
- banners.service.provider.tagline
- banners.service.provider.discount_type
- banners.service.provider.order_count
- banners.service.provider.coupons
- banners.service.provider.instant_booking
- banners.service.provider.repeat_booking
- banners.service.provider.schedule_booking
- banners.service.provider.distance_km
- banners.service.faqs
- banners.service.faqs.question
- banners.service.faqs.answer
- banners.service.total_reviews
- banners.service.reviews
- banners.service.reviews.rating
- banners.service.reviews.comment
- banners.service.reviews.attachment
- banners.service.reviews.reply
- banners.service.reviews.item_name
- banners.service.reviews.item_image_full_url
- banners.service.reviews.created_at
- banners.service.reviews.service_name
- banners.service.reviews.service_image_full_url
- banners.service.reviews.customer
- banners.service.reviews.review_date
- banners.service.is_favorite
- banners.service.is_favourite
- banners.provider
- banners.provider.discount
- banners.provider.discount.discount_amount
- banners.provider.discount.discount_amount_type
- banners.provider.id
- banners.provider.name
- banners.provider.slug
- banners.provider.logo_full_url
- banners.provider.cover_photo_full_url
- banners.provider.address
- banners.provider.phone
- banners.provider.latitude
- banners.provider.longitude
- banners.provider.avg_rating
- banners.provider.rating_count
- banners.provider.open
- banners.provider.active
- banners.provider.schedules
- banners.provider.schedules.day
- banners.provider.schedules.opening_time
- banners.provider.schedules.closing_time
- banners.provider.distance
- banners.provider.verified_seller
- banners.provider.ad
- banners.provider.announcement
- banners.provider.announcement_message
- banners.provider.sub_title
- banners.provider.tagline
- banners.provider.discount_type
- banners.provider.order_count
- banners.provider.coupons
- banners.provider.coupons.title
- banners.provider.coupons.code
- banners.provider.coupons.start_date
- banners.provider.coupons.expire_date
- banners.provider.coupons.min_purchase
- banners.provider.coupons.max_discount
- banners.provider.coupons.discount
- banners.provider.coupons.discount_type
- banners.provider.coupons.coupon_type
- banners.provider.coupons.data
- banners.provider.coupons.store_id
- banners.provider.coupons.store_new
- banners.provider.instant_booking
- banners.provider.repeat_booking
- banners.provider.schedule_booking
- banners.provider.distance_km
- banners.store_id

<a id="api-v1-banners-banneruri"></a>
## Endpoint : /api/v1/banners  — `bannerUri`

- **Constant**: `AppConstants.bannerUri`
- **Repository**: `banner_repository.dart:40`
- **Model**: `lib/features/banner/domain/models/banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- campaigns
- campaigns.id
- campaigns.title
- campaigns.image_full_url
- campaigns.description
- campaigns.available_date_starts
- campaigns.available_date_ends
- campaigns.start_time
- campaigns.end_time
- campaigns.stores
- campaigns.stores.id
- campaigns.stores.name
- campaigns.stores.phone
- campaigns.stores.logo_full_url
- campaigns.stores.latitude
- campaigns.stores.longitude
- campaigns.stores.address
- campaigns.stores.minimum_order
- campaigns.stores.free_delivery
- campaigns.stores.cover_photo_full_url
- campaigns.stores.delivery
- campaigns.stores.take_away
- campaigns.stores.schedule_order
- campaigns.stores.avg_rating
- campaigns.stores.tax
- campaigns.stores.rating_count
- campaigns.stores.reviews_count
- campaigns.stores.self_delivery_system
- campaigns.stores.minimum_shipping_charge
- campaigns.stores.maximum_shipping_charge
- campaigns.stores.per_km_shipping_charge
- campaigns.stores.open
- campaigns.stores.active
- campaigns.stores.zone_id
- campaigns.stores.delivery_time
- campaigns.stores.veg
- campaigns.stores.non_veg
- campaigns.stores.module_id
- campaigns.stores.module_type
- campaigns.stores.order_place_to_schedule_interval
- campaigns.stores.category_ids
- campaigns.stores.categories
- campaigns.stores.store_discount
- campaigns.stores.store_discount.day
- campaigns.stores.store_discount.opening_time
- campaigns.stores.store_discount.closing_time
- campaigns.stores.schedules
- campaigns.stores.schedules.day
- campaigns.stores.schedules.opening_time
- campaigns.stores.schedules.closing_time
- campaigns.stores.vendor_id
- campaigns.stores.prescription_order
- campaigns.stores.cutlery
- campaigns.stores.slug
- campaigns.stores.announcement
- campaigns.stores.announcement_message
- campaigns.stores.total_items
- campaigns.stores.items
- campaigns.stores.items.id
- campaigns.stores.items.name
- campaigns.stores.items.image_full_url
- campaigns.stores.items.price
- campaigns.stores.items.discount
- campaigns.stores.items.discount_type
- campaigns.stores.top_items
- campaigns.stores.top_items.id
- campaigns.stores.top_items.name
- campaigns.stores.top_items.slug
- campaigns.stores.top_items.image_full_url
- campaigns.stores.top_items.thumbnail_full_url
- campaigns.stores.top_items.price
- campaigns.stores.top_items.base_price
- campaigns.stores.top_items.discounted_price
- campaigns.stores.top_items.discount
- campaigns.stores.top_items.discount_type
- campaigns.stores.top_items.avg_rating
- campaigns.stores.extra_packaging_status
- campaigns.stores.extra_packaging_amount
- campaigns.stores.ratings
- campaigns.stores.reviews_comments_count
- campaigns.stores.store_sub
- campaigns.stores.store_sub.chat
- campaigns.stores.store_business_model
- campaigns.stores.distance
- campaigns.stores.distance_km
- campaigns.stores.current_opening_time
- campaigns.stores.verified_seller
- campaigns.stores.avg_item_discount_percentage
- campaigns.stores.ad
- campaigns.stores.pro_discount
- campaigns.stores.pro_discount.start_date
- campaigns.stores.pro_discount.end_date
- campaigns.stores.pro_discount.min_purchase
- campaigns.stores.pro_discount.max_discount
- campaigns.stores.pro_discount.discount
- campaigns.stores.pro_discount.discount_type
- campaigns.stores.is_new
- campaigns.stores.sponsored
- campaigns.stores.offer_label
- campaigns.stores.store_item_image_list
- campaigns.stores.description
- campaigns.stores.active_coupons
- banners
- banners.type
- banners.image_full_url
- banners.link
- banners.store
- banners.store.id
- banners.store.name
- banners.store.phone
- banners.store.logo_full_url
- banners.store.latitude
- banners.store.longitude
- banners.store.address
- banners.store.minimum_order
- banners.store.free_delivery
- banners.store.cover_photo_full_url
- banners.store.delivery
- banners.store.take_away
- banners.store.schedule_order
- banners.store.avg_rating
- banners.store.tax
- banners.store.rating_count
- banners.store.reviews_count
- banners.store.self_delivery_system
- banners.store.minimum_shipping_charge
- banners.store.maximum_shipping_charge
- banners.store.per_km_shipping_charge
- banners.store.open
- banners.store.active
- banners.store.zone_id
- banners.store.delivery_time
- banners.store.veg
- banners.store.non_veg
- banners.store.module_id
- banners.store.module_type
- banners.store.order_place_to_schedule_interval
- banners.store.category_ids
- banners.store.categories
- banners.store.store_discount
- banners.store.store_discount.day
- banners.store.store_discount.opening_time
- banners.store.store_discount.closing_time
- banners.store.schedules
- banners.store.schedules.day
- banners.store.schedules.opening_time
- banners.store.schedules.closing_time
- banners.store.vendor_id
- banners.store.prescription_order
- banners.store.cutlery
- banners.store.slug
- banners.store.announcement
- banners.store.announcement_message
- banners.store.total_items
- banners.store.items
- banners.store.items.id
- banners.store.items.name
- banners.store.items.image_full_url
- banners.store.items.price
- banners.store.items.discount
- banners.store.items.discount_type
- banners.store.top_items
- banners.store.top_items.id
- banners.store.top_items.name
- banners.store.top_items.slug
- banners.store.top_items.image_full_url
- banners.store.top_items.thumbnail_full_url
- banners.store.top_items.price
- banners.store.top_items.base_price
- banners.store.top_items.discounted_price
- banners.store.top_items.discount
- banners.store.top_items.discount_type
- banners.store.top_items.avg_rating
- banners.store.extra_packaging_status
- banners.store.extra_packaging_amount
- banners.store.ratings
- banners.store.reviews_comments_count
- banners.store.store_sub
- banners.store.store_sub.chat
- banners.store.store_business_model
- banners.store.distance
- banners.store.distance_km
- banners.store.current_opening_time
- banners.store.verified_seller
- banners.store.avg_item_discount_percentage
- banners.store.ad
- banners.store.pro_discount
- banners.store.pro_discount.start_date
- banners.store.pro_discount.end_date
- banners.store.pro_discount.min_purchase
- banners.store.pro_discount.max_discount
- banners.store.pro_discount.discount
- banners.store.pro_discount.discount_type
- banners.store.is_new
- banners.store.sponsored
- banners.store.offer_label
- banners.store.store_item_image_list
- banners.store.description
- banners.store.active_coupons
- banners.store_new
- banners.store_new.id
- banners.store_new.name
- banners.store_new.phone
- banners.store_new.logo_full_url
- banners.store_new.latitude
- banners.store_new.longitude
- banners.store_new.address
- banners.store_new.minimum_order
- banners.store_new.free_delivery
- banners.store_new.cover_photo_full_url
- banners.store_new.delivery
- banners.store_new.take_away
- banners.store_new.schedule_order
- banners.store_new.avg_rating
- banners.store_new.tax
- banners.store_new.rating_count
- banners.store_new.reviews_count
- banners.store_new.self_delivery_system
- banners.store_new.minimum_shipping_charge
- banners.store_new.maximum_shipping_charge
- banners.store_new.per_km_shipping_charge
- banners.store_new.open
- banners.store_new.active
- banners.store_new.zone_id
- banners.store_new.delivery_time
- banners.store_new.veg
- banners.store_new.non_veg
- banners.store_new.module_id
- banners.store_new.module_type
- banners.store_new.order_place_to_schedule_interval
- banners.store_new.category_ids
- banners.store_new.categories
- banners.store_new.store_discount
- banners.store_new.store_discount.day
- banners.store_new.store_discount.opening_time
- banners.store_new.store_discount.closing_time
- banners.store_new.schedules
- banners.store_new.schedules.day
- banners.store_new.schedules.opening_time
- banners.store_new.schedules.closing_time
- banners.store_new.vendor_id
- banners.store_new.prescription_order
- banners.store_new.cutlery
- banners.store_new.slug
- banners.store_new.announcement
- banners.store_new.announcement_message
- banners.store_new.total_items
- banners.store_new.items
- banners.store_new.items.id
- banners.store_new.items.name
- banners.store_new.items.image_full_url
- banners.store_new.items.price
- banners.store_new.items.discount
- banners.store_new.items.discount_type
- banners.store_new.top_items
- banners.store_new.top_items.id
- banners.store_new.top_items.name
- banners.store_new.top_items.slug
- banners.store_new.top_items.image_full_url
- banners.store_new.top_items.thumbnail_full_url
- banners.store_new.top_items.price
- banners.store_new.top_items.base_price
- banners.store_new.top_items.discounted_price
- banners.store_new.top_items.discount
- banners.store_new.top_items.discount_type
- banners.store_new.top_items.avg_rating
- banners.store_new.extra_packaging_status
- banners.store_new.extra_packaging_amount
- banners.store_new.ratings
- banners.store_new.reviews_comments_count
- banners.store_new.store_sub
- banners.store_new.store_sub.chat
- banners.store_new.store_business_model
- banners.store_new.distance
- banners.store_new.distance_km
- banners.store_new.current_opening_time
- banners.store_new.verified_seller
- banners.store_new.avg_item_discount_percentage
- banners.store_new.ad
- banners.store_new.pro_discount
- banners.store_new.pro_discount.start_date
- banners.store_new.pro_discount.end_date
- banners.store_new.pro_discount.min_purchase
- banners.store_new.pro_discount.max_discount
- banners.store_new.pro_discount.discount
- banners.store_new.pro_discount.discount_type
- banners.store_new.is_new
- banners.store_new.sponsored
- banners.store_new.offer_label
- banners.store_new.store_item_image_list
- banners.store_new.description
- banners.store_new.active_coupons
- banners.item
- banners.item.id
- banners.item.name
- banners.item.description
- banners.item.image_full_url
- banners.item.video_link
- banners.item.video_full_url
- banners.item.video_preview_url
- banners.item.video_thumbnail_url
- banners.item.video_embed_url
- banners.item.images_full_url
- banners.item.category_id
- banners.item.category_ids
- banners.item.category_ids.id
- banners.item.variations
- banners.item.variations.type
- banners.item.variations.price
- banners.item.variations.stock
- banners.item.food_variations
- banners.item.food_variations.max
- banners.item.food_variations.name
- banners.item.food_variations.type
- banners.item.food_variations.min
- banners.item.food_variations.required
- banners.item.food_variations.values
- banners.item.add_ons
- banners.item.add_ons.id
- banners.item.add_ons.name
- banners.item.add_ons.price
- banners.item.addons
- banners.item.addons.id
- banners.item.addons.name
- banners.item.addons.price
- banners.item.choice_options
- banners.item.choice_options.title
- banners.item.choice_options.options
- banners.item.price
- banners.item.discount
- banners.item.discount_type
- banners.item.available_time_starts
- banners.item.available_time_ends
- banners.item.store_id
- banners.item.store_name
- banners.item.zone_id
- banners.item.schedule_order
- banners.item.avg_rating
- banners.item.rating_count
- banners.item.module_id
- banners.item.module_type
- banners.item.veg
- banners.item.stock
- banners.item.unit_type
- banners.item.available_date_starts
- banners.item.organic
- banners.item.maximum_cart_quantity
- banners.item.flash_sale
- banners.item.halal_tag_status
- banners.item.is_halal
- banners.item.is_prescription_required
- banners.item.nutritions_name
- banners.item.allergies_name
- banners.item.generic_name
- banners.item.store_details
- banners.item.store_details.id
- banners.item.store_details.name
- banners.item.store_details.slug
- banners.item.store_details.zone_id
- banners.item.store_details.show_low_stock_count
- banners.item.store_details.minimum_stock_for_warning
- banners.item.slug
- banners.item.verified_seller
- banners.item.store_image_full_url
- banners.item.store_logo_full_url
- banners.item.free_delivery
- banners.item.offer_label
- banners.item.brand_name

<a id="api-v1-banners-storebannersuri"></a>
## Endpoint : /api/v1/banners/

- **Constant**: `AppConstants.storeBannersUri`
- **Repository**: `store_repository.dart:328` — _getStoreBannerList
- **Model**: `lib/features/store/domain/models/store_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- title
- type
- image_full_url
- data
- default_link

<a id="api-v1-banners-taxi-taxibanneruri"></a>
## Endpoint : /api/v1/banners/taxi

- **Constant**: `AppConstants.taxiBannerUri`
- **Repository**: `banner_repository.dart:60` — _getTaxiBannerList
- **Model**: `lib/features/banner/domain/models/banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- campaigns
- campaigns.id
- campaigns.title
- campaigns.image_full_url
- campaigns.description
- campaigns.available_date_starts
- campaigns.available_date_ends
- campaigns.start_time
- campaigns.end_time
- campaigns.stores
- campaigns.stores.id
- campaigns.stores.name
- campaigns.stores.phone
- campaigns.stores.logo_full_url
- campaigns.stores.latitude
- campaigns.stores.longitude
- campaigns.stores.address
- campaigns.stores.minimum_order
- campaigns.stores.free_delivery
- campaigns.stores.cover_photo_full_url
- campaigns.stores.delivery
- campaigns.stores.take_away
- campaigns.stores.schedule_order
- campaigns.stores.avg_rating
- campaigns.stores.tax
- campaigns.stores.rating_count
- campaigns.stores.reviews_count
- campaigns.stores.self_delivery_system
- campaigns.stores.minimum_shipping_charge
- campaigns.stores.maximum_shipping_charge
- campaigns.stores.per_km_shipping_charge
- campaigns.stores.open
- campaigns.stores.active
- campaigns.stores.zone_id
- campaigns.stores.delivery_time
- campaigns.stores.veg
- campaigns.stores.non_veg
- campaigns.stores.module_id
- campaigns.stores.module_type
- campaigns.stores.order_place_to_schedule_interval
- campaigns.stores.category_ids
- campaigns.stores.categories
- campaigns.stores.store_discount
- campaigns.stores.store_discount.day
- campaigns.stores.store_discount.opening_time
- campaigns.stores.store_discount.closing_time
- campaigns.stores.schedules
- campaigns.stores.schedules.day
- campaigns.stores.schedules.opening_time
- campaigns.stores.schedules.closing_time
- campaigns.stores.vendor_id
- campaigns.stores.prescription_order
- campaigns.stores.cutlery
- campaigns.stores.slug
- campaigns.stores.announcement
- campaigns.stores.announcement_message
- campaigns.stores.total_items
- campaigns.stores.items
- campaigns.stores.items.id
- campaigns.stores.items.name
- campaigns.stores.items.image_full_url
- campaigns.stores.items.price
- campaigns.stores.items.discount
- campaigns.stores.items.discount_type
- campaigns.stores.top_items
- campaigns.stores.top_items.id
- campaigns.stores.top_items.name
- campaigns.stores.top_items.slug
- campaigns.stores.top_items.image_full_url
- campaigns.stores.top_items.thumbnail_full_url
- campaigns.stores.top_items.price
- campaigns.stores.top_items.base_price
- campaigns.stores.top_items.discounted_price
- campaigns.stores.top_items.discount
- campaigns.stores.top_items.discount_type
- campaigns.stores.top_items.avg_rating
- campaigns.stores.extra_packaging_status
- campaigns.stores.extra_packaging_amount
- campaigns.stores.ratings
- campaigns.stores.reviews_comments_count
- campaigns.stores.store_sub
- campaigns.stores.store_sub.chat
- campaigns.stores.store_business_model
- campaigns.stores.distance
- campaigns.stores.distance_km
- campaigns.stores.current_opening_time
- campaigns.stores.verified_seller
- campaigns.stores.avg_item_discount_percentage
- campaigns.stores.ad
- campaigns.stores.pro_discount
- campaigns.stores.pro_discount.start_date
- campaigns.stores.pro_discount.end_date
- campaigns.stores.pro_discount.min_purchase
- campaigns.stores.pro_discount.max_discount
- campaigns.stores.pro_discount.discount
- campaigns.stores.pro_discount.discount_type
- campaigns.stores.is_new
- campaigns.stores.sponsored
- campaigns.stores.offer_label
- campaigns.stores.store_item_image_list
- campaigns.stores.description
- campaigns.stores.active_coupons
- banners
- banners.type
- banners.image_full_url
- banners.link
- banners.store
- banners.store.id
- banners.store.name
- banners.store.phone
- banners.store.logo_full_url
- banners.store.latitude
- banners.store.longitude
- banners.store.address
- banners.store.minimum_order
- banners.store.free_delivery
- banners.store.cover_photo_full_url
- banners.store.delivery
- banners.store.take_away
- banners.store.schedule_order
- banners.store.avg_rating
- banners.store.tax
- banners.store.rating_count
- banners.store.reviews_count
- banners.store.self_delivery_system
- banners.store.minimum_shipping_charge
- banners.store.maximum_shipping_charge
- banners.store.per_km_shipping_charge
- banners.store.open
- banners.store.active
- banners.store.zone_id
- banners.store.delivery_time
- banners.store.veg
- banners.store.non_veg
- banners.store.module_id
- banners.store.module_type
- banners.store.order_place_to_schedule_interval
- banners.store.category_ids
- banners.store.categories
- banners.store.store_discount
- banners.store.store_discount.day
- banners.store.store_discount.opening_time
- banners.store.store_discount.closing_time
- banners.store.schedules
- banners.store.schedules.day
- banners.store.schedules.opening_time
- banners.store.schedules.closing_time
- banners.store.vendor_id
- banners.store.prescription_order
- banners.store.cutlery
- banners.store.slug
- banners.store.announcement
- banners.store.announcement_message
- banners.store.total_items
- banners.store.items
- banners.store.items.id
- banners.store.items.name
- banners.store.items.image_full_url
- banners.store.items.price
- banners.store.items.discount
- banners.store.items.discount_type
- banners.store.top_items
- banners.store.top_items.id
- banners.store.top_items.name
- banners.store.top_items.slug
- banners.store.top_items.image_full_url
- banners.store.top_items.thumbnail_full_url
- banners.store.top_items.price
- banners.store.top_items.base_price
- banners.store.top_items.discounted_price
- banners.store.top_items.discount
- banners.store.top_items.discount_type
- banners.store.top_items.avg_rating
- banners.store.extra_packaging_status
- banners.store.extra_packaging_amount
- banners.store.ratings
- banners.store.reviews_comments_count
- banners.store.store_sub
- banners.store.store_sub.chat
- banners.store.store_business_model
- banners.store.distance
- banners.store.distance_km
- banners.store.current_opening_time
- banners.store.verified_seller
- banners.store.avg_item_discount_percentage
- banners.store.ad
- banners.store.pro_discount
- banners.store.pro_discount.start_date
- banners.store.pro_discount.end_date
- banners.store.pro_discount.min_purchase
- banners.store.pro_discount.max_discount
- banners.store.pro_discount.discount
- banners.store.pro_discount.discount_type
- banners.store.is_new
- banners.store.sponsored
- banners.store.offer_label
- banners.store.store_item_image_list
- banners.store.description
- banners.store.active_coupons
- banners.store_new
- banners.store_new.id
- banners.store_new.name
- banners.store_new.phone
- banners.store_new.logo_full_url
- banners.store_new.latitude
- banners.store_new.longitude
- banners.store_new.address
- banners.store_new.minimum_order
- banners.store_new.free_delivery
- banners.store_new.cover_photo_full_url
- banners.store_new.delivery
- banners.store_new.take_away
- banners.store_new.schedule_order
- banners.store_new.avg_rating
- banners.store_new.tax
- banners.store_new.rating_count
- banners.store_new.reviews_count
- banners.store_new.self_delivery_system
- banners.store_new.minimum_shipping_charge
- banners.store_new.maximum_shipping_charge
- banners.store_new.per_km_shipping_charge
- banners.store_new.open
- banners.store_new.active
- banners.store_new.zone_id
- banners.store_new.delivery_time
- banners.store_new.veg
- banners.store_new.non_veg
- banners.store_new.module_id
- banners.store_new.module_type
- banners.store_new.order_place_to_schedule_interval
- banners.store_new.category_ids
- banners.store_new.categories
- banners.store_new.store_discount
- banners.store_new.store_discount.day
- banners.store_new.store_discount.opening_time
- banners.store_new.store_discount.closing_time
- banners.store_new.schedules
- banners.store_new.schedules.day
- banners.store_new.schedules.opening_time
- banners.store_new.schedules.closing_time
- banners.store_new.vendor_id
- banners.store_new.prescription_order
- banners.store_new.cutlery
- banners.store_new.slug
- banners.store_new.announcement
- banners.store_new.announcement_message
- banners.store_new.total_items
- banners.store_new.items
- banners.store_new.items.id
- banners.store_new.items.name
- banners.store_new.items.image_full_url
- banners.store_new.items.price
- banners.store_new.items.discount
- banners.store_new.items.discount_type
- banners.store_new.top_items
- banners.store_new.top_items.id
- banners.store_new.top_items.name
- banners.store_new.top_items.slug
- banners.store_new.top_items.image_full_url
- banners.store_new.top_items.thumbnail_full_url
- banners.store_new.top_items.price
- banners.store_new.top_items.base_price
- banners.store_new.top_items.discounted_price
- banners.store_new.top_items.discount
- banners.store_new.top_items.discount_type
- banners.store_new.top_items.avg_rating
- banners.store_new.extra_packaging_status
- banners.store_new.extra_packaging_amount
- banners.store_new.ratings
- banners.store_new.reviews_comments_count
- banners.store_new.store_sub
- banners.store_new.store_sub.chat
- banners.store_new.store_business_model
- banners.store_new.distance
- banners.store_new.distance_km
- banners.store_new.current_opening_time
- banners.store_new.verified_seller
- banners.store_new.avg_item_discount_percentage
- banners.store_new.ad
- banners.store_new.pro_discount
- banners.store_new.pro_discount.start_date
- banners.store_new.pro_discount.end_date
- banners.store_new.pro_discount.min_purchase
- banners.store_new.pro_discount.max_discount
- banners.store_new.pro_discount.discount
- banners.store_new.pro_discount.discount_type
- banners.store_new.is_new
- banners.store_new.sponsored
- banners.store_new.offer_label
- banners.store_new.store_item_image_list
- banners.store_new.description
- banners.store_new.active_coupons
- banners.item
- banners.item.id
- banners.item.name
- banners.item.description
- banners.item.image_full_url
- banners.item.video_link
- banners.item.video_full_url
- banners.item.video_preview_url
- banners.item.video_thumbnail_url
- banners.item.video_embed_url
- banners.item.images_full_url
- banners.item.category_id
- banners.item.category_ids
- banners.item.category_ids.id
- banners.item.variations
- banners.item.variations.type
- banners.item.variations.price
- banners.item.variations.stock
- banners.item.food_variations
- banners.item.food_variations.max
- banners.item.food_variations.name
- banners.item.food_variations.type
- banners.item.food_variations.min
- banners.item.food_variations.required
- banners.item.food_variations.values
- banners.item.add_ons
- banners.item.add_ons.id
- banners.item.add_ons.name
- banners.item.add_ons.price
- banners.item.addons
- banners.item.addons.id
- banners.item.addons.name
- banners.item.addons.price
- banners.item.choice_options
- banners.item.choice_options.title
- banners.item.choice_options.options
- banners.item.price
- banners.item.discount
- banners.item.discount_type
- banners.item.available_time_starts
- banners.item.available_time_ends
- banners.item.store_id
- banners.item.store_name
- banners.item.zone_id
- banners.item.schedule_order
- banners.item.avg_rating
- banners.item.rating_count
- banners.item.module_id
- banners.item.module_type
- banners.item.veg
- banners.item.stock
- banners.item.unit_type
- banners.item.available_date_starts
- banners.item.organic
- banners.item.maximum_cart_quantity
- banners.item.flash_sale
- banners.item.halal_tag_status
- banners.item.is_halal
- banners.item.is_prescription_required
- banners.item.nutritions_name
- banners.item.allergies_name
- banners.item.generic_name
- banners.item.store_details
- banners.item.store_details.id
- banners.item.store_details.name
- banners.item.store_details.slug
- banners.item.store_details.zone_id
- banners.item.store_details.show_low_stock_count
- banners.item.store_details.minimum_stock_for_warning
- banners.item.slug
- banners.item.verified_seller
- banners.item.store_image_full_url
- banners.item.store_logo_full_url
- banners.item.free_delivery
- banners.item.offer_label
- banners.item.brand_name

<a id="api-v1-campaigns-basic-basiccampaignuri"></a>
## Endpoint : /api/v1/campaigns/basic

- **Constant**: `AppConstants.basicCampaignUri`
- **Repository**: `campaign_repository.dart:32` — _getBasicCampaignList
- **Model**: `lib/features/item/domain/models/basic_campaign_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- title
- image_full_url
- description
- available_date_starts
- available_date_ends
- start_time
- end_time
- stores
- stores.id
- stores.name
- stores.phone
- stores.logo_full_url
- stores.latitude
- stores.longitude
- stores.address
- stores.minimum_order
- stores.free_delivery
- stores.cover_photo_full_url
- stores.delivery
- stores.take_away
- stores.schedule_order
- stores.avg_rating
- stores.tax
- stores.rating_count
- stores.reviews_count
- stores.self_delivery_system
- stores.minimum_shipping_charge
- stores.maximum_shipping_charge
- stores.per_km_shipping_charge
- stores.open
- stores.active
- stores.zone_id
- stores.delivery_time
- stores.veg
- stores.non_veg
- stores.module_id
- stores.module_type
- stores.order_place_to_schedule_interval
- stores.category_ids
- stores.categories
- stores.store_discount
- stores.store_discount.day
- stores.store_discount.opening_time
- stores.store_discount.closing_time
- stores.schedules
- stores.schedules.day
- stores.schedules.opening_time
- stores.schedules.closing_time
- stores.vendor_id
- stores.prescription_order
- stores.cutlery
- stores.slug
- stores.announcement
- stores.announcement_message
- stores.total_items
- stores.items
- stores.items.id
- stores.items.name
- stores.items.image_full_url
- stores.items.price
- stores.items.discount
- stores.items.discount_type
- stores.top_items
- stores.top_items.id
- stores.top_items.name
- stores.top_items.slug
- stores.top_items.image_full_url
- stores.top_items.thumbnail_full_url
- stores.top_items.price
- stores.top_items.base_price
- stores.top_items.discounted_price
- stores.top_items.discount
- stores.top_items.discount_type
- stores.top_items.avg_rating
- stores.extra_packaging_status
- stores.extra_packaging_amount
- stores.ratings
- stores.reviews_comments_count
- stores.store_sub
- stores.store_sub.chat
- stores.store_business_model
- stores.distance
- stores.distance_km
- stores.current_opening_time
- stores.verified_seller
- stores.avg_item_discount_percentage
- stores.ad
- stores.pro_discount
- stores.pro_discount.start_date
- stores.pro_discount.end_date
- stores.pro_discount.min_purchase
- stores.pro_discount.max_discount
- stores.pro_discount.discount
- stores.pro_discount.discount_type
- stores.is_new
- stores.sponsored
- stores.offer_label
- stores.store_item_image_list
- stores.description
- stores.active_coupons

<a id="api-v1-campaigns-basic-campaign-details-basic-campaign-id-basiccampaigndetailsuri"></a>
## Endpoint : /api/v1/campaigns/basic-campaign-details?basic_campaign_id=

- **Constant**: `AppConstants.basicCampaignDetailsUri`
- **Repository**: `campaign_repository.dart:77` — get
- **Model**: `lib/features/item/domain/models/basic_campaign_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- title
- image_full_url
- description
- available_date_starts
- available_date_ends
- start_time
- end_time
- stores
- stores.id
- stores.name
- stores.phone
- stores.logo_full_url
- stores.latitude
- stores.longitude
- stores.address
- stores.minimum_order
- stores.free_delivery
- stores.cover_photo_full_url
- stores.delivery
- stores.take_away
- stores.schedule_order
- stores.avg_rating
- stores.tax
- stores.rating_count
- stores.reviews_count
- stores.self_delivery_system
- stores.minimum_shipping_charge
- stores.maximum_shipping_charge
- stores.per_km_shipping_charge
- stores.open
- stores.active
- stores.zone_id
- stores.delivery_time
- stores.veg
- stores.non_veg
- stores.module_id
- stores.module_type
- stores.order_place_to_schedule_interval
- stores.category_ids
- stores.categories
- stores.store_discount
- stores.store_discount.day
- stores.store_discount.opening_time
- stores.store_discount.closing_time
- stores.schedules
- stores.schedules.day
- stores.schedules.opening_time
- stores.schedules.closing_time
- stores.vendor_id
- stores.prescription_order
- stores.cutlery
- stores.slug
- stores.announcement
- stores.announcement_message
- stores.total_items
- stores.items
- stores.items.id
- stores.items.name
- stores.items.image_full_url
- stores.items.price
- stores.items.discount
- stores.items.discount_type
- stores.top_items
- stores.top_items.id
- stores.top_items.name
- stores.top_items.slug
- stores.top_items.image_full_url
- stores.top_items.thumbnail_full_url
- stores.top_items.price
- stores.top_items.base_price
- stores.top_items.discounted_price
- stores.top_items.discount
- stores.top_items.discount_type
- stores.top_items.avg_rating
- stores.extra_packaging_status
- stores.extra_packaging_amount
- stores.ratings
- stores.reviews_comments_count
- stores.store_sub
- stores.store_sub.chat
- stores.store_business_model
- stores.distance
- stores.distance_km
- stores.current_opening_time
- stores.verified_seller
- stores.avg_item_discount_percentage
- stores.ad
- stores.pro_discount
- stores.pro_discount.start_date
- stores.pro_discount.end_date
- stores.pro_discount.min_purchase
- stores.pro_discount.max_discount
- stores.pro_discount.discount
- stores.pro_discount.discount_type
- stores.is_new
- stores.sponsored
- stores.offer_label
- stores.store_item_image_list
- stores.description
- stores.active_coupons

<a id="api-v1-campaigns-item-itemcampaignuri"></a>
## Endpoint : /api/v1/campaigns/item

- **Constant**: `AppConstants.itemCampaignUri`
- **Repository**: `campaign_repository.dart:56` — _getItemCampaignList
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- description
- image_full_url
- video_link
- video_full_url
- video_preview_url
- video_thumbnail_url
- video_embed_url
- images_full_url
- category_id
- category_ids
- category_ids.id
- variations
- variations.type
- variations.price
- variations.stock
- food_variations
- food_variations.max
- food_variations.name
- food_variations.type
- food_variations.min
- food_variations.required
- food_variations.values
- food_variations.values.label
- food_variations.values.optionPrice
- food_variations.values.isSelected
- add_ons
- add_ons.id
- add_ons.name
- add_ons.price
- addons
- addons.id
- addons.name
- addons.price
- choice_options
- choice_options.title
- choice_options.options
- price
- discount
- discount_type
- available_time_starts
- available_time_ends
- store_id
- store_name
- zone_id
- schedule_order
- avg_rating
- rating_count
- module_id
- module_type
- veg
- stock
- unit_type
- available_date_starts
- organic
- maximum_cart_quantity
- flash_sale
- halal_tag_status
- is_halal
- is_prescription_required
- nutritions_name
- allergies_name
- generic_name
- store_details
- store_details.id
- store_details.name
- store_details.slug
- store_details.zone_id
- store_details.show_low_stock_count
- store_details.minimum_stock_for_warning
- slug
- verified_seller
- store_image_full_url
- store_logo_full_url
- free_delivery
- offer_label
- brand_name

<a id="api-v1-cashback-getcashback-getcashbackamounturi"></a>
## Endpoint : /api/v1/cashback/getCashback

- **Constant**: `AppConstants.getCashBackAmountUri`
- **Repository**: `home_repository.dart:53` — getCashBackData
- **Model**: `lib/features/home/domain/models/cashback_model.dart`
- **Parsed to model**: Yes

**Data:**

- title
- cashback_type
- cashback_amount
- min_purchase
- max_discount
- end_date

<a id="api-v1-cashback-list-cashbackofferlisturi"></a>
## Endpoint : /api/v1/cashback/list

- **Constant**: `AppConstants.cashBackOfferListUri`
- **Repository**: `home_repository.dart:35`
- **Model**: `lib/features/home/domain/models/cashback_model.dart`
- **Parsed to model**: Yes

**Data:**

- title
- cashback_type
- cashback_amount
- min_purchase
- max_discount
- end_date

<a id="api-v1-coupon-apply-code-couponapplyuri"></a>
## Endpoint : /api/v1/coupon/apply?code=

- **Constant**: `AppConstants.couponApplyUri`
- **Repository**: `coupon_repository.dart:54` — applyCoupon
- **Model**: `lib/features/coupon/domain/models/coupon_model.dart`
- **Parsed to model**: Yes

**Data:**

- title
- code
- start_date
- expire_date
- min_purchase
- max_discount
- discount
- discount_type
- coupon_type
- data
- store_id
- store_new
- store_new.name
- store_new.verified_seller

<a id="api-v1-coupon-list-couponuri"></a>
## Endpoint : /api/v1/coupon/list

- **Constant**: `AppConstants.couponUri`
- **Repository**: `coupon_repository.dart:29`
- **Model**: `lib/features/coupon/domain/models/coupon_model.dart`
- **Parsed to model**: Yes

**Data:**

- title
- code
- start_date
- expire_date
- min_purchase
- max_discount
- discount
- discount_type
- coupon_type
- data
- store_id
- store_new
- store_new.name
- store_new.verified_seller

<a id="api-v1-coupon-list-taxi-taxicouponuri"></a>
## Endpoint : /api/v1/coupon/list/taxi

- **Constant**: `AppConstants.taxiCouponUri`
- **Repository**: `coupon_repository.dart:43` — _getTaxiCouponList
- **Model**: `lib/features/coupon/domain/models/coupon_model.dart`
- **Parsed to model**: Yes

**Data:**

- title
- code
- start_date
- expire_date
- min_purchase
- max_discount
- discount
- discount_type
- coupon_type
- data
- store_id
- store_new
- store_new.name
- store_new.verified_seller

<a id="api-v1-flash-sales-flashsaleuri"></a>
## Endpoint : /api/v1/flash-sales

- **Constant**: `AppConstants.flashSaleUri`
- **Repository**: `flash_sale_repository.dart:24`
- **Model**: `lib/features/flash_sale/domain/models/flash_sale_model.dart`
- **Parsed to model**: Yes

**Data:**

- end_date
- active_products
- active_products.flash_sale_id
- active_products.stock
- active_products.sold
- active_products.item
- active_products.item.id
- active_products.item.name
- active_products.item.description
- active_products.item.image_full_url
- active_products.item.video_link
- active_products.item.video_full_url
- active_products.item.video_preview_url
- active_products.item.video_thumbnail_url
- active_products.item.video_embed_url
- active_products.item.images_full_url
- active_products.item.category_id
- active_products.item.category_ids
- active_products.item.category_ids.id
- active_products.item.variations
- active_products.item.variations.type
- active_products.item.variations.price
- active_products.item.variations.stock
- active_products.item.food_variations
- active_products.item.food_variations.max
- active_products.item.food_variations.name
- active_products.item.food_variations.type
- active_products.item.food_variations.min
- active_products.item.food_variations.required
- active_products.item.food_variations.values
- active_products.item.add_ons
- active_products.item.add_ons.id
- active_products.item.add_ons.name
- active_products.item.add_ons.price
- active_products.item.addons
- active_products.item.addons.id
- active_products.item.addons.name
- active_products.item.addons.price
- active_products.item.choice_options
- active_products.item.choice_options.title
- active_products.item.choice_options.options
- active_products.item.price
- active_products.item.discount
- active_products.item.discount_type
- active_products.item.available_time_starts
- active_products.item.available_time_ends
- active_products.item.store_id
- active_products.item.store_name
- active_products.item.zone_id
- active_products.item.schedule_order
- active_products.item.avg_rating
- active_products.item.rating_count
- active_products.item.module_id
- active_products.item.module_type
- active_products.item.veg
- active_products.item.stock
- active_products.item.unit_type
- active_products.item.available_date_starts
- active_products.item.organic
- active_products.item.maximum_cart_quantity
- active_products.item.flash_sale
- active_products.item.halal_tag_status
- active_products.item.is_halal
- active_products.item.is_prescription_required
- active_products.item.nutritions_name
- active_products.item.allergies_name
- active_products.item.generic_name
- active_products.item.store_details
- active_products.item.store_details.id
- active_products.item.store_details.name
- active_products.item.store_details.slug
- active_products.item.store_details.zone_id
- active_products.item.store_details.show_low_stock_count
- active_products.item.store_details.minimum_stock_for_warning
- active_products.item.slug
- active_products.item.verified_seller
- active_products.item.store_image_full_url
- active_products.item.store_logo_full_url
- active_products.item.free_delivery
- active_products.item.offer_label
- active_products.item.brand_name

<a id="api-v1-flash-sales-items-flashsaleproductsuri"></a>
## Endpoint : /api/v1/flash-sales/items

- **Constant**: `AppConstants.flashSaleProductsUri`
- **Repository**: `flash_sale_repository.dart:43` — getFlashSaleWithId
- **Model**: `lib/features/flash_sale/domain/models/product_flash_sale.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- flash_sale
- flash_sale.end_date
- flash_sale.active_products
- flash_sale.active_products.flash_sale_id
- flash_sale.active_products.stock
- flash_sale.active_products.sold
- flash_sale.active_products.item
- flash_sale.active_products.item.id
- flash_sale.active_products.item.name
- flash_sale.active_products.item.description
- flash_sale.active_products.item.image_full_url
- flash_sale.active_products.item.video_link
- flash_sale.active_products.item.video_full_url
- flash_sale.active_products.item.video_preview_url
- flash_sale.active_products.item.video_thumbnail_url
- flash_sale.active_products.item.video_embed_url
- flash_sale.active_products.item.images_full_url
- flash_sale.active_products.item.category_id
- flash_sale.active_products.item.category_ids
- flash_sale.active_products.item.variations
- flash_sale.active_products.item.food_variations
- flash_sale.active_products.item.add_ons
- flash_sale.active_products.item.addons
- flash_sale.active_products.item.choice_options
- flash_sale.active_products.item.price
- flash_sale.active_products.item.discount
- flash_sale.active_products.item.discount_type
- flash_sale.active_products.item.available_time_starts
- flash_sale.active_products.item.available_time_ends
- flash_sale.active_products.item.store_id
- flash_sale.active_products.item.store_name
- flash_sale.active_products.item.zone_id
- flash_sale.active_products.item.schedule_order
- flash_sale.active_products.item.avg_rating
- flash_sale.active_products.item.rating_count
- flash_sale.active_products.item.module_id
- flash_sale.active_products.item.module_type
- flash_sale.active_products.item.veg
- flash_sale.active_products.item.stock
- flash_sale.active_products.item.unit_type
- flash_sale.active_products.item.available_date_starts
- flash_sale.active_products.item.organic
- flash_sale.active_products.item.maximum_cart_quantity
- flash_sale.active_products.item.flash_sale
- flash_sale.active_products.item.halal_tag_status
- flash_sale.active_products.item.is_halal
- flash_sale.active_products.item.is_prescription_required
- flash_sale.active_products.item.nutritions_name
- flash_sale.active_products.item.allergies_name
- flash_sale.active_products.item.generic_name
- flash_sale.active_products.item.store_details
- flash_sale.active_products.item.slug
- flash_sale.active_products.item.verified_seller
- flash_sale.active_products.item.store_image_full_url
- flash_sale.active_products.item.store_logo_full_url
- flash_sale.active_products.item.free_delivery
- flash_sale.active_products.item.offer_label
- flash_sale.active_products.item.brand_name
- products
- products.stock
- products.sold
- products.item
- products.item.id
- products.item.name
- products.item.description
- products.item.image_full_url
- products.item.video_link
- products.item.video_full_url
- products.item.video_preview_url
- products.item.video_thumbnail_url
- products.item.video_embed_url
- products.item.images_full_url
- products.item.category_id
- products.item.category_ids
- products.item.category_ids.id
- products.item.variations
- products.item.variations.type
- products.item.variations.price
- products.item.variations.stock
- products.item.food_variations
- products.item.food_variations.max
- products.item.food_variations.name
- products.item.food_variations.type
- products.item.food_variations.min
- products.item.food_variations.required
- products.item.food_variations.values
- products.item.add_ons
- products.item.add_ons.id
- products.item.add_ons.name
- products.item.add_ons.price
- products.item.addons
- products.item.addons.id
- products.item.addons.name
- products.item.addons.price
- products.item.choice_options
- products.item.choice_options.title
- products.item.choice_options.options
- products.item.price
- products.item.discount
- products.item.discount_type
- products.item.available_time_starts
- products.item.available_time_ends
- products.item.store_id
- products.item.store_name
- products.item.zone_id
- products.item.schedule_order
- products.item.avg_rating
- products.item.rating_count
- products.item.module_id
- products.item.module_type
- products.item.veg
- products.item.stock
- products.item.unit_type
- products.item.available_date_starts
- products.item.organic
- products.item.maximum_cart_quantity
- products.item.flash_sale
- products.item.halal_tag_status
- products.item.is_halal
- products.item.is_prescription_required
- products.item.nutritions_name
- products.item.allergies_name
- products.item.generic_name
- products.item.store_details
- products.item.store_details.id
- products.item.store_details.name
- products.item.store_details.slug
- products.item.store_details.zone_id
- products.item.store_details.show_low_stock_count
- products.item.store_details.minimum_stock_for_warning
- products.item.slug
- products.item.verified_seller
- products.item.store_image_full_url
- products.item.store_logo_full_url
- products.item.free_delivery
- products.item.offer_label
- products.item.brand_name

<a id="api-v1-offers-items-offeritemsuri"></a>
## Endpoint : /api/v1/offers/items

- **Constant**: `AppConstants.offerItemsUri`
- **Repository**: `offer_repository.dart:15`
- **Model**: `lib/features/offer/domain/models/new_item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- limit
- offset
- items

<a id="api-v1-other-banners-parcelotherbanneruri"></a>
## Endpoint : /api/v1/other-banners  — `parcelOtherBannerUri`

- **Constant**: `AppConstants.parcelOtherBannerUri`
- **Repository**: `banner_repository.dart:78` — _getParcelOtherBannerList
- **Model**: `lib/features/banner/domain/models/others_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- banners
- banners.value_full_url

<a id="api-v1-other-banners-promotionalbanneruri"></a>
## Endpoint : /api/v1/other-banners  — `promotionalBannerUri`

- **Constant**: `AppConstants.promotionalBannerUri`
- **Repository**: `banner_repository.dart:87` — _getPromotionalBannerList
- **Model**: `lib/features/banner/domain/models/promotional_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- bottom_section_banner_full_url

<a id="api-v1-other-banners-video-content-videocontenturi"></a>
## Endpoint : /api/v1/other-banners/video-content

- **Constant**: `AppConstants.videoContentUri`
- **Repository**: `parcel_repository.dart:40`
- **Model**: `lib/features/parcel/domain/models/video_content_model.dart`
- **Parsed to model**: Yes

**Data:**

- banner_contents
- banner_contents.value
- banner_type
- banner_video
- banner_image_full_url
- banner_video_content_full_url

<a id="api-v1-other-banners-why-choose-whychooseuri"></a>
## Endpoint : /api/v1/other-banners/why-choose

- **Constant**: `AppConstants.whyChooseUri`
- **Repository**: `parcel_repository.dart:62`
- **Model**: `lib/features/parcel/domain/models/why_choose_model.dart`
- **Parsed to model**: Yes

**Data:**

- banners
- banners.title
- banners.short_description
- banners.image_full_url

<a id="api-v1-smart-banners-smartbanneruri"></a>
## Endpoint : /api/v1/smart-banners

- **Constant**: `AppConstants.smartBannerUri`
- **Repository**: `smart_banner_repository.dart:14`
- **Model**: `lib/features/smart_banner/domain/models/smart_banner_model.dart`
- **Parsed to model**: Yes

**Data:**

- smart_banners
- smart_banners.title
- smart_banners.subtitle
- smart_banners.image_full_url
- smart_banners.position
- smart_banners.redirect_type
- smart_banners.redirect_target_id
- smart_banners.module_id


---

# Cart

<a id="api-v1-customer-cart-add-addcarturi"></a>
## Endpoint : /api/v1/customer/cart/add

- **Constant**: `AppConstants.addCartUri`
- **Repository**: `cart_repository.dart:50` — addServiceCart
- **Model**: `lib/features/cart/domain/models/online_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- module_id
- add_on_ids
- add_on_qtys
- quantity
- item

<a id="api-v1-customer-cart-get-all-getallcartsuri"></a>
## Endpoint : /api/v1/customer/cart/get-all

- **Constant**: `AppConstants.getAllCartsUri`
- **Repository**: `cart_repository.dart:181` — getAllCarts
- **Model**: `lib/features/cart/domain/models/all_carts_model.dart`
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-cart-list-getcartlisturi"></a>
## Endpoint : /api/v1/customer/cart/list

- **Constant**: `AppConstants.getCartListUri`
- **Repository**: `cart_repository.dart:128` — getServiceCartList
- **Model**: `lib/features/cart/domain/models/online_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- module_id
- add_on_ids
- add_on_qtys
- quantity
- item

<a id="api-v1-customer-cart-remove-removeallcarturi"></a>
## Endpoint : /api/v1/customer/cart/remove

- **Constant**: `AppConstants.removeAllCartUri`
- **Repository**: `cart_repository.dart:91` — _clearCartOnline
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-cart-remove-item-removeitemcarturi"></a>
## Endpoint : /api/v1/customer/cart/remove-item

- **Constant**: `AppConstants.removeItemCartUri`
- **Repository**: `cart_repository.dart:86` — removeServiceCartItem
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-cart-update-updatecarturi"></a>
## Endpoint : /api/v1/customer/cart/update

- **Constant**: `AppConstants.updateCartUri`
- **Repository**: `cart_repository.dart:150` — updateServiceCart
- **Model**: `lib/features/cart/domain/models/online_cart_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- module_id
- add_on_ids
- add_on_qtys
- quantity
- item


---

# Orders

<a id="api-v1-customer-order-again-reorder-reorderuri"></a>
## Endpoint : /api/v1/customer/order-again/reorder

- **Constant**: `AppConstants.reorderUri`
- **Repository**: `order_repository.dart:164` — reorder
- **Model**: `lib/features/order/domain/models/reorder_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- added_count
- unavailable_items
- unavailable_items.name
- unavailable_items.message

<a id="api-v1-customer-order-all-running-orders-dashboardorderuri"></a>
## Endpoint : /api/v1/customer/order/all-running-orders

- **Constant**: `AppConstants.dashboardOrderUri`
- **Repository**: `order_repository.dart:237` — getDashboardOrders
- **Model**: `lib/common/models/ongoing_order_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.id
- data.order_type
- data.status

<a id="api-v1-customer-order-cancel-ordercanceluri"></a>
## Endpoint : /api/v1/customer/order/cancel

- **Constant**: `AppConstants.orderCancelUri`
- **Repository**: `order_repository.dart:87`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-cancellation-reasons-ordercancellationuri"></a>
## Endpoint : /api/v1/customer/order/cancellation-reasons

- **Constant**: `AppConstants.orderCancellationUri`
- **Repository**: `order_repository.dart:186` — _getCancelReasons
- **Model**: `lib/features/order/domain/models/order_cancellation_body.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.reason

<a id="api-v1-customer-order-delete-orderdeleteuri"></a>
## Endpoint : /api/v1/customer/order/delete

- **Constant**: `AppConstants.orderDeleteUri`
- **Repository**: `order_repository.dart:96` — deleteOrder
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-details-order-id-orderdetailsuri"></a>
## Endpoint : /api/v1/customer/order/details?order_id=

- **Constant**: `AppConstants.orderDetailsUri`
- **Repository**: `order_repository.dart:107` — _getOrderDetails
- **Model**: `lib/features/order/domain/models/order_details_model.dart`
- **Parsed to model**: Yes

**Data:**

- item_id
- order_id
- price
- item_details
- item_details.id
- item_details.name
- item_details.description
- item_details.image_full_url
- item_details.video_link
- item_details.video_full_url
- item_details.video_preview_url
- item_details.video_thumbnail_url
- item_details.video_embed_url
- item_details.images_full_url
- item_details.category_id
- item_details.category_ids
- item_details.category_ids.id
- item_details.variations
- item_details.variations.type
- item_details.variations.price
- item_details.variations.stock
- item_details.food_variations
- item_details.food_variations.max
- item_details.food_variations.name
- item_details.food_variations.type
- item_details.food_variations.min
- item_details.food_variations.required
- item_details.food_variations.values
- item_details.food_variations.values.label
- item_details.food_variations.values.optionPrice
- item_details.food_variations.values.isSelected
- item_details.add_ons
- item_details.add_ons.id
- item_details.add_ons.name
- item_details.add_ons.price
- item_details.addons
- item_details.addons.id
- item_details.addons.name
- item_details.addons.price
- item_details.choice_options
- item_details.choice_options.title
- item_details.choice_options.options
- item_details.price
- item_details.discount
- item_details.discount_type
- item_details.available_time_starts
- item_details.available_time_ends
- item_details.store_id
- item_details.store_name
- item_details.zone_id
- item_details.schedule_order
- item_details.avg_rating
- item_details.rating_count
- item_details.module_id
- item_details.module_type
- item_details.veg
- item_details.stock
- item_details.unit_type
- item_details.available_date_starts
- item_details.organic
- item_details.maximum_cart_quantity
- item_details.flash_sale
- item_details.halal_tag_status
- item_details.is_halal
- item_details.is_prescription_required
- item_details.nutritions_name
- item_details.allergies_name
- item_details.generic_name
- item_details.store_details
- item_details.store_details.id
- item_details.store_details.name
- item_details.store_details.slug
- item_details.store_details.zone_id
- item_details.store_details.show_low_stock_count
- item_details.store_details.minimum_stock_for_warning
- item_details.slug
- item_details.verified_seller
- item_details.store_image_full_url
- item_details.store_logo_full_url
- item_details.free_delivery
- item_details.offer_label
- item_details.brand_name
- variation
- variation.max
- variation.name
- variation.type
- variation.min
- variation.required
- variation.values
- variation.values.label
- variation.values.optionPrice
- variation.values.isSelected
- add_ons
- add_ons.name
- add_ons.price
- add_ons.quantity
- quantity
- item_campaign_id
- image_full_url
- is_guest

<a id="api-v1-customer-order-get-tax-getordertaxuri"></a>
## Endpoint : /api/v1/customer/order/get-Tax

- **Constant**: `AppConstants.getOrderTaxUri`
- **Repository**: `checkout_repository.dart:174` — getOrderTax
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-get-surge-price-getsurgepriceuri"></a>
## Endpoint : /api/v1/customer/order/get-surge-price

- **Constant**: `AppConstants.getSurgePriceUri`
- **Repository**: `checkout_repository.dart:187`
- **Model**: `lib/features/checkout/domain/models/surge_price_model.dart`
- **Parsed to model**: Yes

**Data:**

- customer_note
- customer_note_status
- price
- price_type

<a id="api-v1-customer-order-last-lastordersuri"></a>
## Endpoint : /api/v1/customer/order/last

- **Constant**: `AppConstants.lastOrdersUri`
- **Repository**: `order_repository.dart:137`
- **Model**: `lib/features/order/domain/models/last_order_model.dart`
- **Parsed to model**: Yes

**Data:**

- order_id
- module_id
- order_amount
- created_at
- store
- store.id
- store.name
- store.slug
- store.logo_full_url
- items_preview
- items_preview.id
- items_preview.name
- items_preview.image_full_url
- can_reorder

<a id="api-v1-customer-order-list-allorderlist"></a>
## Endpoint : /api/v1/customer/order/list

- **Constant**: `AppConstants.allOrderList`
- **Repository**: `order_repository.dart:175`
- **Model**: `lib/features/order/domain/models/order_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- orders
- orders.id
- orders.user_id
- orders.order_amount
- orders.coupon_discount_amount
- orders.payment_status
- orders.order_status
- orders.total_tax_amount
- orders.payment_method
- orders.order_note
- orders.order_type
- orders.created_at
- orders.updated_at
- orders.delivery_charge
- orders.schedule_at
- orders.otp
- orders.pending
- orders.accepted
- orders.confirmed
- orders.processing
- orders.handover
- orders.picked_up
- orders.delivered
- orders.canceled
- orders.refund_requested
- orders.refunded
- orders.scheduled
- orders.store_discount_amount
- orders.failed
- orders.details_count
- orders.order_attachment_full_url
- orders.charge_payer
- orders.module_type
- orders.delivery_man
- orders.delivery_man.id
- orders.delivery_man.f_name
- orders.delivery_man.l_name
- orders.delivery_man.phone
- orders.delivery_man.image_full_url
- orders.delivery_man.avg_rating
- orders.delivery_man.rating_count
- orders.delivery_man.lat
- orders.delivery_man.lng
- orders.delivery_man.location
- orders.store
- orders.store.id
- orders.store.name
- orders.store.phone
- orders.store.logo_full_url
- orders.store.latitude
- orders.store.longitude
- orders.store.address
- orders.store.minimum_order
- orders.store.free_delivery
- orders.store.cover_photo_full_url
- orders.store.delivery
- orders.store.take_away
- orders.store.schedule_order
- orders.store.avg_rating
- orders.store.tax
- orders.store.rating_count
- orders.store.reviews_count
- orders.store.self_delivery_system
- orders.store.minimum_shipping_charge
- orders.store.maximum_shipping_charge
- orders.store.per_km_shipping_charge
- orders.store.open
- orders.store.active
- orders.store.zone_id
- orders.store.delivery_time
- orders.store.veg
- orders.store.non_veg
- orders.store.module_id
- orders.store.module_type
- orders.store.order_place_to_schedule_interval
- orders.store.category_ids
- orders.store.categories
- orders.store.store_discount
- orders.store.store_discount.day
- orders.store.store_discount.opening_time
- orders.store.store_discount.closing_time
- orders.store.schedules
- orders.store.schedules.day
- orders.store.schedules.opening_time
- orders.store.schedules.closing_time
- orders.store.vendor_id
- orders.store.prescription_order
- orders.store.cutlery
- orders.store.slug
- orders.store.announcement
- orders.store.announcement_message
- orders.store.total_items
- orders.store.items
- orders.store.items.id
- orders.store.items.name
- orders.store.items.image_full_url
- orders.store.items.price
- orders.store.items.discount
- orders.store.items.discount_type
- orders.store.top_items
- orders.store.top_items.id
- orders.store.top_items.name
- orders.store.top_items.slug
- orders.store.top_items.image_full_url
- orders.store.top_items.thumbnail_full_url
- orders.store.top_items.price
- orders.store.top_items.base_price
- orders.store.top_items.discounted_price
- orders.store.top_items.discount
- orders.store.top_items.discount_type
- orders.store.top_items.avg_rating
- orders.store.extra_packaging_status
- orders.store.extra_packaging_amount
- orders.store.ratings
- orders.store.reviews_comments_count
- orders.store.store_sub
- orders.store.store_sub.chat
- orders.store.store_business_model
- orders.store.distance
- orders.store.distance_km
- orders.store.current_opening_time
- orders.store.verified_seller
- orders.store.avg_item_discount_percentage
- orders.store.ad
- orders.store.pro_discount
- orders.store.pro_discount.start_date
- orders.store.pro_discount.end_date
- orders.store.pro_discount.min_purchase
- orders.store.pro_discount.max_discount
- orders.store.pro_discount.discount
- orders.store.pro_discount.discount_type
- orders.store.is_new
- orders.store.sponsored
- orders.store.offer_label
- orders.store.store_item_image_list
- orders.store.description
- orders.store.active_coupons
- orders.delivery_address
- orders.delivery_address.id
- orders.delivery_address.address_type
- orders.delivery_address.contact_person_number
- orders.delivery_address.address
- orders.delivery_address.additional_address
- orders.delivery_address.latitude
- orders.delivery_address.longitude
- orders.delivery_address.zone_id
- orders.delivery_address.ride_zone_id
- orders.delivery_address.zone_ids
- orders.delivery_address._method
- orders.delivery_address.contact_person_name
- orders.delivery_address.road
- orders.delivery_address.house
- orders.delivery_address.floor
- orders.delivery_address.zone_data
- orders.delivery_address.zone_data.id
- orders.delivery_address.zone_data.status
- orders.delivery_address.zone_data.cash_on_delivery
- orders.delivery_address.zone_data.digital_payment
- orders.delivery_address.zone_data.offline_payment
- orders.delivery_address.zone_data.increased_delivery_fee_status
- orders.delivery_address.zone_data.increase_delivery_charge_message
- orders.delivery_address.zone_data.modules
- orders.delivery_address.area_ids
- orders.delivery_address.contact_person_email
- orders.receiver_details
- orders.receiver_details.id
- orders.receiver_details.address_type
- orders.receiver_details.contact_person_number
- orders.receiver_details.address
- orders.receiver_details.additional_address
- orders.receiver_details.latitude
- orders.receiver_details.longitude
- orders.receiver_details.zone_id
- orders.receiver_details.ride_zone_id
- orders.receiver_details.zone_ids
- orders.receiver_details._method
- orders.receiver_details.contact_person_name
- orders.receiver_details.road
- orders.receiver_details.house
- orders.receiver_details.floor
- orders.receiver_details.zone_data
- orders.receiver_details.zone_data.id
- orders.receiver_details.zone_data.status
- orders.receiver_details.zone_data.cash_on_delivery
- orders.receiver_details.zone_data.digital_payment
- orders.receiver_details.zone_data.offline_payment
- orders.receiver_details.zone_data.increased_delivery_fee_status
- orders.receiver_details.zone_data.increase_delivery_charge_message
- orders.receiver_details.zone_data.modules
- orders.receiver_details.area_ids
- orders.receiver_details.contact_person_email
- orders.parcel_category
- orders.parcel_category.id
- orders.parcel_category.image_full_url
- orders.parcel_category.name
- orders.parcel_category.description
- orders.parcel_category.parcel_per_km_shipping_charge
- orders.parcel_category.parcel_minimum_shipping_charge
- orders.dm_tips
- orders.refund
- orders.refund.image_full_url
- orders.refund.customer_reason
- orders.refund.customer_note
- orders.refund.admin_note
- orders.prescription_order
- orders.tax_status
- orders.cancellation_reason
- orders.processing_time
- orders.cutlery
- orders.unavailable_item_note
- orders.delivery_instruction
- orders.additional_charge
- orders.payments
- orders.payments.amount
- orders.payments.payment_status
- orders.payments.payment_method
- orders.order_proof_full_url
- orders.offline_payment
- orders.offline_payment.input
- orders.offline_payment.input.user_input
- orders.offline_payment.input.user_data
- orders.offline_payment.data
- orders.offline_payment.data.status
- orders.offline_payment.data.method_id
- orders.offline_payment.data.method_name
- orders.offline_payment.data.admin_note
- orders.offline_payment.method_fields
- orders.offline_payment.method_fields.input_name
- orders.offline_payment.method_fields.input_data
- orders.flash_admin_discount_amount
- orders.flash_store_discount_amount
- orders.extra_packaging_amount
- orders.ref_bonus_amount
- orders.parcel_cancellation
- orders.parcel_cancellation.reason
- orders.parcel_cancellation.cancel_by
- orders.parcel_cancellation.note
- orders.parcel_cancellation.return_otp
- orders.parcel_cancellation.return_fee
- orders.parcel_cancellation.return_fee_payment_status
- orders.parcel_cancellation.return_date
- orders.parcel_cancellation.before_pickup
- orders.bring_change_amount
- orders.cancellation_note
- orders.reviews
- orders.reviews.item_id
- orders.reviews.comment
- orders.reviews.rating
- orders.delivery_type
- orders.delivery_type_charge
- orders.items_preview
- orders.can_reorder
- orders.benefit_type
- orders.delivery_fee_reduction_amount
- orders.pro_discount
- orders.item_count
- orders.module_id

<a id="api-v1-customer-order-offline-payment-offlinepaymentsaveinfouri"></a>
## Endpoint : /api/v1/customer/order/offline-payment

- **Constant**: `AppConstants.offlinePaymentSaveInfoUri`
- **Repository**: `payement_repository.dart:47` — saveOfflineInfo
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-offline-payment-update-offlinepaymentupdateinfouri"></a>
## Endpoint : /api/v1/customer/order/offline-payment-update

- **Constant**: `AppConstants.offlinePaymentUpdateInfoUri`
- **Repository**: `payement_repository.dart:53` — updateOfflineInfo
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-parcel-instructions-parcelinstructionuri"></a>
## Endpoint : /api/v1/customer/order/parcel-instructions

- **Constant**: `AppConstants.parcelInstructionUri`
- **Repository**: `parcel_repository.dart:98` — _getParcelInstruction
- **Model**: `lib/features/parcel/domain/models/parcel_instruction_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.instruction

<a id="api-v1-customer-order-parcel-return-customerparcelreturn"></a>
## Endpoint : /api/v1/customer/order/parcel-return

- **Constant**: `AppConstants.customerParcelReturn`
- **Repository**: `order_repository.dart:230`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-payment-failed-paymentfaileddetailsuri"></a>
## Endpoint : /api/v1/customer/order/payment-failed

- **Constant**: `AppConstants.paymentFailedDetailsUri`
- **Repository**: `order_repository.dart:48` — getPaymentFailedDetails
- **Model**: `lib/features/checkout/domain/models/payment_model.dart`
- **Parsed to model**: Yes

**Data:**

- order_id
- order_type
- order_amount
- maximum_cod_order_amount
- cash_on_delivery
- digital_payment
- offline_payment
- guest_id
- contact_person_number
- zone_id
- partially_paid_amount
- payment_status
- payment_method
- user_id

<a id="api-v1-customer-order-payment-method-codswitchuri"></a>
## Endpoint : /api/v1/customer/order/payment-method

- **Constant**: `AppConstants.codSwitchUri`
- **Repository**: `order_repository.dart:63`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-place-placeorderuri"></a>
## Endpoint : /api/v1/customer/order/place

- **Constant**: `AppConstants.placeOrderUri`
- **Repository**: `checkout_repository.dart:75` — placeOrder
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-prescription-place-placeprescriptionorderuri"></a>
## Endpoint : /api/v1/customer/order/prescription/place

- **Constant**: `AppConstants.placePrescriptionOrderUri`
- **Repository**: `checkout_repository.dart:103` — placePrescriptionOrder
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-refund-reasons-refundreasonuri"></a>
## Endpoint : /api/v1/customer/order/refund-reasons

- **Constant**: `AppConstants.refundReasonUri`
- **Repository**: `order_repository.dart:199` — _getRefundReasons
- **Model**: `lib/features/order/domain/models/refund_model.dart`
- **Parsed to model**: Yes

**Data:**

- refund_reasons
- refund_reasons.reason

<a id="api-v1-customer-order-refund-request-refundrequesturi"></a>
## Endpoint : /api/v1/customer/order/refund-request

- **Constant**: `AppConstants.refundRequestUri`
- **Repository**: `order_repository.dart:28` — submitRefundRequest
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-order-track-order-id-trackuri"></a>
## Endpoint : /api/v1/customer/order/track?order_id=

- **Constant**: `AppConstants.trackUri`
- **Repository**: `order_repository.dart:33`
- **Model**: `lib/features/order/domain/models/order_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- user_id
- order_amount
- coupon_discount_amount
- payment_status
- order_status
- total_tax_amount
- payment_method
- order_note
- order_type
- created_at
- updated_at
- delivery_charge
- schedule_at
- otp
- pending
- accepted
- confirmed
- processing
- handover
- picked_up
- delivered
- canceled
- refund_requested
- refunded
- scheduled
- store_discount_amount
- failed
- details_count
- order_attachment_full_url
- charge_payer
- module_type
- delivery_man
- delivery_man.id
- delivery_man.f_name
- delivery_man.l_name
- delivery_man.phone
- delivery_man.image_full_url
- delivery_man.avg_rating
- delivery_man.rating_count
- delivery_man.lat
- delivery_man.lng
- delivery_man.location
- store
- store.id
- store.name
- store.phone
- store.logo_full_url
- store.latitude
- store.longitude
- store.address
- store.minimum_order
- store.free_delivery
- store.cover_photo_full_url
- store.delivery
- store.take_away
- store.schedule_order
- store.avg_rating
- store.tax
- store.rating_count
- store.reviews_count
- store.self_delivery_system
- store.minimum_shipping_charge
- store.maximum_shipping_charge
- store.per_km_shipping_charge
- store.open
- store.active
- store.zone_id
- store.delivery_time
- store.veg
- store.non_veg
- store.module_id
- store.module_type
- store.order_place_to_schedule_interval
- store.category_ids
- store.categories
- store.store_discount
- store.store_discount.day
- store.store_discount.opening_time
- store.store_discount.closing_time
- store.schedules
- store.schedules.day
- store.schedules.opening_time
- store.schedules.closing_time
- store.vendor_id
- store.prescription_order
- store.cutlery
- store.slug
- store.announcement
- store.announcement_message
- store.total_items
- store.items
- store.items.id
- store.items.name
- store.items.image_full_url
- store.items.price
- store.items.discount
- store.items.discount_type
- store.top_items
- store.top_items.id
- store.top_items.name
- store.top_items.slug
- store.top_items.image_full_url
- store.top_items.thumbnail_full_url
- store.top_items.price
- store.top_items.base_price
- store.top_items.discounted_price
- store.top_items.discount
- store.top_items.discount_type
- store.top_items.avg_rating
- store.extra_packaging_status
- store.extra_packaging_amount
- store.ratings
- store.reviews_comments_count
- store.store_sub
- store.store_sub.chat
- store.store_business_model
- store.distance
- store.distance_km
- store.current_opening_time
- store.verified_seller
- store.avg_item_discount_percentage
- store.ad
- store.pro_discount
- store.pro_discount.start_date
- store.pro_discount.end_date
- store.pro_discount.min_purchase
- store.pro_discount.max_discount
- store.pro_discount.discount
- store.pro_discount.discount_type
- store.is_new
- store.sponsored
- store.offer_label
- store.store_item_image_list
- store.description
- store.active_coupons
- delivery_address
- delivery_address.id
- delivery_address.address_type
- delivery_address.contact_person_number
- delivery_address.address
- delivery_address.additional_address
- delivery_address.latitude
- delivery_address.longitude
- delivery_address.zone_id
- delivery_address.ride_zone_id
- delivery_address.zone_ids
- delivery_address._method
- delivery_address.contact_person_name
- delivery_address.road
- delivery_address.house
- delivery_address.floor
- delivery_address.zone_data
- delivery_address.zone_data.id
- delivery_address.zone_data.status
- delivery_address.zone_data.cash_on_delivery
- delivery_address.zone_data.digital_payment
- delivery_address.zone_data.offline_payment
- delivery_address.zone_data.increased_delivery_fee_status
- delivery_address.zone_data.increase_delivery_charge_message
- delivery_address.zone_data.modules
- delivery_address.zone_data.modules.id
- delivery_address.zone_data.modules.module_name
- delivery_address.zone_data.modules.module_type
- delivery_address.zone_data.modules.stores_count
- delivery_address.zone_data.modules.theme_id
- delivery_address.zone_data.modules.additional_delivery_option_status
- delivery_address.zone_data.modules.delivery_options
- delivery_address.zone_data.modules.pivot
- delivery_address.area_ids
- delivery_address.contact_person_email
- receiver_details
- receiver_details.id
- receiver_details.address_type
- receiver_details.contact_person_number
- receiver_details.address
- receiver_details.additional_address
- receiver_details.latitude
- receiver_details.longitude
- receiver_details.zone_id
- receiver_details.ride_zone_id
- receiver_details.zone_ids
- receiver_details._method
- receiver_details.contact_person_name
- receiver_details.road
- receiver_details.house
- receiver_details.floor
- receiver_details.zone_data
- receiver_details.zone_data.id
- receiver_details.zone_data.status
- receiver_details.zone_data.cash_on_delivery
- receiver_details.zone_data.digital_payment
- receiver_details.zone_data.offline_payment
- receiver_details.zone_data.increased_delivery_fee_status
- receiver_details.zone_data.increase_delivery_charge_message
- receiver_details.zone_data.modules
- receiver_details.zone_data.modules.id
- receiver_details.zone_data.modules.module_name
- receiver_details.zone_data.modules.module_type
- receiver_details.zone_data.modules.stores_count
- receiver_details.zone_data.modules.theme_id
- receiver_details.zone_data.modules.additional_delivery_option_status
- receiver_details.zone_data.modules.delivery_options
- receiver_details.zone_data.modules.pivot
- receiver_details.area_ids
- receiver_details.contact_person_email
- parcel_category
- parcel_category.id
- parcel_category.image_full_url
- parcel_category.name
- parcel_category.description
- parcel_category.parcel_per_km_shipping_charge
- parcel_category.parcel_minimum_shipping_charge
- dm_tips
- refund
- refund.image_full_url
- refund.customer_reason
- refund.customer_note
- refund.admin_note
- prescription_order
- tax_status
- cancellation_reason
- processing_time
- cutlery
- unavailable_item_note
- delivery_instruction
- additional_charge
- payments
- payments.amount
- payments.payment_status
- payments.payment_method
- order_proof_full_url
- offline_payment
- offline_payment.input
- offline_payment.input.user_input
- offline_payment.input.user_data
- offline_payment.data
- offline_payment.data.status
- offline_payment.data.method_id
- offline_payment.data.method_name
- offline_payment.data.admin_note
- offline_payment.method_fields
- offline_payment.method_fields.input_name
- offline_payment.method_fields.input_data
- flash_admin_discount_amount
- flash_store_discount_amount
- extra_packaging_amount
- ref_bonus_amount
- parcel_cancellation
- parcel_cancellation.reason
- parcel_cancellation.cancel_by
- parcel_cancellation.note
- parcel_cancellation.return_otp
- parcel_cancellation.return_fee
- parcel_cancellation.return_fee_payment_status
- parcel_cancellation.return_date
- parcel_cancellation.before_pickup
- bring_change_amount
- cancellation_note
- reviews
- reviews.item_id
- reviews.comment
- reviews.rating
- delivery_type
- delivery_type_charge
- items_preview
- can_reorder
- benefit_type
- delivery_fee_reduction_amount
- pro_discount
- item_count
- module_id

<a id="api-v1-customer-order-wallet-payment-walletswitchuri"></a>
## Endpoint : /api/v1/customer/order/wallet-payment

- **Constant**: `AppConstants.walletSwitchUri`
- **Repository**: `order_repository.dart:69` — switchToWalletPayment
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-saved-files-savedfilesuri"></a>
## Endpoint : /api/v1/customer/saved-files

- **Constant**: `AppConstants.savedFilesUri`
- **Repository**: `checkout_repository.dart:109` — getSavedPrescriptionImages
- **Model**: `lib/features/checkout/domain/models/saved_prescription_model.dart`
- **Parsed to model**: Yes

**Data:**

- file_name
- image_full_url

<a id="api-v1-customer-saved-files-delete-all-deletesavedfilesuri"></a>
## Endpoint : /api/v1/customer/saved-files/delete-all

- **Constant**: `AppConstants.deleteSavedFilesUri`
- **Repository**: `checkout_repository.dart:134` — deleteSavedPrescriptionImages
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-saved-files-store-storesavedfilesuri"></a>
## Endpoint : /api/v1/customer/saved-files/store

- **Constant**: `AppConstants.storeSavedFilesUri`
- **Repository**: `checkout_repository.dart:123` — storeSavedPrescriptionImages
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-most-tips-mosttipsuri"></a>
## Endpoint : /api/v1/most-tips

- **Constant**: `AppConstants.mostTipsUri`
- **Repository**: `checkout_repository.dart:25` — getDmTipMostTapped
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-offline-payment-method-list-offlinemethodlisturi"></a>
## Endpoint : /api/v1/offline_payment_method_list

- **Constant**: `AppConstants.offlineMethodListUri`
- **Repository**: `checkout_repository.dart:159` — _getOfflineMethodList
- **Model**: `lib/features/payment/domain/models/offline_method_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- method_name
- method_fields
- method_fields.input_name
- method_fields.input_data
- method_informations
- method_informations.customer_input
- method_informations.customer_placeholder
- method_informations.is_required

<a id="api-v1-vehicle-extra-charge-vehiclechargeuri"></a>
## Endpoint : /api/v1/vehicle/extra_charge

- **Constant**: `AppConstants.vehicleChargeUri`
- **Repository**: `checkout_repository.dart:54` — getExtraCharge
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_


---

# Address

<a id="api-v1-customer-address-add-addaddressuri"></a>
## Endpoint : /api/v1/customer/address/add

- **Constant**: `AppConstants.addAddressUri`
- **Repository**: `address_repository.dart:20` — _addAddress
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-address-delete-address-id-removeaddressuri"></a>
## Endpoint : /api/v1/customer/address/delete?address_id=

- **Constant**: `AppConstants.removeAddressUri`
- **Repository**: `address_repository.dart:37` — _removeAddressByID
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-address-list-addresslisturi"></a>
## Endpoint : /api/v1/customer/address/list

- **Constant**: `AppConstants.addressListUri`
- **Repository**: `address_repository.dart:57` — _getAllAddress
- **Model**: `lib/features/address/domain/models/address_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- address_type
- contact_person_number
- address
- additional_address
- latitude
- longitude
- zone_id
- ride_zone_id
- zone_ids
- _method
- contact_person_name
- road
- house
- floor
- zone_data
- zone_data.id
- zone_data.status
- zone_data.cash_on_delivery
- zone_data.digital_payment
- zone_data.offline_payment
- zone_data.increased_delivery_fee_status
- zone_data.increase_delivery_charge_message
- zone_data.modules
- zone_data.modules.id
- zone_data.modules.module_name
- zone_data.modules.module_type
- zone_data.modules.stores_count
- zone_data.modules.theme_id
- zone_data.modules.additional_delivery_option_status
- zone_data.modules.delivery_options
- zone_data.modules.delivery_options.delivery_type
- zone_data.modules.delivery_options.extra_charge
- zone_data.modules.delivery_options.reduce_charge
- zone_data.modules.delivery_options.add_delivery_time
- zone_data.modules.delivery_options.reduce_delivery_time
- zone_data.modules.pivot
- zone_data.modules.pivot.zone_id
- zone_data.modules.pivot.per_km_shipping_charge
- zone_data.modules.pivot.minimum_shipping_charge
- zone_data.modules.pivot.maximum_shipping_charge
- zone_data.modules.pivot.maximum_cod_order_amount
- zone_data.modules.pivot.delivery_charge_type
- zone_data.modules.pivot.fixed_shipping_charge
- zone_data.modules.pivot.minimum_delivery_charge
- area_ids
- contact_person_email

<a id="api-v1-customer-address-update-updateaddressuri"></a>
## Endpoint : /api/v1/customer/address/update/

- **Constant**: `AppConstants.updateAddressUri`
- **Repository**: `address_repository.dart:73` — _updateAddress
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_


---

# Wishlist

<a id="api-v1-customer-wish-list-wishlistgeturi"></a>
## Endpoint : /api/v1/customer/wish-list

- **Constant**: `AppConstants.wishListGetUri`
- **Repository**: `favourite_repository.dart:17`
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- description
- image_full_url
- video_link
- video_full_url
- video_preview_url
- video_thumbnail_url
- video_embed_url
- images_full_url
- category_id
- category_ids
- category_ids.id
- variations
- variations.type
- variations.price
- variations.stock
- food_variations
- food_variations.max
- food_variations.name
- food_variations.type
- food_variations.min
- food_variations.required
- food_variations.values
- food_variations.values.label
- food_variations.values.optionPrice
- food_variations.values.isSelected
- add_ons
- add_ons.id
- add_ons.name
- add_ons.price
- addons
- addons.id
- addons.name
- addons.price
- choice_options
- choice_options.title
- choice_options.options
- price
- discount
- discount_type
- available_time_starts
- available_time_ends
- store_id
- store_name
- zone_id
- schedule_order
- avg_rating
- rating_count
- module_id
- module_type
- veg
- stock
- unit_type
- available_date_starts
- organic
- maximum_cart_quantity
- flash_sale
- halal_tag_status
- is_halal
- is_prescription_required
- nutritions_name
- allergies_name
- generic_name
- store_details
- store_details.id
- store_details.name
- store_details.slug
- store_details.zone_id
- store_details.show_low_stock_count
- store_details.minimum_stock_for_warning
- slug
- verified_seller
- store_image_full_url
- store_logo_full_url
- free_delivery
- offer_label
- brand_name

<a id="api-v1-customer-wish-list-add-addwishlisturi"></a>
## Endpoint : /api/v1/customer/wish-list/add?

- **Constant**: `AppConstants.addWishListUri`
- **Repository**: `favourite_repository.dart:24`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-wish-list-remove-removewishlisturi"></a>
## Endpoint : /api/v1/customer/wish-list/remove?

- **Constant**: `AppConstants.removeWishListUri`
- **Repository**: `favourite_repository.dart:37`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_


---

# Customer account

<a id="api-v1-customer-ai-chat-conversations-aichatconversationlisturi"></a>
## Endpoint : /api/v1/customer/ai-chat/conversations

- **Constant**: `AppConstants.aiChatConversationListUri`
- **Repository**: `ai_chat_bot_repository.dart:19`
- **Model**: `lib/features/ai_chat_bot/domain/models/ai_chat_conversation_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- data
- data.id
- data.title
- data.created_at
- data.updated_at
- data.messages_count

<a id="api-v1-customer-ai-chat-messages-aichatmessagesuri"></a>
## Endpoint : /api/v1/customer/ai-chat/messages

- **Constant**: `AppConstants.aiChatMessagesUri`
- **Repository**: `ai_chat_bot_repository.dart:31`
- **Model**: `lib/features/ai_chat_bot/domain/models/ai_chat_message_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset

<a id="api-v1-customer-ai-chat-send-aichatsendmessageuri"></a>
## Endpoint : /api/v1/customer/ai-chat/send

- **Constant**: `AppConstants.aiChatSendMessageUri`
- **Repository**: `ai_chat_bot_repository.dart:48`
- **Model**: `lib/features/ai_chat_bot/domain/models/ai_chat_message_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- content
- message
- metadata
- metadata.cart_updated
- metadata.products
- metadata.products.id
- metadata.products.name
- metadata.products.description
- metadata.products.image_full_url
- metadata.products.video_link
- metadata.products.video_full_url
- metadata.products.video_preview_url
- metadata.products.video_thumbnail_url
- metadata.products.video_embed_url
- metadata.products.images_full_url
- metadata.products.category_id
- metadata.products.category_ids
- metadata.products.category_ids.id
- metadata.products.variations
- metadata.products.variations.type
- metadata.products.variations.price
- metadata.products.variations.stock
- metadata.products.food_variations
- metadata.products.food_variations.max
- metadata.products.food_variations.name
- metadata.products.food_variations.type
- metadata.products.food_variations.min
- metadata.products.food_variations.required
- metadata.products.food_variations.values
- metadata.products.add_ons
- metadata.products.add_ons.id
- metadata.products.add_ons.name
- metadata.products.add_ons.price
- metadata.products.addons
- metadata.products.addons.id
- metadata.products.addons.name
- metadata.products.addons.price
- metadata.products.choice_options
- metadata.products.choice_options.title
- metadata.products.choice_options.options
- metadata.products.price
- metadata.products.discount
- metadata.products.discount_type
- metadata.products.available_time_starts
- metadata.products.available_time_ends
- metadata.products.store_id
- metadata.products.store_name
- metadata.products.zone_id
- metadata.products.schedule_order
- metadata.products.avg_rating
- metadata.products.rating_count
- metadata.products.module_id
- metadata.products.module_type
- metadata.products.veg
- metadata.products.stock
- metadata.products.unit_type
- metadata.products.available_date_starts
- metadata.products.organic
- metadata.products.maximum_cart_quantity
- metadata.products.flash_sale
- metadata.products.halal_tag_status
- metadata.products.is_halal
- metadata.products.is_prescription_required
- metadata.products.nutritions_name
- metadata.products.allergies_name
- metadata.products.generic_name
- metadata.products.store_details
- metadata.products.store_details.id
- metadata.products.store_details.name
- metadata.products.store_details.slug
- metadata.products.store_details.zone_id
- metadata.products.store_details.show_low_stock_count
- metadata.products.store_details.minimum_stock_for_warning
- metadata.products.slug
- metadata.products.verified_seller
- metadata.products.store_image_full_url
- metadata.products.store_logo_full_url
- metadata.products.free_delivery
- metadata.products.offer_label
- metadata.products.brand_name
- metadata.stores
- metadata.stores.id
- metadata.stores.name
- metadata.stores.phone
- metadata.stores.logo_full_url
- metadata.stores.latitude
- metadata.stores.longitude
- metadata.stores.address
- metadata.stores.minimum_order
- metadata.stores.free_delivery
- metadata.stores.cover_photo_full_url
- metadata.stores.delivery
- metadata.stores.take_away
- metadata.stores.schedule_order
- metadata.stores.avg_rating
- metadata.stores.tax
- metadata.stores.rating_count
- metadata.stores.reviews_count
- metadata.stores.self_delivery_system
- metadata.stores.minimum_shipping_charge
- metadata.stores.maximum_shipping_charge
- metadata.stores.per_km_shipping_charge
- metadata.stores.open
- metadata.stores.active
- metadata.stores.zone_id
- metadata.stores.delivery_time
- metadata.stores.veg
- metadata.stores.non_veg
- metadata.stores.module_id
- metadata.stores.module_type
- metadata.stores.order_place_to_schedule_interval
- metadata.stores.category_ids
- metadata.stores.categories
- metadata.stores.store_discount
- metadata.stores.store_discount.day
- metadata.stores.store_discount.opening_time
- metadata.stores.store_discount.closing_time
- metadata.stores.schedules
- metadata.stores.schedules.day
- metadata.stores.schedules.opening_time
- metadata.stores.schedules.closing_time
- metadata.stores.vendor_id
- metadata.stores.prescription_order
- metadata.stores.cutlery
- metadata.stores.slug
- metadata.stores.announcement
- metadata.stores.announcement_message
- metadata.stores.total_items
- metadata.stores.items
- metadata.stores.items.id
- metadata.stores.items.name
- metadata.stores.items.image_full_url
- metadata.stores.items.price
- metadata.stores.items.discount
- metadata.stores.items.discount_type
- metadata.stores.top_items
- metadata.stores.top_items.id
- metadata.stores.top_items.name
- metadata.stores.top_items.slug
- metadata.stores.top_items.image_full_url
- metadata.stores.top_items.thumbnail_full_url
- metadata.stores.top_items.price
- metadata.stores.top_items.base_price
- metadata.stores.top_items.discounted_price
- metadata.stores.top_items.discount
- metadata.stores.top_items.discount_type
- metadata.stores.top_items.avg_rating
- metadata.stores.extra_packaging_status
- metadata.stores.extra_packaging_amount
- metadata.stores.ratings
- metadata.stores.reviews_comments_count
- metadata.stores.store_sub
- metadata.stores.store_sub.chat
- metadata.stores.store_business_model
- metadata.stores.distance
- metadata.stores.distance_km
- metadata.stores.current_opening_time
- metadata.stores.verified_seller
- metadata.stores.avg_item_discount_percentage
- metadata.stores.ad
- metadata.stores.pro_discount
- metadata.stores.pro_discount.start_date
- metadata.stores.pro_discount.end_date
- metadata.stores.pro_discount.min_purchase
- metadata.stores.pro_discount.max_discount
- metadata.stores.pro_discount.discount
- metadata.stores.pro_discount.discount_type
- metadata.stores.is_new
- metadata.stores.sponsored
- metadata.stores.offer_label
- metadata.stores.store_item_image_list
- metadata.stores.description
- metadata.stores.active_coupons
- metadata.categories
- metadata.categories.id
- metadata.categories.name
- metadata.categories.image_full_url
- metadata.categories.slug
- metadata.categories.module_id
- metadata.cart
- metadata.cart.grand_total
- metadata.cart.grand_total.store_id
- metadata.cart.grand_total.store_name
- metadata.cart.grand_total.store_subtotal
- metadata.cart.grand_total.items
- metadata.cart.total_items
- metadata.cart.stores
- metadata.cart.stores.store_id
- metadata.cart.stores.store_name
- metadata.cart.stores.store_subtotal
- metadata.cart.stores.items
- created_at

<a id="api-v1-customer-automated-message-supportreasonuri"></a>
## Endpoint : /api/v1/customer/automated-message

- **Constant**: `AppConstants.supportReasonUri`
- **Repository**: `order_repository.dart:212` — _getSupportReasons
- **Model**: `lib/features/order/domain/models/support_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.message

<a id="api-v1-customer-cm-firebase-token-tokenuri"></a>
## Endpoint : /api/v1/customer/cm-firebase-token

- **Constant**: `AppConstants.tokenUri`
- **Repository**: `auth_repository.dart:163`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-info-customerinfouri"></a>
## Endpoint : /api/v1/customer/info

- **Constant**: `AppConstants.customerInfoUri`
- **Repository**: `profile_repository.dart:18` — get
- **Model**: `lib/features/profile/domain/models/userinfo_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- f_name
- l_name
- email
- image_full_url
- phone
- created_at
- password
- order_count
- wallet_balance
- loyalty_point
- ref_code
- userinfo
- userinfo.id
- userinfo.f_name
- userinfo.l_name
- userinfo.phone
- userinfo.image_full_url
- is_valid_for_discount
- discount_amount
- discount_amount_type
- validity
- selected_modules_for_interest
- is_phone_verified
- is_email_verified
- pro_status
- pro_subscription

<a id="api-v1-customer-loyalty-point-point-transfer-loyaltypointtransferuri"></a>
## Endpoint : /api/v1/customer/loyalty-point/point-transfer

- **Constant**: `AppConstants.loyaltyPointTransferUri`
- **Repository**: `loyalty_repository.dart:13`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-loyalty-point-transactions-loyaltytransactionuri"></a>
## Endpoint : /api/v1/customer/loyalty-point/transactions

- **Constant**: `AppConstants.loyaltyTransactionUri`
- **Repository**: `loyalty_repository.dart:38` — _getLoyaltyTransactionList
- **Model**: `lib/common/models/transaction_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- data
- data.credit
- data.debit
- data.admin_bonus
- data.transaction_type
- data.reference
- data.created_at

<a id="api-v1-customer-message-details-messagelisturi"></a>
## Endpoint : /api/v1/customer/message/details

- **Constant**: `AppConstants.messageListUri`
- **Repository**: `chat_repository.dart:43` — getMessages
- **Model**: `lib/features/chat/domain/models/chat_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- status
- conversation
- conversation.id
- conversation.sender_type
- conversation.receiver_type
- conversation.unread_message_count
- conversation.last_message_time
- conversation.sender
- conversation.sender.id
- conversation.sender.f_name
- conversation.sender.l_name
- conversation.sender.phone
- conversation.sender.image_full_url
- conversation.receiver
- conversation.receiver.id
- conversation.receiver.f_name
- conversation.receiver.l_name
- conversation.receiver.phone
- conversation.receiver.image_full_url
- conversation.last_message
- conversation.last_message.sender_id
- conversation.last_message.message
- conversation.last_message.file_full_url
- conversation.last_message.is_seen
- conversation.last_message.order
- conversation.last_message.order.id
- conversation.last_message.order.order_amount
- conversation.last_message.order.order_status
- conversation.last_message.order.created_at
- conversation.last_message.order.details_count
- conversation.last_message.order.delivery_address
- conversation.last_message.created_at
- messages
- messages.sender_id
- messages.message
- messages.file_full_url
- messages.is_seen
- messages.order
- messages.order.id
- messages.order.order_amount
- messages.order.order_status
- messages.order.created_at
- messages.order.details_count
- messages.order.delivery_address
- messages.order.delivery_address.contact_person_number
- messages.order.delivery_address.address
- messages.order.delivery_address.road
- messages.order.delivery_address.house
- messages.created_at

<a id="api-v1-customer-message-list-conversationlisturi"></a>
## Endpoint : /api/v1/customer/message/list

- **Constant**: `AppConstants.conversationListUri`
- **Repository**: `chat_repository.dart:25` — _getConversationList
- **Model**: `lib/features/chat/domain/models/conversation_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- conversations
- conversations.id
- conversations.sender_type
- conversations.receiver_type
- conversations.unread_message_count
- conversations.last_message_time
- conversations.sender
- conversations.sender.id
- conversations.sender.f_name
- conversations.sender.l_name
- conversations.sender.phone
- conversations.sender.image_full_url
- conversations.receiver
- conversations.receiver.id
- conversations.receiver.f_name
- conversations.receiver.l_name
- conversations.receiver.phone
- conversations.receiver.image_full_url
- conversations.last_message
- conversations.last_message.sender_id
- conversations.last_message.message
- conversations.last_message.file_full_url
- conversations.last_message.is_seen
- conversations.last_message.order
- conversations.last_message.order.id
- conversations.last_message.order.order_amount
- conversations.last_message.order.order_status
- conversations.last_message.order.created_at
- conversations.last_message.order.details_count
- conversations.last_message.order.delivery_address
- conversations.last_message.created_at

<a id="api-v1-customer-message-search-list-searchconversationlisturi"></a>
## Endpoint : /api/v1/customer/message/search-list

- **Constant**: `AppConstants.searchConversationListUri`
- **Repository**: `chat_repository.dart:34` — _searchConversationList
- **Model**: `lib/features/chat/domain/models/conversation_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- conversations
- conversations.id
- conversations.sender_type
- conversations.receiver_type
- conversations.unread_message_count
- conversations.last_message_time
- conversations.sender
- conversations.sender.id
- conversations.sender.f_name
- conversations.sender.l_name
- conversations.sender.phone
- conversations.sender.image_full_url
- conversations.receiver
- conversations.receiver.id
- conversations.receiver.f_name
- conversations.receiver.l_name
- conversations.receiver.phone
- conversations.receiver.image_full_url
- conversations.last_message
- conversations.last_message.sender_id
- conversations.last_message.message
- conversations.last_message.file_full_url
- conversations.last_message.is_seen
- conversations.last_message.order
- conversations.last_message.order.id
- conversations.last_message.order.order_amount
- conversations.last_message.order.order_status
- conversations.last_message.order.created_at
- conversations.last_message.order.details_count
- conversations.last_message.order.delivery_address
- conversations.last_message.created_at

<a id="api-v1-customer-message-send-sendmessageuri"></a>
## Endpoint : /api/v1/customer/message/send

- **Constant**: `AppConstants.sendMessageUri`
- **Repository**: `chat_repository.dart:59` — sendMessage
- **Model**: `lib/features/chat/domain/models/chat_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- offset
- status
- conversation
- conversation.id
- conversation.sender_type
- conversation.receiver_type
- conversation.unread_message_count
- conversation.last_message_time
- conversation.sender
- conversation.sender.id
- conversation.sender.f_name
- conversation.sender.l_name
- conversation.sender.phone
- conversation.sender.image_full_url
- conversation.receiver
- conversation.receiver.id
- conversation.receiver.f_name
- conversation.receiver.l_name
- conversation.receiver.phone
- conversation.receiver.image_full_url
- conversation.last_message
- conversation.last_message.sender_id
- conversation.last_message.message
- conversation.last_message.file_full_url
- conversation.last_message.is_seen
- conversation.last_message.order
- conversation.last_message.order.id
- conversation.last_message.order.order_amount
- conversation.last_message.order.order_status
- conversation.last_message.order.created_at
- conversation.last_message.order.details_count
- conversation.last_message.order.delivery_address
- conversation.last_message.created_at
- messages
- messages.sender_id
- messages.message
- messages.file_full_url
- messages.is_seen
- messages.order
- messages.order.id
- messages.order.order_amount
- messages.order.order_status
- messages.order.created_at
- messages.order.details_count
- messages.order.delivery_address
- messages.order.delivery_address.contact_person_number
- messages.order.delivery_address.address
- messages.order.delivery_address.road
- messages.order.delivery_address.house
- messages.created_at

<a id="api-v1-customer-monthly-order-list-monthlyorderlisturi"></a>
## Endpoint : /api/v1/customer/monthly-order/list

- **Constant**: `AppConstants.monthlyOrderListUri`
- **Repository**: `order_repository.dart:149`
- **Model**: `lib/features/order/domain/models/monthly_order_model.dart`
- **Parsed to model**: Yes

**Data:**

- items
- items.id
- items.order_id
- items.module_id
- items.module_type
- items.remind_at
- items.store
- items.store.id
- items.store.name
- items.store.logo_full_url
- items.store.logo
- items.items_preview
- items.items_preview.name
- items.items_preview.image_full_url
- items.items_preview.image
- items.items_preview.price
- items.items_preview.old_price
- items.items_preview.quantity

<a id="api-v1-customer-monthly-order-remove-monthlyorderremoveuri"></a>
## Endpoint : /api/v1/customer/monthly-order/remove

- **Constant**: `AppConstants.monthlyOrderRemoveUri`
- **Repository**: `order_repository.dart:158` — removeMonthlyOrder
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-notifications-notificationuri"></a>
## Endpoint : /api/v1/customer/notifications

- **Constant**: `AppConstants.notificationUri`
- **Repository**: `notification_repository.dart:17`
- **Model**: `lib/features/notification/domain/models/notification_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- data
- data.title
- data.description
- data.type
- created_at
- updated_at
- image_full_url

<a id="api-v1-customer-pro-customer-active-offer-proactiveofferuri"></a>
## Endpoint : /api/v1/customer/pro-customer/active-offer

- **Constant**: `AppConstants.proActiveOfferUri`
- **Repository**: `pro_repository.dart:41`
- **Model**: `lib/features/pro/domain/models/pro_active_offer_model.dart`
- **Parsed to model**: Yes

**Data:**

- benefit
- benefit.type
- benefit.plan_id
- benefit.percentage
- benefit.max_amount
- benefit.min_order_status
- benefit.min_order_amount
- benefit.offer_type
- benefit.charge_discount_percentage
- plan_details
- plan_details.plan_name
- plan_details.total_saved
- plan_details.total_orders
- plan_details.start_at
- plan_details.end_at
- plan_details.days_remaining
- plan_details.paid_by

<a id="api-v1-customer-pro-customer-cancel-procancelsubscriptionsuri"></a>
## Endpoint : /api/v1/customer/pro-customer/cancel

- **Constant**: `AppConstants.proCancelSubscriptionsUri`
- **Repository**: `pro_repository.dart:65` — cancelSubscription
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-pro-customer-subscribe-procustomersubscribeuri"></a>
## Endpoint : /api/v1/customer/pro-customer/subscribe

- **Constant**: `AppConstants.proCustomerSubscribeUri`
- **Repository**: `pro_repository.dart:54`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-reels-details-reeldetailsuri"></a>
## Endpoint : /api/v1/customer/reels/details

- **Constant**: `AppConstants.reelDetailsUri`
- **Repository**: `reels_details_dialog_widget.dart:723`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-reels-like-reellikeuri"></a>
## Endpoint : /api/v1/customer/reels/like

- **Constant**: `AppConstants.reelLikeUri`
- **Repository**: `reels_repository.dart:70` — toggleReelLike
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-reels-list-reellisturi"></a>
## Endpoint : /api/v1/customer/reels/list

- **Constant**: `AppConstants.reelListUri`
- **Repository**: `reels_repository.dart:40`
- **Model**: `lib/features/reels/domain/models/reel_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size

<a id="api-v1-customer-reels-stats-reelstatsuri"></a>
## Endpoint : /api/v1/customer/reels/stats

- **Constant**: `AppConstants.reelStatsUri`
- **Repository**: `reels_repository.dart:51` — getReelStats
- **Model**: `lib/features/reels/domain/models/reel_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_views
- total_likes
- total_store_visits
- is_liked
- liked

<a id="api-v1-customer-reels-visit-reelvisituri"></a>
## Endpoint : /api/v1/customer/reels/visit

- **Constant**: `AppConstants.reelVisitUri`
- **Repository**: `reels_repository.dart:101` — visitReel
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-remove-account-customerremoveuri"></a>
## Endpoint : /api/v1/customer/remove-account

- **Constant**: `AppConstants.customerRemoveUri`
- **Repository**: `profile_repository.dart:100` — delete
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-suggested-items-suggesteditemuri"></a>
## Endpoint : /api/v1/customer/suggested-items

- **Constant**: `AppConstants.suggestedItemUri`
- **Repository**: `search_repository.dart:94` — _getSuggestedItems
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- description
- image_full_url
- video_link
- video_full_url
- video_preview_url
- video_thumbnail_url
- video_embed_url
- images_full_url
- category_id
- category_ids
- category_ids.id
- variations
- variations.type
- variations.price
- variations.stock
- food_variations
- food_variations.max
- food_variations.name
- food_variations.type
- food_variations.min
- food_variations.required
- food_variations.values
- food_variations.values.label
- food_variations.values.optionPrice
- food_variations.values.isSelected
- add_ons
- add_ons.id
- add_ons.name
- add_ons.price
- addons
- addons.id
- addons.name
- addons.price
- choice_options
- choice_options.title
- choice_options.options
- price
- discount
- discount_type
- available_time_starts
- available_time_ends
- store_id
- store_name
- zone_id
- schedule_order
- avg_rating
- rating_count
- module_id
- module_type
- veg
- stock
- unit_type
- available_date_starts
- organic
- maximum_cart_quantity
- flash_sale
- halal_tag_status
- is_halal
- is_prescription_required
- nutritions_name
- allergies_name
- generic_name
- store_details
- store_details.id
- store_details.name
- store_details.slug
- store_details.zone_id
- store_details.show_low_stock_count
- store_details.minimum_stock_for_warning
- slug
- verified_seller
- store_image_full_url
- store_logo_full_url
- free_delivery
- offer_label
- brand_name

<a id="api-v1-customer-update-interest-interesturi"></a>
## Endpoint : /api/v1/customer/update-interest

- **Constant**: `AppConstants.interestUri`
- **Repository**: `category_repository.dart:107` — saveUserInterests
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-update-profile-updateprofileuri"></a>
## Endpoint : /api/v1/customer/update-profile

- **Constant**: `AppConstants.updateProfileUri`
- **Repository**: `profile_repository.dart:46` — updateProfile
- **Model**: `lib/features/profile/domain/models/update_profile_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- verification_on
- verification_medium
- message

<a id="api-v1-customer-update-zone-updatezoneuri"></a>
## Endpoint : /api/v1/customer/update-zone

- **Constant**: `AppConstants.updateZoneUri`
- **Repository**: `auth_repository.dart:299` — updateZone
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-visit-again-visitagainstoreuri"></a>
## Endpoint : /api/v1/customer/visit-again

- **Constant**: `AppConstants.visitAgainStoreUri`
- **Repository**: `store_repository.dart:231`
- **Model**: `lib/features/store/domain/models/store_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- name
- phone
- logo_full_url
- latitude
- longitude
- address
- minimum_order
- free_delivery
- cover_photo_full_url
- delivery
- take_away
- schedule_order
- avg_rating
- tax
- rating_count
- reviews_count
- self_delivery_system
- minimum_shipping_charge
- maximum_shipping_charge
- per_km_shipping_charge
- open
- active
- zone_id
- delivery_time
- veg
- non_veg
- module_id
- module_type
- order_place_to_schedule_interval
- category_ids
- categories
- store_discount
- store_discount.day
- store_discount.opening_time
- store_discount.closing_time
- schedules
- schedules.day
- schedules.opening_time
- schedules.closing_time
- vendor_id
- prescription_order
- cutlery
- slug
- announcement
- announcement_message
- total_items
- items
- items.id
- items.name
- items.image_full_url
- items.price
- items.discount
- items.discount_type
- top_items
- top_items.id
- top_items.name
- top_items.slug
- top_items.image_full_url
- top_items.thumbnail_full_url
- top_items.price
- top_items.base_price
- top_items.discounted_price
- top_items.discount
- top_items.discount_type
- top_items.avg_rating
- extra_packaging_status
- extra_packaging_amount
- ratings
- reviews_comments_count
- store_sub
- store_sub.chat
- store_business_model
- distance
- distance_km
- current_opening_time
- verified_seller
- avg_item_discount_percentage
- ad
- pro_discount
- pro_discount.start_date
- pro_discount.end_date
- pro_discount.min_purchase
- pro_discount.max_discount
- pro_discount.discount
- pro_discount.discount_type
- is_new
- sponsored
- offer_label
- store_item_image_list
- description
- active_coupons

<a id="api-v1-customer-wallet-add-fund-addfunduri"></a>
## Endpoint : /api/v1/customer/wallet/add-fund

- **Constant**: `AppConstants.addFundUri`
- **Repository**: `wallet_repository.dart:21` — addFundToWallet
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-customer-wallet-bonuses-walletbonusuri"></a>
## Endpoint : /api/v1/customer/wallet/bonuses

- **Constant**: `AppConstants.walletBonusUri`
- **Repository**: `wallet_repository.dart:76` — _getWalletBonusList
- **Model**: `lib/features/wallet/domain/models/fund_bonus_model.dart`
- **Parsed to model**: Yes

**Data:**

- title
- bonus_type
- bonus_amount
- minimum_add_amount
- end_date

<a id="api-v1-customer-wallet-transactions-wallettransactionuri"></a>
## Endpoint : /api/v1/customer/wallet/transactions

- **Constant**: `AppConstants.walletTransactionUri`
- **Repository**: `wallet_repository.dart:67` — _getWalletTransactionList
- **Model**: `lib/common/models/transaction_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- data
- data.credit
- data.debit
- data.admin_bonus
- data.transaction_type
- data.reference
- data.created_at


---

# Auth

<a id="api-v1-auth-delivery-man-store-dmregisteruri"></a>
## Endpoint : /api/v1/auth/delivery-man/store

- **Constant**: `AppConstants.dmRegisterUri`
- **Repository**: `deliveryman_registration_repository.dart:19` — registerDeliveryMan
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-auth-firebase-reset-password-firebaseresetpassword"></a>
## Endpoint : /api/v1/auth/firebase-reset-password

- **Constant**: `AppConstants.firebaseResetPassword`
- **Repository**: `verification_repository.dart:72`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-auth-firebase-verify-token-firebaseauthverify"></a>
## Endpoint : /api/v1/auth/firebase-verify-token

- **Constant**: `AppConstants.firebaseAuthVerify`
- **Repository**: `verification_repository.dart:61`
- **Model**: `lib/features/auth/domain/models/auth_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- token
- is_phone_verified
- is_email_verified
- is_personal_info
- is_exist_user
- is_exist_user.name
- is_exist_user.image
- email

<a id="api-v1-auth-forgot-password-forgetpassworduri"></a>
## Endpoint : /api/v1/auth/forgot-password

- **Constant**: `AppConstants.forgetPasswordUri`
- **Repository**: `verification_repository.dart:21`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-auth-guest-request-guestloginuri"></a>
## Endpoint : /api/v1/auth/guest/request

- **Constant**: `AppConstants.guestLoginUri`
- **Repository**: `auth_repository.dart:71` — guestLogin
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-auth-login-loginuri"></a>
## Endpoint : /api/v1/auth/login

- **Constant**: `AppConstants.loginUri`
- **Repository**: `auth_repository.dart:45` — loginWithSocialMedia
- **Model**: `lib/features/auth/domain/models/auth_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- token
- is_phone_verified
- is_email_verified
- is_personal_info
- is_exist_user
- is_exist_user.name
- is_exist_user.image
- email

<a id="api-v1-auth-reset-password-resetpassworduri"></a>
## Endpoint : /api/v1/auth/reset-password

- **Constant**: `AppConstants.resetPasswordUri`
- **Repository**: `verification_repository.dart:33`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-auth-sign-up-registeruri"></a>
## Endpoint : /api/v1/auth/sign-up

- **Constant**: `AppConstants.registerUri`
- **Repository**: `auth_repository.dart:30` — registration
- **Model**: `lib/features/auth/domain/models/auth_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- token
- is_phone_verified
- is_email_verified
- is_personal_info
- is_exist_user
- is_exist_user.name
- is_exist_user.image
- email

<a id="api-v1-auth-update-info-personalinformationuri"></a>
## Endpoint : /api/v1/auth/update-info

- **Constant**: `AppConstants.personalInformationUri`
- **Repository**: `auth_repository.dart:94`
- **Model**: `lib/features/auth/domain/models/auth_response_model.dart`
- **Parsed to model**: Yes

**Data:**

- token
- is_phone_verified
- is_email_verified
- is_personal_info
- is_exist_user
- is_exist_user.name
- is_exist_user.image
- email

<a id="api-v1-auth-vendor-register-storeregisteruri"></a>
## Endpoint : /api/v1/auth/vendor/register

- **Constant**: `AppConstants.storeRegisterUri`
- **Repository**: `store_registration_repository.dart:15` — registerStore
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-auth-verify-phone-verifyphoneuri"></a>
## Endpoint : /api/v1/auth/verify-phone

- **Constant**: `AppConstants.verifyPhoneUri`
- **Repository**: `verification_repository.dart:46` — verifyPhone
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-auth-verify-token-verifytokenuri"></a>
## Endpoint : /api/v1/auth/verify-token

- **Constant**: `AppConstants.verifyTokenUri`
- **Repository**: `verification_repository.dart:89`
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-get-vehicles-vehiclesuri"></a>
## Endpoint : /api/v1/get-vehicles

- **Constant**: `AppConstants.vehiclesUri`
- **Repository**: `deliveryman_registration_repository.dart:61` — _getVehicleList
- **Model**: `lib/features/auth/domain/models/delivery_man_vehicles_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- type

<a id="api-v1-vendor-business-plan-businessplanuri"></a>
## Endpoint : /api/v1/vendor/business_plan

- **Constant**: `AppConstants.businessPlanUri`
- **Repository**: `business_repo.dart:17` — setUpBusinessPlan
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-vendor-package-view-storepackagesuri"></a>
## Endpoint : /api/v1/vendor/package-view

- **Constant**: `AppConstants.storePackagesUri`
- **Repository**: `business_repo.dart:35`
- **Model**: `lib/features/business/domain/models/package_model.dart`
- **Parsed to model**: Yes

**Data:**

- packages
- packages.id
- packages.package_name
- packages.price
- packages.validity
- packages.max_order
- packages.max_product
- packages.pos
- packages.mobile_app
- packages.chat
- packages.review
- packages.self_delivery

<a id="api-v1-vendor-subscription-payment-api-businessplanpaymenturi"></a>
## Endpoint : /api/v1/vendor/subscription/payment/api

- **Constant**: `AppConstants.businessPlanPaymentUri`
- **Repository**: `business_repo.dart:29` — subscriptionPayment
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_


---

# Parcel

<a id="api-v1-get-parcel-cancellation-reasons-getparcelcancellationreasons"></a>
## Endpoint : /api/v1/get-parcel-cancellation-reasons

- **Constant**: `AppConstants.getParcelCancellationReasons`
- **Repository**: `parcel_repository.dart:109`
- **Model**: `lib/features/parcel/domain/models/parcel_cancellation_reasons_model.dart`
- **Parsed to model**: Yes

**Data:**

- data
- data.reason

<a id="api-v1-parcel-category-parcelcategoryuri"></a>
## Endpoint : /api/v1/parcel-category

- **Constant**: `AppConstants.parcelCategoryUri`
- **Repository**: `parcel_repository.dart:88` — _getParcelCategory
- **Model**: `lib/features/parcel/domain/models/parcel_category_model.dart`
- **Parsed to model**: Yes

**Data:**

- id
- image_full_url
- name
- description
- parcel_per_km_shipping_charge
- parcel_minimum_shipping_charge


---

# Other

<a id="api-v1-searchuri"></a>
## Endpoint : /api/v1/

- **Constant**: `AppConstants.searchUri`
- **Repository**: `search_repository.dart:132` — getSearchData
- **Model**: `lib/features/item/domain/models/item_model.dart`
- **Parsed to model**: Yes

**Data:**

- total_size
- min_price
- max_price
- limit
- offset
- products
- products.id
- products.name
- products.description
- products.image_full_url
- products.video_link
- products.video_full_url
- products.video_preview_url
- products.video_thumbnail_url
- products.video_embed_url
- products.images_full_url
- products.category_id
- products.category_ids
- products.category_ids.id
- products.variations
- products.variations.type
- products.variations.price
- products.variations.stock
- products.food_variations
- products.food_variations.max
- products.food_variations.name
- products.food_variations.type
- products.food_variations.min
- products.food_variations.required
- products.food_variations.values
- products.food_variations.values.label
- products.food_variations.values.optionPrice
- products.food_variations.values.isSelected
- products.add_ons
- products.add_ons.id
- products.add_ons.name
- products.add_ons.price
- products.addons
- products.addons.id
- products.addons.name
- products.addons.price
- products.choice_options
- products.choice_options.title
- products.choice_options.options
- products.price
- products.discount
- products.discount_type
- products.available_time_starts
- products.available_time_ends
- products.store_id
- products.store_name
- products.zone_id
- products.schedule_order
- products.avg_rating
- products.rating_count
- products.module_id
- products.module_type
- products.veg
- products.stock
- products.unit_type
- products.available_date_starts
- products.organic
- products.maximum_cart_quantity
- products.flash_sale
- products.halal_tag_status
- products.is_halal
- products.is_prescription_required
- products.nutritions_name
- products.allergies_name
- products.generic_name
- products.store_details
- products.store_details.id
- products.store_details.name
- products.store_details.slug
- products.store_details.zone_id
- products.store_details.show_low_stock_count
- products.store_details.minimum_stock_for_warning
- products.slug
- products.verified_seller
- products.store_image_full_url
- products.store_logo_full_url
- products.free_delivery
- products.offer_label
- products.brand_name
- items
- items.id
- items.name
- items.description
- items.image_full_url
- items.video_link
- items.video_full_url
- items.video_preview_url
- items.video_thumbnail_url
- items.video_embed_url
- items.images_full_url
- items.category_id
- items.category_ids
- items.category_ids.id
- items.variations
- items.variations.type
- items.variations.price
- items.variations.stock
- items.food_variations
- items.food_variations.max
- items.food_variations.name
- items.food_variations.type
- items.food_variations.min
- items.food_variations.required
- items.food_variations.values
- items.food_variations.values.label
- items.food_variations.values.optionPrice
- items.food_variations.values.isSelected
- items.add_ons
- items.add_ons.id
- items.add_ons.name
- items.add_ons.price
- items.addons
- items.addons.id
- items.addons.name
- items.addons.price
- items.choice_options
- items.choice_options.title
- items.choice_options.options
- items.price
- items.discount
- items.discount_type
- items.available_time_starts
- items.available_time_ends
- items.store_id
- items.store_name
- items.zone_id
- items.schedule_order
- items.avg_rating
- items.rating_count
- items.module_id
- items.module_type
- items.veg
- items.stock
- items.unit_type
- items.available_date_starts
- items.organic
- items.maximum_cart_quantity
- items.flash_sale
- items.halal_tag_status
- items.is_halal
- items.is_prescription_required
- items.nutritions_name
- items.allergies_name
- items.generic_name
- items.store_details
- items.store_details.id
- items.store_details.name
- items.store_details.slug
- items.store_details.zone_id
- items.store_details.show_low_stock_count
- items.store_details.minimum_stock_for_warning
- items.slug
- items.verified_seller
- items.store_image_full_url
- items.store_logo_full_url
- items.free_delivery
- items.offer_label
- items.brand_name
- categories
- categories.id
- categories.name

<a id="api-v1-app-download-section-appdownloadsectionuri"></a>
## Endpoint : /api/v1/app-download-section

- **Constant**: `AppConstants.appDownloadSectionUri`
- **Repository**: `splash_repository.dart:323` — getAppDownloadSection
- **Model**: `lib/features/splash/domain/models/app_download_section_model.dart`
- **Parsed to model**: Yes

**Data:**

- download_user_app_title
- download_user_app_links
- download_user_app_links.playstore_url
- download_user_app_links.apple_store_url

<a id="api-v1-delivery-man-reviews-submit-deliverymanreviewuri"></a>
## Endpoint : /api/v1/delivery-man/reviews/submit

- **Constant**: `AppConstants.deliveryManReviewUri`
- **Repository**: `review_repository.dart:39` — submitDeliveryManReview
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-newsletter-subscribe-subscriptionuri"></a>
## Endpoint : /api/v1/newsletter/subscribe

- **Constant**: `AppConstants.subscriptionUri`
- **Repository**: `splash_repository.dart:218` — subscribeEmail
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_

<a id="api-v1-pro-customer-faqs-profaqsuri"></a>
## Endpoint : /api/v1/pro-customer/faqs

- **Constant**: `AppConstants.proFaqsUri`
- **Repository**: `pro_repository.dart:28` — getProFaqs
- **Model**: `lib/features/pro/domain/models/pro_faq_model.dart`
- **Parsed to model**: Yes

**Data:**

- question
- answer

<a id="api-v1-pro-customer-plans-proplansuri"></a>
## Endpoint : /api/v1/pro-customer/plans

- **Constant**: `AppConstants.proPlansUri`
- **Repository**: `pro_repository.dart:18` — getProPlans
- **Model**: `lib/features/pro/domain/models/pro_plan_model.dart`
- **Parsed to model**: Yes

**Data:**

- pro_brand
- plans
- plans.id
- plans.plan_name
- plans.plan_type
- plans.price
- plans.duration
- plans.duration_label
- plans.status
- benefits
- benefits.discount
- benefits.discount.active
- benefits.discount.config
- benefits.discount.config.percentage
- benefits.discount.config.max_amount
- benefits.discount.config.min_order_status
- benefits.discount.config.min_order_amount
- benefits.discount.modules
- benefits.delivery_fee
- benefits.delivery_fee.active
- benefits.delivery_fee.modules
- benefits.coupon
- benefits.coupon.active

<a id="api-v1-refund-policy-refunduri"></a>
## Endpoint : /api/v1/refund-policy

- **Constant**: `AppConstants.refundUri`
- **Repository**: `html_repository.dart:14` — getHtmlText
- **Model**: _none_
- **Parsed to model**: No

**Data:**

- _(none — response is not parsed; only `statusCode` / `message` is read)_
