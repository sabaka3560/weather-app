import 'package:flutter/material.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget{
  const WeatherPage({super.key});

  @override
  State<StatefulWidget> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>{

  //apikey
  final _weatherService = const WeatherService('35d85458773643d6add45331242607');
   Weather? _weather;
  String? cityName;

  String getWeatherAnimation(String? mainCondition) {
  if (mainCondition == null) return 'assets/sunny.json';

  switch (mainCondition.toLowerCase()) {
    case 'sunny':
    case 'clear':
      return 'assets/sunny.json';
    case 'rain':
    case 'light rain':
    case 'light rain shower':
    case 'moderate rain':
    case 'heavy rain':
    case 'patchy rain possible':
      return 'assets/rain.json';
    case 'thunder':
    case 'thundery outbreaks possible':
    case 'patchy light rain with thunder':
    case 'moderate or heavy rain with thunder':
    case 'patchy light snow with thunder':
    case 'moderate or heavy snow with thunder':
      return 'assets/thunder.json';
    case 'cloud':
    case 'partly cloudy':
    case 'cloudy':
    case 'overcast':
      return 'assets/cloud.json';
    default:
      return 'assets/sunny.json';
  }
  }


  // Fetch the city name and weather
  Future<void> _fetchCityAndWeather() async {
    cityName = await _weatherService.getCurrentCity();
    if (cityName != null) {
      try {
        final weather = await _weatherService.getWeather(cityName!);
        setState(() {
          _weather = weather;
        });
      } catch (e) {
        print(e);
      }
    }
  }

  //weather animations

  //init state
  @override
  void initState() {
    
    super.initState();
    _fetchCityAndWeather();
  }

  //fetch weather
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //CITY NAME
            Text(
              cityName == null ? "Locating You" : cityName!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            //Animation
            Lottie.asset(getWeatherAnimation(_weather?.condition)),


            //Tempertature
            if (_weather == null && cityName != null)
              CircularProgressIndicator(),
            Text('${_weather?.temperature.round()} Degrees Celciues'),
    
            Text(_weather?.condition ?? " " )
        ],),
      ),
    );
  }
}