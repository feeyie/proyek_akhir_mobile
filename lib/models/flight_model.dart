class FlightModel {
  final String id;
  final String airline;
  final String flightNumber;
  final String originCity;
  final String destinationCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String duration;
  final double price;
  final String cabinClass;
  final int stops;
  final String origin; 
  final String destination; 

  FlightModel({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.originCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.cabinClass,
    required this.stops,
    required this.origin, 
    required this.destination,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'flightNumber': flightNumber,
      'originCity': originCity,
      'destinationCity': destinationCity,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'duration': duration,
      'price': price,
      'cabinClass': cabinClass,
      'stops': stops,
      'origin': origin, 
      'destination': destination, 
    };
  }

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'],
      airline: json['airline'],
      flightNumber: json['flightNumber'],
      originCity: json['originCity'],
      destinationCity: json['destinationCity'],
      departureTime: DateTime.parse(json['departureTime']),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      duration: json['duration'],
      price: json['price'].toDouble(),
      cabinClass: json['cabinClass'],
      stops: json['stops'],
      origin: json['origin'] ?? json['originCity'], 
      destination: json['destination'] ?? json['destinationCity'], 
    );
  }
}