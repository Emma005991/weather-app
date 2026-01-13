import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool _darkMode = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('darkMode') ?? false;
    setState(() => _loaded = true);
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _darkMode = !_darkMode);
    await prefs.setBool('darkMode', _darkMode);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: WeatherHomePage(onToggleTheme: _toggleTheme, isDark: _darkMode),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const WeatherHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _controller = TextEditingController();

  bool _loading = false;
  String? _error;

  String? city;
  double? temperature;
  double? feelsLike;
  int? humidity;
  double? wind;
  String? description;
  String? icon;

  static const String apiKey = "YOUR_API_KEY_HERE";

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString('lastCity');
    if (last != null && last.isNotEmpty) {
      _controller.text = last;
      _fetchWeather(last);
    }
  }

  Future<void> _saveLastCity(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCity', name);
  }

  Future<void> _fetchWeather(String cityName) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (apiKey == "YOUR_API_KEY_HERE") {
        throw Exception("API key not set");
      }

      final encodedCity = Uri.encodeComponent(cityName);
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$encodedCity&appid=$apiKey&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("City not found");
      }

      final data = jsonDecode(response.body);

      setState(() {
        city = data["name"];
        temperature = data["main"]["temp"].toDouble();
        feelsLike = data["main"]["feels_like"].toDouble();
        humidity = data["main"]["humidity"];
        wind = data["wind"]["speed"].toDouble();
        description = data["weather"][0]["description"];
        icon = data["weather"][0]["icon"];
      });

      _saveLastCity(cityName);
    } catch (e) {
      setState(() {
        _error = apiKey == "YOUR_API_KEY_HERE"
            ? "Please set your OpenWeather API key in main.dart"
            : "Could not fetch weather. Check the city name.";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _skeleton() {
    return Column(
      children: [
        Container(height: 28, width: 160, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Container(height: 48, width: 120, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Container(height: 16, width: 180, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (_) => Container(height: 80, width: 90, color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter city name",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) _fetchWeather(text);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) _fetchWeather(v.trim());
              },
            ),
            const SizedBox(height: 24),

            if (_loading) _skeleton(),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            if (!_loading && city != null && temperature != null) ...[
              const SizedBox(height: 24),
              Text(city!,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("${temperature!.toStringAsFixed(1)} °C",
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.w300)),
              const SizedBox(height: 8),
              Text(description!.toUpperCase(),
                  style: const TextStyle(letterSpacing: 1.2)),
              const SizedBox(height: 16),
              if (icon != null)
                Image.network(
                  "https://openweathermap.org/img/wn/$icon@2x.png",
                  width: 100,
                  height: 100,
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoCard("Feels", "${feelsLike!.toStringAsFixed(1)}°"),
                  _infoCard("Humidity", "$humidity%"),
                  _infoCard("Wind", "${wind!.toStringAsFixed(1)} m/s"),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
