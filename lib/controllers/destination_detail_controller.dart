import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import 'package:intl/intl.dart';

class DestinationDetailController extends ChangeNotifier {
  final DestinationModel destination;

  DestinationDetailController(this.destination);

  String _selectedCurrency = 'USD';
  String _selectedTimeZone = 'WIB';

  String get selectedCurrency => _selectedCurrency;
  String get selectedTimeZone => _selectedTimeZone;

  final Map<String, double> exchangeRates = {
    'USD': 0.000062,
    'EUR': 0.000057,
    'JPY': 0.0092,
    'GBP': 0.000050,
    'AUD': 0.000094,
    'SGD': 0.000084,
    'KRW': 0.085,
    'THB': 0.0022,
    'AED': 0.00023,
    'CNY': 0.00045,
    'TRY': 0.00033,
  };

  final Map<String, int> timeZoneOffsets = {
    "WIB": 7,
    "WITA": 8,
    "WIT": 9,
    "London": 0,
  };

  List<String> get currencyList => exchangeRates.keys.toList();
  List<String> get timeZoneList => timeZoneOffsets.keys.toList();

  void updateCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  void updateTimeZone(String timeZone) {
    _selectedTimeZone = timeZone;
    notifyListeners();
  }

  String getConvertedPrice() {
    double priceInIDR = _calculatePriceInIDR();
    final rateSel = exchangeRates[_selectedCurrency] ?? 1;
    final converted = priceInIDR * rateSel;
    return "${converted.toStringAsFixed(2)} $_selectedCurrency";
  }

  String getPriceInIDR() {
    double priceInIDR = _calculatePriceInIDR();
    return NumberFormat.currency(locale: "id_ID", symbol: "Rp ")
        .format(priceInIDR.round());
  }

  double _calculatePriceInIDR() {
    double? apiPrice = destination.apiFlightPrice;
    String? apiCurr = destination.apiCurrency;

    if (apiPrice != null && apiCurr != null) {
      final rateApi = exchangeRates[apiCurr] ?? 1;
      return apiPrice / rateApi;
    } else {
      return destination.flightCostIDR.toDouble();
    }
  }

  DateTime getLocalTime() {
    return DateTime.now()
        .toUtc()
        .add(Duration(hours: destination.timezoneOffset));
  }

  DateTime getConvertedTime() {
    return DateTime.now()
        .toUtc()
        .add(Duration(hours: timeZoneOffsets[_selectedTimeZone] ?? 7));
  }

  String getFormattedLocalTime() {
    return DateFormat("EEE, dd MMM | HH:mm").format(getLocalTime());
  }

  String getFormattedConvertedTime() {
    return DateFormat("EEE, dd MMM | HH:mm").format(getConvertedTime());
  }

  String get title => destination.title;
  String get description => destination.apiDescription ?? destination.description;
  String get imageUrl => destination.apiPhoto ?? destination.thumbnail;
}