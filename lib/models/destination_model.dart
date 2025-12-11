class DestinationModel {
  final String title;
  final String description;
  final String thumbnail;
  final String currencyCode;
  final int timezoneOffset;
  final double flightCostIDR;

  final String? apiPhoto;
  final String? apiDescription;
  final double? apiFlightPrice; 
  final String? apiCurrency;

  DestinationModel({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.currencyCode,
    required this.timezoneOffset,
    required this.flightCostIDR,
    this.apiPhoto,
    this.apiDescription,
    this.apiFlightPrice,
    this.apiCurrency,
  });

  String getTimeOffsetText() {
    if (timezoneOffset == 0) return 'GMT ±0';
    return timezoneOffset > 0 ? 'GMT +$timezoneOffset' : 'GMT $timezoneOffset';
  }

  DestinationModel copyWith({
    String? title,
    String? description,
    String? thumbnail,
    String? currencyCode,
    int? timezoneOffset,
    double? flightCostIDR,
    String? apiPhoto,
    String? apiDescription,
    double? apiFlightPrice,
    String? apiCurrency,
  }) {
    return DestinationModel(
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      currencyCode: currencyCode ?? this.currencyCode,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      flightCostIDR: flightCostIDR ?? this.flightCostIDR,
      apiPhoto: apiPhoto ?? this.apiPhoto,
      apiDescription: apiDescription ?? this.apiDescription,
      apiFlightPrice: apiFlightPrice ?? this.apiFlightPrice,
      apiCurrency: apiCurrency ?? this.apiCurrency,
    );
  }
}
