class TaxiCartProvider {
  final List<int> pickupZoneId;
  const TaxiCartProvider({this.pickupZoneId = const []});
}

class TaxiCartItem {
  final TaxiCartProvider? provider;
  const TaxiCartItem({this.provider});
}

class TaxiTripDetails {
  final int id;
  final String? phone;
  const TaxiTripDetails({required this.id, this.phone});
}
