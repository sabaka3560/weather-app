import 'dart:convert';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  const WeatherService(this.apiKey);
  static const BASE_URL = "http://api.weatherapi.com/v1/current.json";
  final String apiKey;

  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(Uri.parse('$BASE_URL?key=$apiKey&q=$cityName&aqi=no'));
    print(response.body);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load the weather');
    }
  }

  Future<String> getCurrentCity() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permissions are denied.');
      }
    }

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      throw Exception('Failed to get location data.');
    }

    // Perform reverse geocoding using OpenStreetMap's Nominatim API
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final city = decoded['address']['city'];
      print(city);
      if (city != null) {
        return city;
      }
    }

    throw Exception('Failed to get current city.');
  }
}
