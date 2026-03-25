abstract class TaxiHomeServiceInterface {
  Future<void> getTopRatedCarList(int offset, bool reload);
  Future<void> getTaxiBannerList(bool reload);
  Future<void> getTaxiCouponList(bool reload);
}
